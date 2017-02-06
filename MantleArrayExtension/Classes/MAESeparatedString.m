//
//  MAESeparatedString.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAESeparatedString.h"

@interface MAESeparatedString ()
@property (nonatomic, nonnull, copy, readwrite) NSString* characters;
@property (nonatomic, assign, readwrite) MAEStringType type;
@end

@implementation MAESeparatedString

- (instancetype _Nonnull)initWithCharacters:(NSString* _Nonnull)characters
                                       type:(MAEStringType)type
{
    NSParameterAssert(characters != nil);

    if (self = [super init]) {
        self.characters = characters;
        self.type = type;
    }
    return self;
}

- (instancetype _Nonnull)initWithString:(NSString* _Nonnull)string
{
    NSParameterAssert(string != nil);
    if (string.length >= 2 && [string hasPrefix:@"\""] & [string hasSuffix:@"\""]) {
        string = [string substringWithRange:NSMakeRange(1, string.length - 2)];
        string = [string stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        return [self initWithCharacters:string type:MAEStringTypeDoubleQuoted];
    } else if (string.length >= 2 && [string hasPrefix:@"'"] & [string hasSuffix:@"'"]) {
        string = [string substringWithRange:NSMakeRange(1, string.length - 2)];
        string = [string stringByReplacingOccurrencesOfString:@"\'" withString:@"'"];
        return [self initWithCharacters:string type:MAEStringTypeSingleQuoted];
    }
    return [self initWithCharacters:string type:MAEStringTypeEnumerate];
}

- (NSString* _Nonnull)toString
{
    switch (self.type) {
        case MAEStringTypeDoubleQuoted: {
            NSString* string = [self.characters stringByReplacingOccurrencesOfString:@"\""
                                                                          withString:@"\\\""];
            return [NSString stringWithFormat:@"\"%@\"", string];
            break;
        }
        case MAEStringTypeSingleQuoted: {
            NSString* string = [self.characters stringByReplacingOccurrencesOfString:@"'"
                                                                          withString:@"\\'"];
            return [NSString stringWithFormat:@"'%@'", string];
            break;
        }
        default:
            break;
    }
    return self.characters;
}

#pragma mark - NSObject (Override)

- (BOOL)isEqual:(id _Nullable)object
{
    if ([object isKindOfClass:NSString.class]) {
        return [self isEqual:[[self.class alloc] initWithString:object]];
    } else if ([object isKindOfClass:MAESeparatedString.class]) {
        MAESeparatedString* other = object;
        return self.type == other.type && [self.characters isEqualToString:other.characters];
    }
    return NO;
}

- (NSString* _Nonnull)description
{
    return [self toString];
}

@end
