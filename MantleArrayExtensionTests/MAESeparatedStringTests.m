//
//  MAESeparatedStringTests.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAESeparatedString.h"

QuickSpecBegin(MAESeparatedStringTests)
{
    describe(@"initializer", ^{
        it(@"can discrimination the quoted string and initialize", ^{
            __block MAESeparatedString* s;
            expect(s = [[MAESeparatedString alloc] initWithString:@"\"hoge\""]).notTo(beNil());
            expect(s.characters).to(equal(@"hoge"));
            expect(@(s.type)).to(equal(MAEStringTypeDoubleQuoted));

            expect(s = [[MAESeparatedString alloc] initWithString:@"'hoge'"]).notTo(beNil());
            expect(s.characters).to(equal(@"hoge"));
            expect(@(s.type)).to(equal(MAEStringTypeSingleQuoted));

            expect(s = [[MAESeparatedString alloc] initWithString:@"\"\""]).notTo(beNil());
            expect(s.characters).to(equal(@""));
            expect(@(s.type)).to(equal(MAEStringTypeDoubleQuoted));

            expect(s = [[MAESeparatedString alloc] initWithString:@"''"]).notTo(beNil());
            expect(s.characters).to(equal(@""));
            expect(@(s.type)).to(equal(MAEStringTypeSingleQuoted));
        });

        it(@"judge unbalanced quoted as not quoted-string", ^{
            __block MAESeparatedString* s;
            expect(s = [[MAESeparatedString alloc] initWithString:@"\"hoge"]).notTo(beNil());
            expect(s.characters).to(equal(@"\"hoge"));
            expect(@(s.type)).to(equal(MAEStringTypeEnumerate));
        });

        it(@"maintain double quote that exist on the way", ^{
            __block MAESeparatedString* s;
            expect(s = [[MAESeparatedString alloc] initWithString:@"\"hoge \"fugo"]).notTo(beNil());
            expect(s.characters).to(equal(@"\"hoge \"fugo"));
            expect(@(s.type)).to(equal(MAEStringTypeEnumerate));
        });
    });

    describe(@"isEqual:", ^{
        it(@"can compare NSString and MAESeparatedString", ^{
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithCharacters:@"hoge"
                                                                              type:MAEStringTypeDoubleQuoted];
            expect(s).to(equal(@"\"hoge\""));
            expect(s).notTo(equal(@"hoge"));

            s = [[MAESeparatedString alloc] initWithCharacters:@"hoge"
                                                          type:MAEStringTypeSingleQuoted];
            expect(s).to(equal(@"'hoge'"));
            expect(s).notTo(equal(@"hoge"));

            s = [[MAESeparatedString alloc] initWithCharacters:@"hoge"
                                                          type:MAEStringTypeEnumerate];
            expect(s).to(equal(@"hoge"));
            expect(s).notTo(equal(@"\"hoge\""));

            s = [[MAESeparatedString alloc] initWithCharacters:@"hoge\"fugo"
                                                          type:MAEStringTypeDoubleQuoted];
            expect(s).to(equal(@"\"hoge\\\"fugo\""));

            s = [[MAESeparatedString alloc] initWithCharacters:@"hoge'fugo"
                                                          type:MAEStringTypeSingleQuoted];
            expect(s).to(equal(@"'hoge\'fugo'"));
        });
    });
}
QuickSpecEnd
