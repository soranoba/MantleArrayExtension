//
//  NSError+MAEErrorCode.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/28.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEErrorCode.h"
#import <Foundation/Foundation.h>

#define format(...) ([NSString stringWithFormat:__VA_ARGS__])

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
 * @param code      Error code
 * @param userInfo  An userInfo excluding LocalizedDescription. LocalizedDescription will be added automatically.
 * @return instance
 */
+ (instancetype _Nonnull)mae_errorWithMAEErrorCode:(MAEErrorCode)code
                                          userInfo:(NSDictionary* _Nullable)userInfo;

@end

static inline void SET_ERROR(NSError* _Nullable* _Nullable error, MAEErrorCode code, NSDictionary* _Nullable userInfo)
{
    if (error) {
        *error = [NSError mae_errorWithMAEErrorCode:code userInfo:userInfo];
    }
}
