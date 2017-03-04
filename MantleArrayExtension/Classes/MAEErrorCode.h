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
};

extern NSString* const MAEErrorDomain;
