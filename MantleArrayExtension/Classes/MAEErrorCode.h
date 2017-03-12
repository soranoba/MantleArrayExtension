//
//  MAEErrorCode.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/28.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MAEErrorCode) {
    MAEErrorUnknown,
    /// Could not conversion, because nil was inputted.
    MAEErrorNilInputData,
    /// There was an input data that is different from the expected type.
    MAEErrorInvalidInputData,
    /// It does not match fragment type
    MAEErrorNotMatchFragmentType,
    /// The number of fragments is not allowed in format
    MAEErrorNotMatchFragmentCount,
    /// classForParsingArray: returns nil.
    MAEErrorNoConversionTarget,

    MAEErrorInputNil __attribute__((unavailable("Replaced by MAEErrorNilInputData"))),
    MAEErrorTransform __attribute__((unavailable("Replaced by MAEErrorInvalidInputData"))),
    MAEErrorBadArguemt __attribute__((unavailable("Replaced by MAEErrorInvalidInputData"))),
    MAEErrorNotQuoted __attribute__((unavailable("Replaced by MAEErrorNotMatchFragmentType"))),
    MAEErrorNotEnum __attribute__((unavailable("Replaced by MAEErrorNotMatchFragmentType"))),
    MAEErrorInvalidCount __attribute__((unavailable("Replaced by MAEErrorNotMatchFragmentCount"))),
};

/// The domain for errors originating from MantleArrayExtension
extern NSString* const MAEErrorDomain;
/// A key that stores the input data that caused the error
extern NSString* const MAEErrorInputDataKey;
