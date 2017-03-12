//
//  MAEFragment.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEFragment.h"

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
    if ([v isKindOfClass:MAEFragment.class]) {
        fragment = v;
    } else {
        NSCAssert([v isKindOfClass:NSString.class],
                  @"It only allow NSString and MAEFramgnet, but got %@", [v class]);
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

extern MAEFragment* _Nonnull MAEOptional(id _Nonnull v)
{
    MAEFragment* fragment = makeFragment(v);
    fragment.optional = YES;
    return fragment;
}

extern MAEFragment* _Nonnull MAEVariadic(id _Nonnull v)
{
    MAEFragment* fragment = makeFragment(v);
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

#pragma mark - NSObject (Override)

- (BOOL)isEqual:(id _Nullable)other
{
    if ([other isKindOfClass:MAEFragment.class]) {
        typeof(self) otherFragment = other;
        return [otherFragment.propertyName isEqual:self.propertyName]
            && otherFragment.type == self.type
            && otherFragment.optional == self.optional
            && otherFragment.variadic == self.variadic;
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.propertyName hash];
}

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

    return [NSString stringWithFormat:@"<%@: %@ :%c%c%c>",
                                      self.class, self.propertyName, type,
                                      (self.optional ? 'O' : '-'), (self.variadic ? 'V' : '-')];
}

@end
