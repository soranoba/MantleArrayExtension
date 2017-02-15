//
//  MAEArrayAdapter.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/27.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEArrayAdapter.h"
#import "MAESeparatedString.h"
#import "NSError+MAEErrorCode.h"
#import <Mantle/EXTRuntimeExtensions.h>
#import <Mantle/MTLReflection.h>
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import <objc/runtime.h>

static unichar const MAEDefaultSeparator = ' ';

/// It is a Key to use for non-local exits (NSException)
static NSString* const MAESeparatorChanged = @"MAESeparatorChanged";

static NSString* const MAEAdapter = @"MAEAdapter";

@interface MAEArrayAdapter ()

@property (nonatomic, nonnull, strong) Class modelClass;
/// A cached copy of the return value of +formatByPropertyKey
@property (nonatomic, nonnull, copy) NSArray<MAEFragment*>* formatByPropertyKey;
/// A cached copy of the return value of +separator
@property (nonatomic, assign) unichar separator;
/// A cached copy of the return value of +propertyKeys
@property (nonatomic, nonnull, copy) NSSet<NSString*>* propertyKeys;
/// A cached copy of the return value of -valueTransforersForModelClass:
@property (nonatomic, nonnull, copy)
    NSDictionary* valueTransformersByPropertyKey;
/// A cached copy of the return value of +ignoreEdgeBlank
@property (nonatomic, assign) BOOL ignoreEdgeBlank;

@end

@implementation MAEArrayAdapter

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    NSAssert(NO, @"%@ MUST be initialized with designed initializer", self.class);
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
            if ([fragment isKindOfClass:NSString.class]) {
                [formatByPropertyKey addObject:[[MAEFragment alloc] initWithPropertyName:fragment]];
            } else if (foundVariadic) {
                NSAssert(NO, @"Variadic MUST be the last");
                break;
            } else {
                NSAssert([fragment isKindOfClass:MAEFragment.class],
                         @"formatByPropertyKey only support NSString and MAEFragment, but got %@", [fragment class]);
                foundVariadic |= [fragment isVariadic];
                if ([self.propertyKeys containsObject:[fragment propertyName]]) {
                    [formatByPropertyKey addObject:fragment];
                }
            }
        }
        self.formatByPropertyKey = formatByPropertyKey;

        self.valueTransformersByPropertyKey = [self.class valueTransformeresForModelClass:modelClass];
    }
    return self;
}

#pragma mark - Public Methods

#pragma mark Convertion between model to string or array

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

+ (NSArray<NSString*>* _Nullable)arrayFromModel:(id<MAEArraySerializing> _Nullable)model
                                          error:(NSError* _Nullable* _Nullable)error
{
    if (!model) {
        SET_ERROR(error, MAEErrorInputNil, @"The model instance is nil");
        return nil;
    }
    MAEArrayAdapter* adapter = [[self alloc] initWithModelClass:[model class]];
    return [adapter arrayFromModel:model error:error];
}

+ (NSString* _Nullable)stringFromModel:(id<MAEArraySerializing> _Nullable)model
                                 error:(NSError* _Nullable* _Nullable)error
{
    if (!model) {
        SET_ERROR(error, MAEErrorInputNil, @"The model instance is nil");
        return nil;
    }
    MAEArrayAdapter* adapter = [[self alloc] initWithModelClass:[model class]];
    return [adapter stringFromModel:model error:error];
}

- (id<MAEArraySerializing> _Nullable)modelFromString:(NSString* _Nullable)string
                                               error:(NSError* _Nullable* _Nullable)error
{
    if (!string) {
        SET_ERROR(error, MAEErrorInputNil, @"Input string is nil");
        return nil;
    }

    @try {
        return [self modelFromSeparatedStrings:[self separateString:string]
                                         error:error];
    } @catch (NSException* exception) {
        if (exception.name == MAESeparatorChanged) {
            MAEArrayAdapter* otherAdapter = exception.userInfo[MAEAdapter];
            return [otherAdapter modelFromString:string error:error];
        }
        @throw exception;
    }
}

- (id<MAEArraySerializing> _Nullable)modelFromArray:(NSArray<NSString*>* _Nullable)array
                                              error:(NSError* _Nullable* _Nullable)error
{
    if (!array) {
        SET_ERROR(error, MAEErrorInputNil, @"Input array is nil");
        return nil;
    }

    NSMutableArray<MAESeparatedString*>* separatedStrings = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString* s in array) {
        [separatedStrings addObject:[[MAESeparatedString alloc] initWithString:s]];
    }

    @try {
        return [self modelFromSeparatedStrings:separatedStrings error:error];
    } @catch (NSException* exception) {
        if (exception.name == MAESeparatorChanged) {
            MAEArrayAdapter* otherAdapter = exception.userInfo[MAEAdapter];
            return [otherAdapter modelFromSeparatedStrings:separatedStrings error:error];
        }
        @throw exception;
    }
}

- (NSString* _Nullable)stringFromModel:(id<MAEArraySerializing> _Nullable)model
                                 error:(NSError* _Nullable* _Nullable)error
{
    NSArray<NSString*>* array = [self arrayFromModel:model error:error];
    if (!array) {
        return nil;
    }
    unichar c = self.separator;
    return [array componentsJoinedByString:[NSString stringWithCharacters:&c length:1]];
}

- (NSArray<NSString*>* _Nullable)arrayFromModel:(id<MAEArraySerializing> _Nullable)model
                                          error:(NSError* _Nullable* _Nullable)error
{
    if (!model) {
        SET_ERROR(error, MAEErrorInputNil, @"Input model is nil");
        return nil;
    }

    if (![model isMemberOfClass:self.modelClass]) {
        return [self.class arrayFromModel:model error:error];
    }

    NSMutableArray<NSString*>* result = [NSMutableArray array];
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

        if (value == NSNull.null) {
            value = @"";
        }

        if (![value isKindOfClass:NSArray.class]) {
            value = @[ value ];
        }

        for (NSString* transformedString in value) {
            if (![transformedString isKindOfClass:NSString.class]) {
                SET_ERROR(error, MAEErrorTransform,
                          [NSString stringWithFormat:@"The result of reverseTransform MUST be NSString or NSArray, but got %@",
                                                     [value class]]);
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
                    type = [transformedString rangeOfString:@" "].location == NSNotFound
                        ? MAEStringTypeEnumerate
                        : MAEStringTypeDoubleQuoted;
                    break;
                default:
                    type = MAEStringTypeEnumerate;
                    break;
            }
            [result addObject:[[[MAESeparatedString alloc] initWithCharacters:transformedString type:type] toString]];
        }
    }
    return result;
}

#pragma mark Transformer

+ (NSValueTransformer* _Nonnull)variadicArrayTransformerWithModelClass:(Class _Nonnull)modelClass
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                if (!value) {
                    return nil;
                }

                if (![value isKindOfClass:NSArray.class]) {
                    SET_ERROR(error, MAEErrorBadArguemt,
                              @"arrayTransformerWithModelClass only support to convert from between NSArray and MTLModel");
                    *success = NO;
                    return nil;
                }
                id model = [self modelOfClass:modelClass fromArray:value error:error];
                *success = model != nil;
                return model;
            }
        reverseBlock:^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
            if (!value) {
                return nil;
            }

            if (!([value isKindOfClass:MTLModel.class] &&
                  [value conformsToProtocol:@protocol(MAEArraySerializing)])) {
                SET_ERROR(error, MAEErrorBadArguemt,
                          @"arrayTransformerWithModelClass only support MAEArraySerializing MTLModel");
                *success = NO;
                return nil;
            }

            NSArray* array = [self arrayFromModel:value error:error];
            *success = array != nil;
            return array;
        }];
}

+ (NSValueTransformer* _Nonnull)arrayTransformerWithModelClass:(Class _Nonnull)modelClass
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                if (!value) {
                    return nil;
                }

                if (![value isKindOfClass:NSString.class]) {
                    SET_ERROR(error, MAEErrorBadArguemt,
                              @"arrayTransformerWithModelClass only support to convert between string and MTLModel");
                    *success = NO;
                    return nil;
                }
                id model = [self modelOfClass:modelClass fromString:value error:error];
                *success = model != nil;
                return model;
            }
        reverseBlock:^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
            if (!value) {
                return nil;
            }

            if (!([value isKindOfClass:MTLModel.class] &&
                  [value conformsToProtocol:@protocol(MAEArraySerializing)])) {
                SET_ERROR(error, MAEErrorBadArguemt,
                          @"arrayTransformerWithModelClass only support MAEArraySerializing MTLModel");
                *success = NO;
                return nil;
            }

            NSString* str = [self stringFromModel:value error:error];
            *success = str != nil;
            return str;
        }];
}

+ (NSValueTransformer* _Nonnull)numberStringTransformer
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                NSValueTransformer<MTLTransformerErrorHandling>* transformer
                    = [NSValueTransformer mtl_transformerWithFormatter:[NSNumberFormatter new]
                                                        forObjectClass:NSNumber.class];
                return [transformer transformedValue:value success:success error:error];
            }
        reverseBlock:^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
            if (!value) {
                return nil;
            }
            if (![value isKindOfClass:NSNumber.class]) {
                SET_ERROR(error, MAEErrorBadArguemt,
                          [NSString stringWithFormat:@"Input data expected NSNumber, but got %@", [value class]]);
                *success = NO;
                return nil;
            }
            *success = YES;
            return [(NSNumber*)value stringValue];
        }];
}

+ (NSValueTransformer* _Nonnull)boolStringTransformer
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^NSNumber* _Nullable(id _Nullable str, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {

                if (!str) {
                    return nil;
                }
                if (![str isKindOfClass:NSString.class]) {
                    SET_ERROR(error, MAEErrorBadArguemt,
                              [NSString stringWithFormat:@"Input data expected a numeric string, but got %@.", [str class]]);
                    *success = NO;
                    return nil;
                }

                *success = YES;
                return [NSNumber numberWithBool:[str boolValue]];
            }
        reverseBlock:^NSString* _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
            if (!value) {
                return nil;
            }
            if (![value isKindOfClass:NSNumber.class]) {
                SET_ERROR(error, MAEErrorBadArguemt,
                          [NSString stringWithFormat:@"Input data expected NSNumber, but got %@", [value class]]);
                *success = NO;
                return nil;
            }
            *success = YES;
            return [(NSNumber*)value integerValue] ? @"true" : @"false";
        }];
}

/**
 * It returns transformer for converting between NSString and ObjCType
 *
 * @param type An ObjCType
 * @return If the type does not support, it returns nil. Otherwise, it returns transfomer.
 */
+ (NSValueTransformer* _Nullable)stringTransformerObjCType:
        (const char* _Nonnull)type
{
    if (strcmp(type, @encode(NSUInteger)) == 0
        || strcmp(type, @encode(NSInteger)) == 0
        || strcmp(type, @encode(NSNumber)) == 0
        || strcmp(type, @encode(float)) == 0
        || strcmp(type, @encode(double)) == 0) {
        return [self numberStringTransformer];
    } else if (strcmp(type, @encode(BOOL)) == 0) {
        return [self boolStringTransformer];
    }
    return nil;
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
    if ([self.modelClass respondsToSelector:@selector(classForParsingArray:)]) {
        Class class = [self.modelClass classForParsingArray:separatedStrings];
        if (class == nil) {
            SET_ERROR(error, MAEErrorNoConversionTarget,
                      ([NSString stringWithFormat:@"%@ # classForParsingArray returns nil", self.modelClass]));
            return nil;
        }

        if (class != self.modelClass) {
            NSAssert([class conformsToProtocol:@protocol(MAEArraySerializing)],
                     ([NSString stringWithFormat:@"classForParsingArray MUST return MAEArraySerializing MTLModel class. but got %@", class]));

            MAEArrayAdapter* otherAdapter = [[self.class alloc] initWithModelClass:class];

            // NOTE: If separator is different, it will start over from separate process again.
            if (otherAdapter.separator != self.separator) {
                NSException* exception = [[NSException alloc] initWithName:MAESeparatorChanged
                                                                    reason:nil
                                                                  userInfo:@{ MAEAdapter : otherAdapter }];
                @throw exception;
            }
            return [otherAdapter modelFromSeparatedStrings:separatedStrings error:error];
        }
    }

    NSArray<MAEFragment*>* fragments = [self.class chooseFormatByPropertyKey:self.formatByPropertyKey
                                                                   withCount:separatedStrings.count];
    if (!fragments) {
        SET_ERROR(error, MAEErrorInvalidCount,
                  @"Number of separated strings and format does not match");
        return nil;
    }

    BOOL (^validate)
    (MAEFragment * _Nonnull, MAESeparatedString * _Nonnull)
        = ^BOOL(MAEFragment* _Nonnull f, MAESeparatedString* _Nonnull s) {
              switch (f.type) {
                  case MAEFragmentDoubleQuotedString:
                      if (s.type != MAEStringTypeDoubleQuoted) {
                          SET_ERROR(error, MAEErrorNotQuoted,
                                    [NSString stringWithFormat:@"%@ expected double-quoted-string", f.propertyName]);
                          return NO;
                      }
                      break;
                  case MAEFragmentSingleQuotedString:
                      if (s.type != MAEStringTypeSingleQuoted) {
                          SET_ERROR(error, MAEErrorNotEnum,
                                    [NSString stringWithFormat:@"%@ expected single-quoted-string", f.propertyName]);
                          return NO;
                      }
                      break;
                  case MAEFragmentEnumerateString:
                      if (s.type != MAEStringTypeEnumerate) {
                          SET_ERROR(error, MAEErrorNotEnum,
                                    [NSString stringWithFormat:@"%@ expected enumerate-string", f.propertyName]);
                          return NO;
                      }
                      break;
                  default:
                      break;
              }
              return YES;
          };

    id _Nullable (^transform)(NSString* _Nonnull, id _Nonnull)
        = ^id _Nullable(NSString* _Nonnull propertyName, id _Nonnull value)
    {
        NSValueTransformer* transformer = self.valueTransformersByPropertyKey[propertyName];
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
        return value;
    };

    NSMutableDictionary* dictionaryValue = [NSMutableDictionary dictionaryWithCapacity:fragments.count];
    NSEnumerator* fEnum = fragments.objectEnumerator;
    NSEnumerator* sEnum = separatedStrings.objectEnumerator;

    MAEFragment* f;
    MAESeparatedString* s;
    while ((f = [fEnum nextObject])) {
        id value;

        if (f.isVariadic) {
            NSMutableArray* arr = [NSMutableArray array];
            while ((s = [sEnum nextObject])) {
                if (!validate(f, s)) {
                    return nil;
                }
                [arr addObject:s.characters];
            }
            value = arr;
        } else {
            s = [sEnum nextObject];
            NSAssert(s, @"Incorrect number of elements in separatedString");

            if (!validate(f, s)) {
                return nil;
            }
            value = s.characters;
        }

        value = transform(f.propertyName, value);
        if (!value) {
            return nil;
        }
        dictionaryValue[f.propertyName] = value;
    }
    id model = [self.modelClass modelWithDictionary:dictionaryValue error:error];
    return [model validate:error] ? model : nil;
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
    unichar* chars = malloc(sizeof(unichar) * (string.length + 1));
    [string getCharacters:chars range:NSMakeRange(0, string.length)];
    chars[string.length] = '\0';

    unichar* p = chars;
    __block unichar *start = nil, *end = nil;
    BOOL doubleQuoted = NO, singleQuoted = NO;
    NSMutableArray<MAESeparatedString*>* separatedStrings =
        [NSMutableArray arrayWithCapacity:self.formatByPropertyKey.count];

    void (^append)(unichar* _Nullable, unichar* _Nullable) = ^void(unichar* _Nullable start, unichar* _Nullable end) {
        NSString* str;
        if (start && end) {
            if ((start > chars)
                && ((*(start - 1) == '"' && *end == '"') || (*(start - 1) == '\'' && *end == '\''))) {
                start -= 1;
                end += 1;
            }
            str = [NSString stringWithCharacters:start length:end - start];
        } else {
            str = [NSString string];
        }
        [separatedStrings addObject:[[MAESeparatedString alloc] initWithString:str]];
    };

    for (; *p != '\0'; p++) {
        if (*p == '\\') {
            if (++p == '\0') {
                break;
            }
        } else if (!singleQuoted && !doubleQuoted && *p == self.separator) {
            if (*p == ' ' && !start) {
                if (!self.ignoreEdgeBlank) {
                    append(nil, nil);
                }
            } else {
                append(start, (end ?: p));
                start = end = nil;
            }
        } else if (!singleQuoted && *p == '"') {
            if (doubleQuoted) {
                end = p;
            }
            doubleQuoted = !doubleQuoted;
        } else if (!doubleQuoted && *p == '\'') {
            if (singleQuoted) {
                end = p;
            }
            singleQuoted = !singleQuoted;
        } else if (doubleQuoted || singleQuoted) {
            if (!start) {
                start = p;
            }
            continue;
        } else if (*p == ' ') {
            if (start && self.ignoreEdgeBlank) {
                end = p;
            } else if (!start && !self.ignoreEdgeBlank) {
                start = p;
            }
        } else if (!start) {
            start = p;
        } else {
            end = nil;
        }
    }

    if (start) {
        if (!doubleQuoted && !singleQuoted) {
            append(start, (end ?: p));
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
 *         Otherwise, it returns fragments with unnecessary optional elements
 * removed for the count elements.
 */
+ (NSArray<MAEFragment*>* _Nullable)chooseFormatByPropertyKey:(NSArray<MAEFragment*>* _Nullable)fragments
                                                    withCount:(NSUInteger)count
{
    if (fragments.count == count) {
        return fragments;
    } else if (fragments.count < count) {
        if ([fragments lastObject].variadic) {
            return fragments;
        } else {
            return nil;
        }
    }

    BOOL hasVariadic = NO;
    NSMutableArray<MAEFragment*>* filteredFragments = [fragments mutableCopy];
    for (MAEFragment* fragment in fragments.reverseObjectEnumerator) {
        if (fragment.optional) {
            [filteredFragments removeObject:fragment];
        } else if (fragment.variadic) {
            hasVariadic = YES;
        }

        if (filteredFragments.count - (int)hasVariadic == count) {
            return filteredFragments;
        }
    }
    return nil;
}

/**
 * It returns transformer of all used properties on modelClass.
 *
 * It also solve the default transformer.
 *
 * @param modelClass A modelClass that conforms to MAEArraySerializing
 * @return transformers
 */
+ (NSDictionary* _Nonnull)valueTransformeresForModelClass:(Class _Nonnull)modelClass
{
    NSParameterAssert(modelClass != nil);
    NSParameterAssert([modelClass conformsToProtocol:@protocol(MAEArraySerializing)]);

    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (NSString* propertyKey in [modelClass propertyKeys]) {
        SEL selector = MTLSelectorWithKeyPattern(propertyKey, "ArrayTransformer");
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
            if ([klass conformsToProtocol:@protocol(MAEArraySerializing)]) {
                result[propertyKey] = [self arrayTransformerWithModelClass:klass];
            } else {
                result[propertyKey] = [NSValueTransformer mtl_validatingTransformerForClass:(klass ?: NSObject.class)];
            }
        } else {
            result[propertyKey] = [self stringTransformerObjCType:attributes->type]
                ?: [NSValueTransformer mtl_validatingTransformerForClass:NSValue.class];
        }
        free(attributes);
    }
    return result;
}

@end
