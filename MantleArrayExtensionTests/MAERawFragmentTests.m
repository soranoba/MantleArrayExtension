//
//  MAERawFragmentTests.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/12/09.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEErrorCode.h"
#import "MAERawFragment.h"

QuickSpecBegin(MAERawFragmentTests)
{
    describe(@"initialize", ^{
        it(@"returns a fragment that set single rawString using MAERaw", ^{
            MAERawFragment* fragment = MAERaw(@"raw");

            expect(fragment.propertyName).to(beNil());
            expect(fragment.rawStrings).to(equal(@[ @"raw" ]));
            expect(fragment.isOptional).to(beFalse());
            expect(fragment.isVariadic).to(beFalse());
        });

        it(@"returns a fragment that set multiple rawStrings using MAERawEither", ^{
            MAERawFragment* fragment = MAERawEither(@[ @"a", @"b" ]);

            expect(fragment.propertyName).to(beNil());
            expect(fragment.rawStrings).to(equal(@[ @"a", @"b" ]));
            expect(fragment.isOptional).to(beFalse());
            expect(fragment.isVariadic).to(beFalse());
        });

        it(@"can optional", ^{
            MAERawFragment* fragment = MAEOptional(MAERaw(@"raw"));

            expect(fragment.isOptional).to(beTrue());
        });

        it(@"can variadic", ^{
            MAERawFragment* fragment = MAEVariadic(MAERaw(@"raw"));

            expect(fragment.isVariadic).to(beTrue());
        });

        it(@"can set propertyName", ^{
            MAERawFragment* fragment = MAERaw(@"raw").withProperty(@"propertyName");

            expect(fragment.propertyName).to(equal(@"propertyName"));
        });
    });

    describe(@"separatedStringFromTransformedValue:error:", ^{
        MAERawFragment* fragment = MAERawEither(@[ @"a", @"\"b\"" ]);

        it(@"returns matched one", ^{
            __block NSError* error = nil;
            expect([fragment separatedStringFromTransformedValue:@"a" error:&error]).to(equal(@"a"));
            expect(error).to(beNil());
        });

        it(@"returns matched one, when a candidate is quoted-string", ^{
            __block NSError* error = nil;
            MAESeparatedString* s = [fragment separatedStringFromTransformedValue:@"\"b\"" error:&error];
            expect(s).to(equal(@"b"));
            expect([s isEqualToSeparatedString:[[MAESeparatedString alloc] initWithCharacters:@"b"
                                                                                         type:MAEStringTypeDoubleQuoted]])
                .to(beTrue());
            expect(error).to(beNil());
        });

        it(@"returns nil, if it does not match any of candidate", ^{
            __block NSError* error = nil;
            expect([fragment separatedStringFromTransformedValue:@"hoge" error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
        });

        it(@"returns first one, when transformedValue is nil", ^{
            __block NSError* error = nil;
            expect([fragment separatedStringFromTransformedValue:nil error:&error])
                .to(equal(fragment.rawStrings.firstObject));
            expect(error).to(beNil());
        });
    });

    describe(@"validateWithSeparatedString:error:", ^{
        MAERawFragment* fragment = MAERawEither(@[ @"a", @"\"b\"" ]);

        it(@"returns YES, if separatedString is one of candidates", ^{
            __block NSError* error = nil;
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"a" ignoreEdgeBlank:NO];
            expect([fragment validateWithSeparatedString:s error:&error]).to(beTrue());
            expect(error).to(beNil());
        });

        it(@"returns NO, if separatedString is missing double-quotes", ^{
            __block NSError* error = nil;
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithCharacters:@"b" type:MAEStringTypeEnumerate];
            expect([fragment validateWithSeparatedString:s error:&error]).to(beFalse());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
        });

        it(@"returns YES, when the candidate is double-quoted string", ^{
            __block NSError* error = nil;
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithCharacters:@"b" type:MAEStringTypeDoubleQuoted];
            expect([fragment validateWithSeparatedString:s error:&error]).to(beTrue());
            expect(error).to(beNil());
        });
    });

    describe(@"description", ^{
        it(@"returns expectig one", ^{
            expect(MAERawEither(@[ @"value1", @"value2" ]).withProperty(@"name").description)
                .to(equal(@"<MAERawFragment : candidates=(value1,value2), property=name>"));
        });
    });
}
QuickSpecEnd
