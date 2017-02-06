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

@property (nonatomic, nonnull, copy, readonly) NSString* v;
@property (nonatomic, assign, readonly) MAEStringType type;

#pragma mark - Lifecycle

/**
 * Create an instance
 *
 * @param v      A string processed double-quote.
 * @param type   A string type.
 * @return An instance
 */
- (instancetype _Nonnull)initWithValue:(NSString* _Nonnull)v
                                  type:(MAEStringType)type;

/**
 * Create an instance from string
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
