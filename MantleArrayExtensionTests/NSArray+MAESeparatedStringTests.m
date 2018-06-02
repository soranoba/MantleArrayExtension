//
//  NSArray+MAESeparatedStringTests.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/03/05.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAESeparatedString.h"
#import "NSArray+MAESeparatedString.h"

QuickSpecBegin(NSArray_MAESeparatedStringTests)
{
    describe(@"mae_componentsJoinedBySeparatedString:", ^{
        it(@"throws an exception if there is any other than MAESeparatedString", ^{
            NSArray* array
                = @[ [[MAESeparatedString alloc] initWithOriginalCharacters:@"  \"hoge\"  " ignoreEdgeBlank:YES],
                     @"fuga" ];
            expectAction(^{
                [array mae_componentsJoinedBySeparatedString:' '];
            }).to(raiseException());
        });

        it(@"returns joined string", ^{
            NSArray<MAESeparatedString*>* array
                = @[ [[MAESeparatedString alloc] initWithOriginalCharacters:@"  \"hoge\"  " ignoreEdgeBlank:YES],
                     [[MAESeparatedString alloc] initWithOriginalCharacters:@"  'fuga'  "
                                                            ignoreEdgeBlank:YES] ];
            expect([array mae_componentsJoinedBySeparatedString:',']).to(equal(@"  \"hoge\"  ,  'fuga'  "));
        });

        it(@"returns empty string, if input array is empty", ^{
            expect([@[] mae_componentsJoinedBySeparatedString:',']).to(equal(@""));
        });
    });
}
QuickSpecEnd
