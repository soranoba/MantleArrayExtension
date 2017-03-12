//
//  NSArray+MAESeparatedString.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/03/05.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAESeparatedString.h"
#import "NSArray+MAESeparatedString.h"

@implementation NSArray (MAESeparatedString)

#pragma mark - Public Methods

- (NSString* _Nonnull)mae_componentsJoinedBySeparatedString:(unichar)separator
{
    NSString* separatorStr = [[NSString alloc] initWithCharacters:&separator length:1];
    NSMutableString* result = [NSMutableString string];
    for (MAESeparatedString* separatedString in self) {
        if (![separatedString isKindOfClass:MAESeparatedString.class]) {
            NSAssert(NO, @"It only support MAESeparatedString, but got %@", separatedString.class);
            continue;
        }

        if (result.length != 0) {
            [result appendString:separatorStr];
        }
        [result appendString:separatedString.originalCharacters];
    }
    return result;
}

@end
