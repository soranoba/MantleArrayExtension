//
//  NSArray+MAESeparatedString.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/03/05.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MAESeparatedString)

#pragma mark - Public Methods

/**
 * It returns string joined by the separator using originalCharacters.
 *
 * @param separator   A separator
 * @return A joined string
 */
- (NSString* _Nonnull)mae_componentsJoinedBySeparatedString:(unichar)separator;

@end
