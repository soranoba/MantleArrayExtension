//
//  MAESeparatedString.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MAEStringType) {
    MAEStringTypeDoubleQuoted,
    MAEStringTypeSingleQuoted,
    MAEStringTypeEnumerate,
};

@interface MAESeparatedString : NSObject

@property (nonatomic, nonnull, copy, readonly) NSString* characters;
@property (nonatomic, assign, readonly) MAEStringType type;

#pragma mark - Lifecycle

/**
 * Specify a type and create an instance.
 * If you want to create an instance with quoted-string, the characters MUST be removed prefix and suffix double-quoted.
 *
 * @param characters A string without quoted.
 * @param type       A string type.
 * @return An instance
 */
- (instancetype _Nonnull)initWithCharacters:(NSString* _Nonnull)characters
                                       type:(MAEStringType)type;

/**
 * Create an instance after judging whether the string is quoted-string.
 *
 * @param string  A string
 * @return An instance
 */
- (instancetype _Nonnull)initWithString:(NSString* _Nonnull)string;

/**
 * Convert to string from instance
 *
 * @return string
 */
- (NSString* _Nonnull)toString;

@end
