//
//  MAEFragment.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEFragment.h"
#import "NSError+MAEErrorCode.h"

@interface MAEFragment ()
@property (nonatomic, nonnull, copy, readwrite) NSString* propertyName;
@property (nonatomic, assign, readwrite) MAEFragmentType type;
@property (nonatomic, assign, readwrite) BOOL optional;
@property (nonatomic, assign, readwrite) BOOL variadic;
@end

#pragma mark - Syntax Suger

static inline MAEFragment* _Nonnull makeFragment(id _Nonnull v)
{
    MAEFragment* fragment;
    if ([v conformsToProtocol:@protocol(MAEFragment)]) {
        fragment = v;
    } else {
        NSCAssert([v isKindOfClass:NSString.class],
                  @"It only allow NSString and id<MAEFramgnet>, but got %@", [v class]);
        fragment = [[MAEFragment alloc] initWithPropertyName:v];
    }
    return fragment;
}

extern MAEFragment* _Nonnull MAEQuoted(NSString* _Nonnull propertyName)
{
    MAEFragment* fragment = [[MAEFragment alloc] initWithPropertyName:propertyName];
    fragment.type = MAEFragmentDoubleQuotedString;
    return fragment;
}

extern MAEFragment* _Nonnull MAESingleQuoted(NSString* _Nonnull propertyName)
{
    MAEFragment* fragment = [[MAEFragment alloc] initWithPropertyName:propertyName];
    fragment.type = MAEFragmentSingleQuotedString;
    return fragment;
}

extern MAEFragment* _Nonnull MAEEnum(NSString* _Nonnull propertyName)
{
    MAEFragment* fragment = [[MAEFragment alloc] initWithPropertyName:propertyName];
    fragment.type = MAEFragmentEnumerateString;
    return fragment;
}

extern id<MAEFragment> _Nonnull MAEOptional(id _Nonnull v)
{
    MAEFragment* fragment = makeFragment(v);
    NSCAssert([fragment respondsToSelector:@selector(setOptional:)],
              format(@"%@ does not support optional", v));
    fragment.optional = YES;
    return fragment;
}

extern id<MAEFragment> _Nonnull MAEVariadic(id _Nonnull v)
{
    MAEFragment* fragment = makeFragment(v);
    NSCAssert([fragment respondsToSelector:@selector(setVariadic:)],
              format(@"%@ does not support variadic", v));
    fragment.variadic = YES;
    return fragment;
}

@implementation MAEFragment

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    NSAssert(NO, @"%@ MUST be initialized with designated initializer", self.class);
    return nil;
}

- (instancetype _Nonnull)initWithPropertyName:(NSString* _Nonnull)propertyName
{
    NSParameterAssert(propertyName != nil);

    if (self = [super init]) {
        self.propertyName = propertyName;
    }
    return self;
}

#pragma mark - MAEFragment

- (BOOL)validateWithSeparatedString:(MAESeparatedString* _Nonnull)separatedString
                              error:(NSError* _Nullable* _Nullable)error
{
    NSParameterAssert(separatedString != nil);

    NSString* expectedType = nil;
    switch (self.type) {
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
                         format(@"%@ expected %@", self.propertyName, expectedType) });
        return NO;
    }
    return YES;
}

- (MAESeparatedString* _Nullable)separatedStringFromTransformedValue:(NSString* _Nullable)transformedValue
                                                               error:(NSError* _Nullable* _Nullable)error
{
    if (!transformedValue) {
        transformedValue = @"";
    }

    MAEStringType type;
    switch (self.type) {
        case MAEFragmentDoubleQuotedString:
            type = MAEStringTypeDoubleQuoted;
            break;
        case MAEFragmentSingleQuotedString:
            type = MAEStringTypeSingleQuoted;
            break;
        case MAEFragmentMaybeQuotedString:
            type = (transformedValue.length > 0 && [transformedValue rangeOfString:@" "].location == NSNotFound)
                ? MAEStringTypeEnumerate
                : MAEStringTypeDoubleQuoted;
            break;
        default:
            type = MAEStringTypeEnumerate;
            break;
    }
    return [[MAESeparatedString alloc] initWithCharacters:transformedValue type:type];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone* _Nullable)zone
{
    return self;
}

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    char type = ' ';
    switch (self.type) {
        case MAEFragmentEnumerateString:
            type = 'E';
            break;
        case MAEFragmentDoubleQuotedString:
            type = 'D';
            break;
        case MAEFragmentSingleQuotedString:
            type = 'S';
            break;
        default:
            type = '-';
    }

    return format(@"<%@: %@ :%c%c%c>", self.class, self.propertyName, type,
                  (self.optional ? 'O' : '-'), (self.variadic ? 'V' : '-'));
}

@end
