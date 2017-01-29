//
//  NSError+MAEErrorCode.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/28.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEErrorCode.h"
#import <Foundation/Foundation.h>

@interface NSError (MAEErrorCode)

#pragma mark - Lifecycle

/**
 * Create NSError with error code
 *
 * @param code Error code
 * @return instance
 */
+ (instancetype _Nonnull)mae_errorWithMAEErrorCode:(MAEErrorCode)code;

/**
 * Create NSError with error code and reason
 *
 * @param code   Error code
 * @param reason Error reason
 * @return instance
 */
+ (instancetype _Nonnull)mae_errorWithMAEErrorCode:(MAEErrorCode)code
                                            reason:(NSString* _Nonnull)reason;

@end

static inline void SET_ERROR(NSError* _Nullable* _Nullable error, MAEErrorCode code, NSString* _Nonnull reason)
{
    if (error) {
        *error = [NSError mae_errorWithMAEErrorCode:code reason:reason];
    }
}
