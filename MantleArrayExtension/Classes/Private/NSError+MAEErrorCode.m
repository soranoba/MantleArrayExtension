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
        case MAEErrorInputNil:
            return @"Input is nil";
        case MAEErrorInvalidCount:
            return @"It does not match the number specified by format";
        case MAEErrorNotQuoted:
            return @"Quoted-string is expected, but it differs";
        case MAEErrorNotEnum:
            return @"Enumerate-string is expected, but it differs";
        case MAEErrorTransform:
            return @"The result of transform is incorrect";
        case MAEErrorNoConversionTarget:
            return @"No conversion target. (classForParsingArray: returns nil)";

        case MAEErrorInvalidInputData:
            return @"Transformation failed, because input data is invalid";
        default:
            return @"Unknown error";
    }
}

@end
