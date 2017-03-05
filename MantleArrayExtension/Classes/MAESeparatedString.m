//
//  MAESeparatedString.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAESeparatedString.h"

@interface MAESeparatedString ()
@property (nonatomic, nonnull, copy, readwrite) NSString* originalCharacters;
@property (nonatomic, nonnull, copy, readwrite) NSString* characters;
@property (nonatomic, assign, readwrite) MAEStringType type;
@end

@implementation MAESeparatedString

#pragma mark - Lifecycle

- (instancetype _Nonnull)initWithCharacters:(NSString* _Nonnull)characters
                                       type:(MAEStringType)type
{
    NSParameterAssert(characters != nil);

    if (self = [super init]) {
        self.characters = characters;
        self.type = type;
        self.originalCharacters = [self.class stringFromCharacters:characters withType:type];
    }
    return self;
}

- (instancetype _Nonnull)initWithOriginalCharacters:(NSString* _Nonnull)originalCharacters
                                    ignoreEdgeBlank:(BOOL)ignoreEdgeBlank
{
    NSParameterAssert(originalCharacters != nil);

    if (self = [super init]) {
        self.originalCharacters = originalCharacters;

        NSString* characters;
        if (ignoreEdgeBlank) {
            NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
            characters = [originalCharacters stringByTrimmingCharactersInSet:characterSet];
        } else {
            characters = originalCharacters;
        }

        if (characters.length >= 2 && [characters hasPrefix:@"\""] & [characters hasSuffix:@"\""]) {
            characters = [characters substringWithRange:NSMakeRange(1, characters.length - 2)];
            characters = [characters stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
            self.type = MAEStringTypeDoubleQuoted;
        } else if (characters.length >= 2 && [characters hasPrefix:@"'"] & [characters hasSuffix:@"'"]) {
            characters = [characters substringWithRange:NSMakeRange(1, characters.length - 2)];
            characters = [characters stringByReplacingOccurrencesOfString:@"\'" withString:@"'"];
            self.type = MAEStringTypeSingleQuoted;
        } else {
            self.type = MAEStringTypeEnumerate;
        }
        self.characters = characters;
    }
    return self;
}

#pragma mark - Public Methods

+ (NSString* _Nonnull)stringFromCharacters:(NSString* _Nonnull)characters
                                  withType:(MAEStringType)type
{
    NSParameterAssert(characters != nil);

    switch (type) {
        case MAEStringTypeDoubleQuoted: {
            NSString* string = [characters stringByReplacingOccurrencesOfString:@"\""
                                                                     withString:@"\\\""];
            return [NSString stringWithFormat:@"\"%@\"", string];
        }
        case MAEStringTypeSingleQuoted: {
            NSString* string = [characters stringByReplacingOccurrencesOfString:@"'"
                                                                     withString:@"\\'"];
            return [NSString stringWithFormat:@"'%@'", string];
        }
        default:
            return characters;
    }
}

#pragma mark - NSObject (Override)

- (BOOL)isEqual:(id _Nullable)object
{
    if ([object isKindOfClass:NSString.class]) {
        return [self isEqual:[[self.class alloc] initWithOriginalCharacters:object ignoreEdgeBlank:NO]];
    } else if ([object isKindOfClass:MAESeparatedString.class]) {
        MAESeparatedString* other = object;
        return self.type == other.type && [self.characters isEqualToString:other.characters];
    }
    return NO;
}

- (NSString* _Nonnull)description
{
    return [self.class stringFromCharacters:self.characters withType:self.type];
}

@end
