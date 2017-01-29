//
//  MAEFragment.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Type of string
 */
typedef NS_ENUM(NSUInteger, MAEFragmentType) {
    /// Allow both 'sigle-quoted-string', "double-quoted-string" and enumulate-string
    MAEFragmentMaybeQuotedString = 0,
    /// Must be "double-quoted-string"
    MAEFragmentDoubleQuotedString,
    /// Must be 'single-quoted-string'
    MAEFragmentSingleQuotedString,
    /// Must be enumerate-string
    MAEFragmentEnumerateString,
};

@class MAEFragment;

/**
 * A double-quoted-string fragment
 *
 * usage:
 *    -  MAEQuoted(@"propertyName")
 */
MAEFragment* _Nonnull MAEQuoted(NSString* _Nonnull);

/**
 * A single-quoted-string fragment
 *
 * usage:
 *    -  MAESignleQuoted(@"propertyName")
 */
MAEFragment* _Nonnull MAESingleQuoted(NSString* _Nonnull);

/**
 * A maybe enumerate-string fragment
 * Enumerate-string means string that MUST NOT be enclosed with quoted.
 *
 * usage:
 *    - MAEEnum(@"propertyName")
 */
MAEFragment* _Nonnull MAEEnum(NSString* _Nonnull);

/**
 * An optional fragment
 *
 * usage:
 *    - MAEOptional(@"propertyName")
 *    - MAEOptional(MAEQuoted(@"proeprtyName"))
 */
MAEFragment* _Nonnull MAEOptional(id _Nonnull);

/**
 * A fragment that means to group from this position as one array.
 *
 * usage:
 *    - MAEVariadic(@"propertyName")
 *    - MAEVariadic(MAEQuoted(@"propertyName"))
 *    - MAEVariadic(MAEEnum(@"propertyName"))
 */
MAEFragment* _Nonnull MAEVariadic(id _Nonnull);

@interface MAEFragment : NSObject

@property (nonatomic, nonnull, copy, readonly) NSString* propertyName;
@property (nonatomic, assign, readonly) MAEFragmentType type;
@property (nonatomic, assign, readonly, getter=isOptional) BOOL optional;
@property (nonatomic, assign, readonly, getter=isVariadic) BOOL variadic;

#pragma mark - Lifecycle

/**
 * Create an instance
 *
 * @param propertyName A property name
 * @return An instance
 */
- (instancetype _Nonnull)initWithPropertyName:(NSString* _Nonnull)propertyName;

@end
