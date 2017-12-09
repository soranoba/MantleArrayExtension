//
//  MAEFragment.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAESeparatedString.h"
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

@protocol MAEFragment;
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
id<MAEFragment> _Nonnull MAEOptional(id _Nonnull);

/**
 * A fragment that means to group from this position as one array.
 *
 * usage:
 *    - MAEVariadic(@"propertyName")
 *    - MAEVariadic(MAEQuoted(@"propertyName"))
 *    - MAEVariadic(MAEEnum(@"propertyName"))
 */
id<MAEFragment> _Nonnull MAEVariadic(id _Nonnull);

@protocol MAEFragment <NSObject>

// It returns that name, if it have corresponding property
@property (nonatomic, nullable, copy, readonly) NSString* propertyName;
// If it is optional element, it returns YES. Otherwise, it returns NO.
@property (nonatomic, assign, readonly, getter=isOptional) BOOL optional;
// If it is variadic elements, it returns YES. Otherwise, it returns NO.
@property (nonatomic, assign, readonly, getter=isVariadic) BOOL variadic;

/**
 * Returns whether separatedString is in correct format.
 *
 * @param separatedString  A corresponding string
 * @param error            If it return nil, an error information is saved here.
 * @return Returns YES, if the separatedString is correct. Otherwise, it returns NO.
 */
- (BOOL)validateWithSeparatedString:(MAESeparatedString* _Nonnull)separatedString
                              error:(NSError* _Nullable* _Nullable)error;

/**
 * It convert separatedString from transformedValue.
 *
 *
 */
- (MAESeparatedString* _Nullable)separatedStringFromTransformedValue:(NSString* _Nonnull)transformedValue
                                                               error:(NSError* _Nullable* _Nullable)error;

@optional

/**
 * You should implements, if it support optional.
 *
 * @param optional  The value of optional to be set.
 */
- (void)setOptional:(BOOL)optional;

/**
 * You should implements, if it support variadic.
 *
 * @param variadic  The value of variadic to be set.
 */
- (void)setVariadic:(BOOL)variadic;

@end

/**
 * A Class is the simplest MAEFragment
 * It use to define a value corresponding to one property.
 */
@interface MAEFragment : NSObject <MAEFragment>

@property (nonatomic, assign, readonly) MAEFragmentType type;

#pragma mark - Lifecycle

/**
 * Create an instance
 *
 * @param propertyName   A property name
 * @return An instance
 */
- (instancetype _Nonnull)initWithPropertyName:(NSString* _Nonnull)propertyName;

@end
