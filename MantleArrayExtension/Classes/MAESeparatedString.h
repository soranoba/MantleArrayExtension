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

/**
 * The class represent one of characters separated by separator.
 */
@interface MAESeparatedString : NSObject

/// The original characters sometimes contains some spaces and quotes.
@property (nonatomic, nonnull, copy, readonly) NSString* originalCharacters;
/// The characters has already removed prefix and suffix spaces and quotes.
@property (nonatomic, nonnull, copy, readonly) NSString* characters;
/// The type of string.
@property (nonatomic, assign, readonly) MAEStringType type;

#pragma mark - Lifecycle

/**
 * Specify a type and create an instance.
 * If you want to create an instance with quoted-string, the characters MUST be removed prefix and suffix quotes.
 *
 * @param characters   A string without quotes.
 * @param type         A type of string.
 * @return An instance
 */
- (instancetype _Nonnull)initWithCharacters:(NSString* _Nonnull)characters
                                       type:(MAEStringType)type;

/**
 * Create an instance with an original characters.
 *
 * @param originalCharacters  An originalCharacters. Please refer to property with the same name.
 * @param ignoreEdgeBlank     If it is YES, prefix and suffix spaces will remove.
 * @return An instance
 */
- (instancetype _Nonnull)initWithOriginalCharacters:(NSString* _Nonnull)originalCharacters
                                    ignoreEdgeBlank:(BOOL)ignoreEdgeBlank;

#pragma mark - Public Methods

/**
 * Create a string from unquoted-string with type.
 *
 * @param characters   An unquoted-string. Please refer to MAESeparatedString # characters.
 * @param type         A type of string.
 * @return A created string.
 */
+ (NSString* _Nonnull)stringFromCharacters:(NSString* _Nonnull)characters
                                  withType:(MAEStringType)type;

@end

@interface MAESeparatedString (Deprecated)

- (instancetype _Nonnull)initWithString:(NSString* _Nonnull)string
    __attribute__((unavailable("Replaced by initWithOriginalCharacters:ignoreEdgeBlank:")));
- (NSString* _Nonnull)toString
    __attribute__((unavailable("Replaced by +stringFromCharacters:withType:")));

@end
