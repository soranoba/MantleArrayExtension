//
//  MAEArrayAdapter.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/27.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEArrayAdapter.h"
#import "MAESeparatedString.h"
#import "NSArray+MAESeparatedString.h"
#import "NSError+MAEErrorCode.h"
#import <Mantle/EXTRuntimeExtensions.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <objc/runtime.h>

static unichar const MAEDefaultSeparator = ' ';

@interface MAEArrayAdapter ()

@property (nonatomic, nonnull, strong) Class modelClass;
/// A cached copy of the return value of +formatByPropertyKey
@property (nonatomic, nonnull, copy) NSArray<MAEFragment*>* formatByPropertyKey;
/// A cached copy of the return value of +separator
@property (nonatomic, assign) unichar separator;
/// A cached copy of the return value of +propertyKeys
@property (nonatomic, nonnull, copy) NSSet<NSString*>* propertyKeys;
/// A cached copy of the return value of -valueTransforersForModelClass:
@property (nonatomic, nonnull, copy) NSDictionary* valueTransformersByPropertyKey;
/// A cached copy of the return value of +ignoreEdgeBlank
@property (nonatomic, assign) BOOL ignoreEdgeBlank;

@end

@implementation MAEArrayAdapter

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    NSAssert(NO, @"%@ MUST be initialized with designated initializer", self.class);
    return nil;
}

- (instancetype _Nonnull)initWithModelClass:(Class _Nonnull)modelClass
{
    NSParameterAssert(modelClass != nil);

    if (self = [super init]) {
        self.modelClass = modelClass;
        self.propertyKeys = [modelClass propertyKeys];

        if ([modelClass respondsToSelector:@selector(separator)]) {
            self.separator = [modelClass separator];
        } else {
            self.separator = MAEDefaultSeparator;
        }

        if ([modelClass respondsToSelector:@selector(ignoreEdgeBlank)]) {
            self.ignoreEdgeBlank = [modelClass ignoreEdgeBlank];
        } else {
            self.ignoreEdgeBlank = YES;
        }

        NSMutableArray* formatByPropertyKey = [NSMutableArray array];
        BOOL foundVariadic = NO;
        for (id fragment in [modelClass formatByPropertyKey]) {
            if (foundVariadic) {
                NSAssert(NO, @"Variadic MUST be the last");
                break;
            } else if ([fragment isKindOfClass:NSString.class]) {
                NSAssert([self.propertyKeys containsObject:fragment],
                         @"Not found a property named %@", fragment);
                [formatByPropertyKey addObject:[[MAEFragment alloc] initWithPropertyName:fragment]];
            } else {
                NSAssert([fragment isKindOfClass:MAEFragment.class],
                         @"formatByPropertyKey only support NSString and MAEFragment, but got %@", [fragment class]);
                foundVariadic |= [fragment isVariadic];
                NSAssert([self.propertyKeys containsObject:[fragment propertyName]],
                         @"Not found a property named %@", [fragment propertyName]);
                [formatByPropertyKey addObject:fragment];
            }
        }
        NSAssert([NSSet setWithArray:formatByPropertyKey].count == formatByPropertyKey.count,
                 @"The same property key is used more than once");
        self.formatByPropertyKey = formatByPropertyKey;

        self.valueTransformersByPropertyKey = [self.class valueTransformersForModelClass:modelClass];
    }
    return self;
}

#pragma mark - Public Methods

+ (id<MAEArraySerializing> _Nullable)modelOfClass:(Class _Nonnull)modelClass
                                       fromString:(NSString* _Nullable)string
                                            error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(modelClass != nil);
    MAEArrayAdapter* adapter = [[self alloc] initWithModelClass:modelClass];
    return [adapter modelFromString:string error:error];
}

+ (id<MAEArraySerializing> _Nullable)modelOfClass:(Class _Nonnull)modelClass
                                        fromArray:(NSArray<NSString*>* _Nullable)array
                                            error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(modelClass != nil);
    MAEArrayAdapter* adapter = [[self alloc] initWithModelClass:modelClass];
    return [adapter modelFromArray:array error:error];
}

+ (NSArray<MAESeparatedString*>* _Nullable)arrayFromModel:(id<MAEArraySerializing> _Nullable)model
                                                    error:(NSError* _Nullable* _Nullable)error
{
    if (!model) {
        SET_ERROR(error, MAEErrorNilInputData,
                  @{ NSLocalizedFailureReasonErrorKey : @"The model instance is nil" });
        return nil;
    }
    MAEArrayAdapter* adapter = [[self alloc] initWithModelClass:[model class]];
    return [adapter arrayFromModel:model error:error];
}

+ (NSString* _Nullable)stringFromModel:(id<MAEArraySerializing> _Nullable)model
                                 error:(NSError* _Nullable* _Nullable)error
{
    if (!model) {
        SET_ERROR(error, MAEErrorNilInputData,
                  @{ NSLocalizedFailureReasonErrorKey : @"The model instance is nil" });
        return nil;
    }
    MAEArrayAdapter* adapter = [[self alloc] initWithModelClass:[model class]];
    return [adapter stringFromModel:model error:error];
}

#pragma mark Instance Methods

- (id<MAEArraySerializing> _Nullable)modelFromString:(NSString* _Nullable)string
                                               error:(NSError* _Nullable* _Nullable)error
{
    if (!string) {
        SET_ERROR(error, MAEErrorNilInputData,
                  @{ NSLocalizedFailureReasonErrorKey : @"Input string is nil" });
        return nil;
    }

    NSArray<MAESeparatedString*>* separatedStrings = [self separateString:string];
    if (!separatedStrings) {
        SET_ERROR(error, MAEErrorInvalidInputData,
                  @{ NSLocalizedFailureReasonErrorKey : @"Unclosed single or double quoted string is exist" });
        return nil;
    }

    return [self modelFromSeparatedStrings:separatedStrings
                                     error:error];
}

- (id<MAEArraySerializing> _Nullable)modelFromArray:(NSArray<NSString*>* _Nullable)array
                                              error:(NSError* _Nullable* _Nullable)error
{
    if (!array) {
        SET_ERROR(error, MAEErrorNilInputData,
                  @{ NSLocalizedFailureReasonErrorKey : @"Input array is nil" });
        return nil;
    }

    NSMutableArray<MAESeparatedString*>* separatedStrings = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString* s in array) {
        if ([s isKindOfClass:MAESeparatedString.class]) {
            [separatedStrings addObject:(MAESeparatedString*)s];
        } else {
            [separatedStrings addObject:[[MAESeparatedString alloc] initWithOriginalCharacters:s ignoreEdgeBlank:NO]];
        }
    }

    return [self modelFromSeparatedStrings:separatedStrings error:error];
}

- (NSString* _Nullable)stringFromModel:(id<MAEArraySerializing> _Nullable)model
                                 error:(NSError* _Nullable* _Nullable)error
{
    NSArray<MAESeparatedString*>* array = [self arrayFromModel:model error:error];
    if (!array) {
        return nil;
    }
    return [array mae_componentsJoinedBySeparatedString:self.separator];
}

- (NSArray<MAESeparatedString*>* _Nullable)arrayFromModel:(id<MAEArraySerializing> _Nullable)model
                                                    error:(NSError* _Nullable* _Nullable)error
{
    if (!model) {
        SET_ERROR(error, MAEErrorNilInputData,
                  @{ NSLocalizedFailureReasonErrorKey : @"Input model is nil" });
        return nil;
    }

    if (![model isMemberOfClass:self.modelClass]) {
        return [self.class arrayFromModel:model error:error];
    }

    NSMutableArray<MAESeparatedString*>* result = [NSMutableArray array];
    NSDictionary* dictionaryValue = [model.dictionaryValue dictionaryWithValuesForKeys:self.propertyKeys.allObjects];
    for (MAEFragment* fragment in self.formatByPropertyKey) {
        id value = dictionaryValue[fragment.propertyName];
        if ([value isEqual:NSNull.null] && fragment.optional) {
            continue;
        }

        NSValueTransformer* transformer = self.valueTransformersByPropertyKey[fragment.propertyName];
        if ([transformer.class allowsReverseTransformation]) {
            if ([transformer respondsToSelector:@selector(reverseTransformedValue:success:error:)]) {
                id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;
                BOOL success = YES;
                value = [errorHandlingTransformer reverseTransformedValue:value success:&success error:error];
                if (!success) {
                    return nil;
                }
            } else {
                value = [transformer reverseTransformedValue:value];
            }
        }

        if (!value || value == NSNull.null) {
            value = @"";
        }

        if (![value isKindOfClass:NSArray.class]) {
            value = @[ value ];
        }

        for (NSString* transformedString in value) {
            if (![transformedString isKindOfClass:NSString.class]) {
                SET_ERROR(error, MAEErrorInvalidInputData,
                          @{ NSLocalizedFailureReasonErrorKey :
                                 format(@"The result of reverseTransform MUST be NSString or NSArray, but got %@", [value class]) });
                return nil;
            }

            MAEStringType type;
            switch (fragment.type) {
                case MAEFragmentDoubleQuotedString:
                    type = MAEStringTypeDoubleQuoted;
                    break;
                case MAEFragmentSingleQuotedString:
                    type = MAEStringTypeSingleQuoted;
                    break;
                case MAEFragmentMaybeQuotedString:
                    type = ([transformedString rangeOfString:@" "].location == NSNotFound && transformedString.length > 0)
                        ? MAEStringTypeEnumerate
                        : MAEStringTypeDoubleQuoted;
                    break;
                default:
                    type = MAEStringTypeEnumerate;
                    break;
            }
            [result addObject:[[MAESeparatedString alloc] initWithCharacters:transformedString type:type]];
        }
    }
    return result;
}

#pragma mark - Private Methods

/**
 * Convert to model from separatedString
 *
 * @param separatedStrings An array of MAESeparatedString.
 * @param error            If it return nil, error information is saved here.
 * @return A model instance
 */
- (id<MAEArraySerializing> _Nullable)modelFromSeparatedStrings:(NSArray<MAESeparatedString*>* _Nonnull)separatedStrings
                                                         error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(separatedStrings != nil);

    if ([self.modelClass respondsToSelector:@selector(classForParsingArray:)]) {
        Class class = [self.modelClass classForParsingArray:separatedStrings];
        if (class == nil) {
            SET_ERROR(error, MAEErrorNoConversionTarget,
                      @{ NSLocalizedFailureReasonErrorKey :
                             format(@"%@ # classForParsingArray returns nil", self.modelClass) });
            return nil;
        }

        if (class != self.modelClass) {
            NSAssert([class conformsToProtocol:@protocol(MAEArraySerializing)],
                     @"classForParsingArray MUST return MAEArraySerializing MTLModel class. but got %@", class);

            MAEArrayAdapter* otherAdapter = [[self.class alloc] initWithModelClass:class];

            // NOTE: If separator is different, it will start over from separate process again.
            if (otherAdapter.separator != self.separator) {
                NSString* mergeString = [separatedStrings mae_componentsJoinedBySeparatedString:self.separator];
                return [otherAdapter modelFromString:mergeString error:error];
            }
            return [otherAdapter modelFromSeparatedStrings:separatedStrings error:error];
        }
    }

    NSArray<MAEFragment*>* fragments = [self.class chooseFormatByPropertyKey:self.formatByPropertyKey
                                                                   withCount:separatedStrings.count];
    if (!fragments) {
        SET_ERROR(error, MAEErrorNotMatchFragmentCount,
                  @{ NSLocalizedFailureReasonErrorKey :
                         format(@"Expected format is %@, but got fragment count is %@",
                                self.formatByPropertyKey, @(separatedStrings.count)) });
        return nil;
    }

    NSMutableDictionary* dictionaryValue = [NSMutableDictionary dictionaryWithCapacity:fragments.count];
    NSEnumerator* sEnum = separatedStrings.objectEnumerator;

    MAESeparatedString* s;
    for (MAEFragment* fragment in fragments) {
        id value;

        if (fragment.isVariadic) {
            NSMutableArray* arr = [NSMutableArray array];
            while ((s = [sEnum nextObject])) {
                if (![self.class validateOfSeparatedString:s withExpectedFragment:fragment error:error]) {
                    return nil;
                }
                [arr addObject:s];
            }
            value = arr;
        } else {
            s = [sEnum nextObject];
            NSAssert(s, @"Incorrect number of elements in separatedString");

            if (![self.class validateOfSeparatedString:s withExpectedFragment:fragment error:error]) {
                return nil;
            }
            value = s;
        }

        NSValueTransformer* transformer = self.valueTransformersByPropertyKey[fragment.propertyName];
        if (transformer) {
            if ([transformer respondsToSelector:@selector(transformedValue:success:error:)]) {
                id<MTLTransformerErrorHandling> errorHandlingTransformer = (id)transformer;
                BOOL success = YES;
                value = [errorHandlingTransformer transformedValue:value success:&success error:error];
                if (!success) {
                    return nil;
                }
            } else {
                value = [transformer transformedValue:value];
            }
        }

        dictionaryValue[fragment.propertyName] = value;
    }
    id model = [self.modelClass modelWithDictionary:dictionaryValue error:error];
    return [model validate:error] ? model : nil;
}

/**
 * Validate that separated string matches the form of fragment
 *
 * @param separatedString  A SeparatedString to be validated.
 * @param fragment         A fragment to be expected.
 * @param error            If it return nil, error information is saved here
 * @return If it is valid, it returns YES. Otherwise, it returns NO.
 */
+ (BOOL)validateOfSeparatedString:(MAESeparatedString* _Nonnull)separatedString
             withExpectedFragment:(MAEFragment* _Nonnull)fragment
                            error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(separatedString != nil && fragment != nil);

    NSString* expectedType = nil;
    switch (fragment.type) {
        case MAEFragmentDoubleQuotedString:
            if (separatedString.type != MAEStringTypeDoubleQuoted) {
                expectedType = @"double quoted string";
            }
            break;
        case MAEFragmentSingleQuotedString:
            if (separatedString.type != MAEStringTypeSingleQuoted) {
                expectedType = @"single quoted string";
            }
            break;
        case MAEFragmentEnumerateString:
            if (separatedString.type != MAEStringTypeEnumerate) {
                expectedType = @"enumerate string";
            }
            break;
        default:
            break;
    }
    if (expectedType) {
        SET_ERROR(error, MAEErrorNotMatchFragmentType,
                  @{ NSLocalizedFailureReasonErrorKey :
                         format(@"%@ expected %@", fragment.propertyName, expectedType) });
        return NO;
    }
    return YES;
}

/**
 * Separate the string and return an array of separatedString
 *
 * @param string A string
 * @return If the string contains unclosed-quoted, it returns nil.
 *         Otherwise, it returns an array of separatedString.
 */
- (NSArray<MAESeparatedString*>* _Nullable)separateString:(NSString* _Nonnull)string
{
    NSParameterAssert(string != nil);

    unichar* chars = malloc(sizeof(unichar) * (string.length + 1));
    [string getCharacters:chars range:NSMakeRange(0, string.length)];
    chars[string.length] = '\0';

    unichar* p = chars;
    unichar *start = nil, *end = nil;
    BOOL doubleQuoted = NO, singleQuoted = NO;
    NSMutableArray<MAESeparatedString*>* separatedStrings =
        [NSMutableArray arrayWithCapacity:self.formatByPropertyKey.count];

    void (^append)(unichar* _Nullable, unichar* _Nullable) = ^void(unichar* _Nullable start, unichar* _Nullable end) {
        NSString* str = (start <= end) ? [NSString stringWithCharacters:start length:end - start + 1] : @"";
        [separatedStrings addObject:[[MAESeparatedString alloc] initWithOriginalCharacters:str
                                                                           ignoreEdgeBlank:self.ignoreEdgeBlank]];
    };

    for (start = p; *p != '\0'; p++) {
        if (*p == '\\') {
            if (*(++p) == '\0') {
                break;
            }
        } else if (!singleQuoted && !doubleQuoted && *p == self.separator) {
            if (*p == ' ' && self.ignoreEdgeBlank && *(p + 1) == ' ') {
                // NOP
            } else {
                end = p - 1;
                append(start, end);
                start = p + 1;
                end = nil;
            }
        } else if (!singleQuoted && *p == '"') {
            doubleQuoted = !doubleQuoted;
        } else if (!doubleQuoted && *p == '\'') {
            singleQuoted = !singleQuoted;
        }
    }
    end = p - 1;

    if (*start != '\0') {
        if (!doubleQuoted && !singleQuoted) {
            append(start, end);
        } else {
            // NOTE: unclosed-quoted
            separatedStrings = nil;
        }
    }

    free(chars);
    return separatedStrings;
}

/**
 * It returns fragments with unnecessary optional elements removed for the count elements.
 *
 * @param fragments The fragments that contains optional elements
 * @param count     The count of separated string. It is not fragments.count.
 * @return If it does not correspond to the count, it returns nil.
 *         Otherwise, it returns fragments with unnecessary optional elements removed for the count elements.
 */
+ (NSArray<MAEFragment*>* _Nullable)chooseFormatByPropertyKey:(NSArray<MAEFragment*>* _Nonnull)fragments
                                                    withCount:(NSUInteger)count
{
    NSParameterAssert(fragments != nil);

    if (fragments.count == count) {
        return fragments;
    } else if (fragments.count < count) {
        if ([fragments lastObject].variadic) {
            return fragments;
        }
    } else { // fragments.count > count
        BOOL hasRequirementsVariadic = NO;
        NSMutableArray<MAEFragment*>* filteredFragments = [fragments mutableCopy];
        for (MAEFragment* fragment in fragments.reverseObjectEnumerator) {
            if (fragment.optional) {
                [filteredFragments removeObject:fragment];
            } else if (fragment.variadic) {
                NSAssert(hasRequirementsVariadic == NO, @"Variadic is allowed only one, but there are multiple variadic");
                hasRequirementsVariadic = YES;
            }

            if (filteredFragments.count - (int)hasRequirementsVariadic == count) {
                return filteredFragments;
            }
        }
    }
    return nil;
}

/**
 * It returns transformer of all used properties on modelClass.
 *
 * It also solve the default transformer.
 *
 * @param modelClass   A modelClass that conforms to MAEArraySerializing
 * @return transformers
 */
+ (NSDictionary* _Nonnull)valueTransformersForModelClass:(Class _Nonnull)modelClass
{
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MAEArraySerializing)]);

    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (NSString* propertyKey in [modelClass propertyKeys]) {
        SEL selector = NSSelectorFromString([propertyKey stringByAppendingString:@"ArrayTransformer"]);
        if ([modelClass respondsToSelector:selector]) {
            IMP imp = [modelClass methodForSelector:selector];
            result[propertyKey] = ((NSValueTransformer * (*)(id, SEL))imp)(modelClass, selector);
            continue;
        }

        if ([modelClass respondsToSelector:@selector(arrayTransformerForKey:)]) {
            NSValueTransformer* transformer = [modelClass arrayTransformerForKey:propertyKey];
            if (transformer) {
                result[propertyKey] = transformer;
                continue;
            }
        }

        objc_property_t property = class_getProperty(modelClass, propertyKey.UTF8String);
        if (!propertyKey) {
            continue;
        }

        mtl_propertyAttributes* attributes = mtl_copyPropertyAttributes(property);
        if (*(attributes->type) == *(@encode(id))) {
            Class klass = attributes->objectClass;

            NSValueTransformer* transformer = nil;
            if ([klass conformsToProtocol:@protocol(MAEArraySerializing)]) {
                transformer = [self stringTransformerWithArrayModelClass:klass];
            } else if ([klass isSubclassOfClass:NSNumber.class]) {
                transformer = [self numberTransformer];
            }

            if (!transformer) {
                transformer = [NSValueTransformer mtl_validatingTransformerForClass:(klass ?: NSObject.class)];
            }
            result[propertyKey] = transformer;
        } else {
            result[propertyKey] = [self stringTransformerForObjCType:attributes->type]
                ?: [NSValueTransformer mtl_validatingTransformerForClass:NSValue.class];
        }
        free(attributes);
    }
    return result;
}

/**
 * It returns a transformer for converting between NSString and ObjCType.
 *
 * @param objCType   An ObjCType
 * @return If the type does not support, it returns nil. Otherwise, it returns a transfomer.
 */
+ (NSValueTransformer* _Nullable)stringTransformerForObjCType:(const char* _Nonnull)objCType
{
    NSParameterAssert(objCType != nil);

    if (strcmp(objCType, @encode(char)) == 0
        || strcmp(objCType, @encode(int)) == 0
        || strcmp(objCType, @encode(short)) == 0
        || strcmp(objCType, @encode(long)) == 0
        || strcmp(objCType, @encode(long long)) == 0
        || strcmp(objCType, @encode(unsigned char)) == 0
        || strcmp(objCType, @encode(unsigned int)) == 0
        || strcmp(objCType, @encode(unsigned short)) == 0
        || strcmp(objCType, @encode(unsigned long)) == 0
        || strcmp(objCType, @encode(unsigned long long)) == 0
        || strcmp(objCType, @encode(float)) == 0
        || strcmp(objCType, @encode(double)) == 0) {
        return [self.class numberTransformer];
    } else if (strcmp(objCType, @encode(BOOL)) == 0) {
        return [self.class boolTransformer];
    }

    return nil;
}

@end
