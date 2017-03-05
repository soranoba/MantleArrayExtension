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
    MAEErrorBadArguemt,
    MAEErrorInputNil,
    MAEErrorInvalidCount,
    MAEErrorNotQuoted,
    MAEErrorNotEnum,
    MAEErrorTransform,
    MAEErrorNoConversionTarget,

    /// There was an input data that is different from the expected type.
    MAEErrorInvalidInputData,
};

/// The domain for errors originating from MantleArrayExtension
extern NSString* const MAEErrorDomain;
/// A key that stores the input data that caused the error
extern NSString* const MAEErrorInputDataKey;
