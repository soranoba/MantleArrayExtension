//
//  MAERawFragment.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/12/09.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEFragment.h"
#import <Foundation/Foundation.h>

@class MAERawFragment;

/**
 * A raw string fragment.
 *
 * usage:
 *    - MAERaw(@"rawString")
 *    - MAERaw(@"rawString").withProperty(@"propertyName")
 *    - MAEOptional(MAERaw(@"rawString"))
 */
MAERawFragment* _Nonnull MAERaw(NSString* _Nonnull);

/**
 * An either of raw strings fragment.
 *
 * usage:
 *    - MAERawEither(@[@"play", @"pause"])
 *    - MAERawEither(@[@"play", @"pause"]).withProperty(@"propertyName")
 *    - MAEOptional(MAERawEither(@[@"play", @"pause"]))
 */
MAERawFragment* _Nonnull MAERawEither(NSArray<NSString*>* _Nonnull);

/**
 * A fragment expecting that it is the specified character string.
 * It can not correspond to property.
 */
@interface MAERawFragment : NSObject <MAEFragment>

/// Candidates for raw string.
@property (nonatomic, nonnull, copy, readonly) NSArray<NSString*>* candidates;

#pragma mark - Lifecycle

/**
 * Create an instance
 *
 * @param candidates     Candidates for raw string.
 * @return An instance
 */
- (instancetype _Nonnull)initWithCandidates:(NSArray<NSString*>* _Nonnull)candidates;

#pragma mark - Public Methods

/**
 * Returns a block to set property
 *
 * @return A block to set property
 */
- (MAERawFragment* _Nonnull (^_Nonnull)(NSString* _Nullable propertyName))withProperty;

@end
