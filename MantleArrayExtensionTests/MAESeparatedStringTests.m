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

    describe(@"isEqualToSeparatedString:", ^{
        it(@"can compare NSString and MAESeparatedString", ^{
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithCharacters:@"hoge"
                                                                              type:MAEStringTypeDoubleQuoted];
            expect([s isEqualToSeparatedString:@"\"hoge\""]).to(equal(YES));
            expect([s isEqualToSeparatedString:@"hoge"]).to(equal(NO));

            s = [[MAESeparatedString alloc] initWithCharacters:@"hoge"
                                                          type:MAEStringTypeSingleQuoted];
            expect([s isEqualToSeparatedString:@"'hoge'"]).to(equal(YES));

            s = [[MAESeparatedString alloc] initWithCharacters:@"hoge"
                                                          type:MAEStringTypeEnumerate];
            expect([s isEqualToSeparatedString:@"hoge"]).to(equal(YES));

            s = [[MAESeparatedString alloc] initWithCharacters:@"hoge\"fugo"
                                                          type:MAEStringTypeDoubleQuoted];
            expect([s isEqualToSeparatedString:@"\"hoge\\\"fugo\""]).to(equal(YES));

            s = [[MAESeparatedString alloc] initWithCharacters:@"hoge'fugo"
                                                          type:MAEStringTypeSingleQuoted];
            expect([s isEqualToSeparatedString:@"'hoge\\'fugo'"]).to(equal(YES));
        });

        it(@"regard the instance as the same if characters and type are the same.", ^{
            MAESeparatedString* s1 = [[MAESeparatedString alloc] initWithOriginalCharacters:@" \"hoge\" " ignoreEdgeBlank:YES];
            MAESeparatedString* s2 = [[MAESeparatedString alloc] initWithOriginalCharacters:@"   \"hoge\"  " ignoreEdgeBlank:YES];
            MAESeparatedString* s3 = [[MAESeparatedString alloc] initWithOriginalCharacters:@" 'hoge' " ignoreEdgeBlank:YES];
            expect([s1 isEqualToSeparatedString:s2]).to(equal(YES));
            expect([s1 isEqualToSeparatedString:s3]).to(equal(NO));
        });

        it(@"returns NO, if instances can not be compared", ^{
            MAESeparatedString* s1 = [[MAESeparatedString alloc] initWithOriginalCharacters:@"hoge" ignoreEdgeBlank:YES];
            expect([s1 isEqualToSeparatedString:(id)@1]).to(equal(NO));
        });
    });

    describe(@"NSString Override", ^{
        it(@"become NSString when it copy", ^{
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"  hoge  " ignoreEdgeBlank:YES];
            expect([s isKindOfClass:MAESeparatedString.class]).to(equal(YES));

            id copied = [s copy];
            expect([copied isKindOfClass:NSString.class]).to(equal(YES));
            expect([copied isKindOfClass:MAESeparatedString.class]).to(equal(NO));
            expect(copied).to(equal(@"hoge"));
        });

        it(@"become NSMutableString when it mutableCopy", ^{
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"  hoge  " ignoreEdgeBlank:YES];
            expect([s isKindOfClass:MAESeparatedString.class]).to(equal(YES));

            id copied = [s mutableCopy];
            expect([copied isKindOfClass:NSMutableString.class]).to(equal(YES));
            expect([copied isKindOfClass:MAESeparatedString.class]).to(equal(NO));
            expect(copied).to(equal(@"hoge"));
        });

        it(@"returns characters when description called", ^{
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"  'hoge'  " ignoreEdgeBlank:YES];
            expect([s description]).to(equal(@"hoge"));
            expect([NSString stringWithFormat:@"%@", s]).to(equal(@"hoge"));
        });

        it(@"returns characters.length when length called", ^{
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"  'hoge'  " ignoreEdgeBlank:YES];
            expect(s.length).to(equal(@"hoge".length));
        });

        it(@"returns character specified position of the characters", ^{
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"  'hoge'  " ignoreEdgeBlank:YES];
            expect(@([s characterAtIndex:0])).to(equal('h'));
            expect(@([s characterAtIndex:1])).to(equal('o'));
            expect(@([s characterAtIndex:2])).to(equal('g'));
            expect(@([s characterAtIndex:3])).to(equal('e'));
            expect(@([s characterAtIndex:4])).to(raiseException());
        });

        it(@"can compare NSString", ^{
            MAESeparatedString* s = [[MAESeparatedString alloc] initWithOriginalCharacters:@"  'hoge'  " ignoreEdgeBlank:YES];
            expect([s isEqual:@"hoge"]).to(equal(YES));
            expect([s isEqualToString:@"hoge"]).to(equal(YES));
            expect([s isEqual:@"'hoge'"]).to(equal(NO));
            expect([s isEqualToString:@"'hoge'"]).to(equal(NO));
            expect([@"hoge" isEqual:s]).to(equal(YES));
            expect([@"hoge" isEqualToString:s]).to(equal(YES));
        });
    });
}
QuickSpecEnd
