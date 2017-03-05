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
            expect(s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"\"hoge\"" ignoreEdgeBlank:NO]).notTo(beNil());
            expect(s.characters).to(equal(@"hoge"));
            expect(@(s.type)).to(equal(MAEStringTypeDoubleQuoted));
            expect(s.originalCharacters).to(equal(@"\"hoge\""));

            expect(s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"'hoge'" ignoreEdgeBlank:NO]).notTo(beNil());
            expect(s.characters).to(equal(@"hoge"));
            expect(@(s.type)).to(equal(MAEStringTypeSingleQuoted));
            expect(s.originalCharacters).to(equal(@"'hoge'"));

            expect(s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"\"\"" ignoreEdgeBlank:NO]).notTo(beNil());
            expect(s.characters).to(equal(@""));
            expect(@(s.type)).to(equal(MAEStringTypeDoubleQuoted));
            expect(s.originalCharacters).to(equal(@"\"\""));

            expect(s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"''" ignoreEdgeBlank:NO]).notTo(beNil());
            expect(s.characters).to(equal(@""));
            expect(@(s.type)).to(equal(MAEStringTypeSingleQuoted));
            expect(s.originalCharacters).to(equal(@"''"));
        });

        it(@"judge unbalanced quoted as not quoted-string", ^{
            __block MAESeparatedString* s;
            expect(s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"\"hoge" ignoreEdgeBlank:NO]).notTo(beNil());
            expect(s.characters).to(equal(@"\"hoge"));
            expect(@(s.type)).to(equal(MAEStringTypeEnumerate));
            expect(s.originalCharacters).to(equal(@"\"hoge"));
        });

        it(@"remove prefix and suffix spaces, if ignoreEdgeBlank is YES", ^{
            __block MAESeparatedString* s;
            expect(s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"  hoge  fuga  " ignoreEdgeBlank:YES]).notTo(beNil());
            expect(s.characters).to(equal(@"hoge  fuga"));
            expect(@(s.type)).to(equal(MAEStringTypeEnumerate));
            expect(s.originalCharacters).to(equal(@"  hoge  fuga  "));
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

        it(@"regard the instance as the same if characters and type are the same.", ^{
            MAESeparatedString* s1 = [[MAESeparatedString alloc] initWithOriginalCharacters:@" \"hoge\" " ignoreEdgeBlank:YES];
            MAESeparatedString* s2 = [[MAESeparatedString alloc] initWithOriginalCharacters:@"   \"hoge\"  " ignoreEdgeBlank:YES];
            MAESeparatedString* s3 = [[MAESeparatedString alloc] initWithOriginalCharacters:@" 'hoge' " ignoreEdgeBlank:YES];
            expect([s1 isEqual:s2]).to(equal(YES));
            expect([s1 isEqual:s3]).to(equal(NO));
        });

        it(@"returns NO, if instances can not be compared", ^{
            MAESeparatedString* s1 = [[MAESeparatedString alloc] initWithOriginalCharacters:@"hoge" ignoreEdgeBlank:YES];
            expect([s1 isEqual:@1]).to(equal(NO));
        });
    });

    describe(@"description", ^{
        it(@"returns string that ignored edge blanks", ^{
            MAESeparatedString* s1 = [[MAESeparatedString alloc] initWithOriginalCharacters:@" \"hoge\" " ignoreEdgeBlank:YES];
            expect([s1 description]).to(equal(@"\"hoge\""));
            MAESeparatedString* s2 = [[MAESeparatedString alloc] initWithOriginalCharacters:@" \"hoge\" " ignoreEdgeBlank:NO];
            expect([s2 description]).to(equal(@" \"hoge\" "));
        });
    });
}
QuickSpecEnd
