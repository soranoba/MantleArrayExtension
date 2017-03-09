//
//  NSError+MAEErrorCode.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/28.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "NSError+MAEErrorCode.h"

NSString* _Nonnull const MAEErrorDomain = @"MAEErrorDomain";
NSString* _Nonnull const MAEErrorInputDataKey = @"MAEErrorInputDataKey";

@implementation NSError (MAEErrorCode)

#pragma mark - Lifecycle

+ (instancetype _Nonnull)mae_errorWithMAEErrorCode:(MAEErrorCode)code
{
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : [self mae_description:code] };
    return [NSError errorWithDomain:MAEErrorDomain code:code userInfo:userInfo];
}

+ (instancetype _Nonnull)mae_errorWithMAEErrorCode:(MAEErrorCode)code
                                          userInfo:(NSDictionary* _Nullable)userInfo
{
    if (userInfo) {
        NSMutableDictionary* mutableUserInfo = [userInfo mutableCopy];
        mutableUserInfo[NSLocalizedDescriptionKey] = [self mae_description:code];
        userInfo = mutableUserInfo;
    }
    return [NSError errorWithDomain:MAEErrorDomain code:code userInfo:userInfo];
}

#pragma mark - Private Methods

/**
 * Return a LocalizedDescription.
 *
 * @param code   An error code
 * @return A description string
 */
+ (NSString* _Nonnull)mae_description:(MAEErrorCode)code
{
    switch (code) {
        case MAEErrorNilInputData:
            return @"Could not conversion, because nil was inputted";
        case MAEErrorInvalidInputData:
            return @"Transformation failed, because input data is invalid";
        case MAEErrorNotMatchFragmentType:
            return @"It does not match fragment type";
        case MAEErrorNotMatchFragmentCount:
            return @"The number of fragments is not allowed in format";
        case MAEErrorNoConversionTarget:
            return @"There is no target to convert";
        default:
            return @"Unknown error";
    }
}

@end
