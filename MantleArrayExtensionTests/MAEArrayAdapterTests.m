//
//  MAEArrayAdapterTests.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEArrayAdapter.h"
#import "MAESeparatedString.h"
#import "MAETModel.h"
#import <Foundation/Foundation.h>

@interface MAEArrayAdapter ()
- (instancetype _Nonnull)initWithModelClass:(Class _Nonnull)modelClass;
- (NSArray<MAESeparatedString*>* _Nonnull)separateString:(NSString* _Nonnull)string;
+ (NSArray<MAEFragment*>* _Nullable)chooseFormatByPropertyKey:(NSArray<MAEFragment*>* _Nullable)fragments
                                                    withCount:(NSUInteger)count;
@end

QuickSpecBegin(MAEArrayAdapterTests)
{
    describe(@"modelOfClass:fromString:error:", ^{
        __block id mock = nil;

        afterEach(^{
            [mock stopMocking];
        });

        it(@"can handle premitive type", ^{
            __block MAETModel1* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel1.class
                                              fromString:@"true,5348765123,-1389477961,-2.5,1.797693"
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.b).to(equal(YES));
            expect(model.ui).to(equal(5348765123));
            expect(model.i).to(equal(-1389477961));
            expect(model.f).to(equal(-2.5f));
            expect(model.d).to(equal(1.797693));
        });

        it(@"can handle optional", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);

            __block MAETModel2* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel2.class
                                              fromString:@"a  \"c\""
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.a).to(equal(@"a"));
            expect(model.b).to(beNil());
            expect(model.c).to(equal(@"c"));
        });

        it(@"can handle variadic", ^{
            __block MAETModel3* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel3.class
                                              fromString:@"a, \"c\""
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.requireString).to(equal(@"a"));
            expect(model.optionalString).to(equal(@"c"));
            expect(model.variadicArray).to(equal(@[]));

            expect(model = [MAEArrayAdapter modelOfClass:MAETModel3.class
                                              fromString:@"a, b, \"c\""
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.requireString).to(equal(@"a"));
            expect(model.optionalString).to(equal(@"b"));
            expect(model.variadicArray).to(equal(@[ @"c" ]));

            expect(model = [MAEArrayAdapter modelOfClass:MAETModel3.class
                                              fromString:@"a, b, \"c\", d"
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.requireString).to(equal(@"a"));
            expect(model.optionalString).to(equal(@"b"));
            expect(model.variadicArray).to(equal(@[ @"c", @"d" ]));
        });

        it(@"can handle nested model", ^{
            __block MAETModel4* model;
            __block NSError* error = nil;

            expect(model = [MAEArrayAdapter modelOfClass:MAETModel4.class
                                              fromString:@"a | b, c, d"
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.requireString).to(equal(@"a"));
            expect(model.model3.requireString).to(equal(@"b"));
            expect(model.model3.optionalString).to(equal(@"c"));
            expect(model.model3.variadicArray).to(equal(@[ @"d" ]));

            expect(model = [MAEArrayAdapter modelOfClass:MAETModel4.class
                                              fromString:@"a"
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.requireString).to(equal(@"a"));
            expect(model.model3).to(beNil());
        });
    });

    describe(@"stringFromModel:error:", ^{
        it(@"can handle premitive type", ^{
            MAETModel1* model = [MAETModel1 new];
            model.b = YES;
            model.ui = 5348765123;
            model.i = -1389477961;
            model.f = -2.5f;
            model.d = 1.797693;

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error])
                .to(equal(@"true,5348765123,-1389477961,-2.5,1.797693"));
            expect(error).to(beNil());
        });

        it(@"can handle optional", ^{
            MAETModel2* model = [MAETModel2 new];
            model.a = @"a";
            model.c = @"c";

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"a \"c\""));
            expect(error).to(beNil());
        });

        it(@"can handle variadic", ^{
            MAETModel3* model = [MAETModel3 new];
            model.requireString = @"a";
            model.optionalString = @"c";
            model.variadicArray = @[];

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"a,c"));
            expect(error).to(beNil());

            model.requireString = @"a";
            model.optionalString = @"b";
            model.variadicArray = @[ @"c" ];
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"a,b,c"));
            expect(error).to(beNil());

            model.requireString = @"a";
            model.optionalString = @"b";
            model.variadicArray = @[ @"c", @"d" ];
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"a,b,c,d"));
        });

        it(@"can handle nested model", ^{
            MAETModel4* model = [MAETModel4 new];
            model.requireString = @"a";
            model.model3 = [MAETModel3 new];
            model.model3.requireString = @"b";
            model.model3.optionalString = @"c";
            model.model3.variadicArray = @[ @"d" ];

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error])
                .to(equal(@"a|b,c,d"));
            expect(error).to(beNil());

            model.requireString = @"a";
            model.model3 = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"a"));
        });
    });

    describe(@"separateString:", ^{
        __block id mock = nil;

        afterEach(^{
            [mock stopMocking];
        });

        it(@"can handle double-quote and single-quote", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn(' ');

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"'a\" b' c"]).to(equal(@[ @"'a\" b'", @"c" ]));
            expect([adapter separateString:@"\"a' b\"  c"]).to(equal(@[ @"\"a' b\"", @"c" ]));
        });

        it(@"can handle backslash", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn(' ');

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"'a\\' b' c"]).to(equal(@[ @"'a\\' b'", @"c" ]));
            expect([adapter separateString:@"\"a\\\" b\"  c"]).to(equal(@[ @"\"a\\\" b\"", @"c" ]));
        });

        it(@"returns nil, if it contains unclosed-quote", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn(' ');

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"'a' b' c"]).to(beNil());
            expect([adapter separateString:@"\"a\" b\" c"]).to(beNil());
        });

        it(@"returns list that contain empty string, if there contain two consecutive blanks and ignoreEdgeBlank is NO and separator is a space", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(NO);
            OCMStub([mock separator]).andReturn(' ');

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"a  b  c"]).to(equal(@[ @"a", @"", @"b", @"", @"c" ]));
        });

        it(@"can use separator other than space", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn(',');

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"a, b, c"]).to(equal(@[ @"a", @"b", @"c" ]));
        });

        it(@"returns list of string that contain space, if ignoreEdgeBlank is NO",
           ^{
               mock = OCMClassMock(MAETModel2.class);
               OCMStub([mock ignoreEdgeBlank]).andReturn(NO);
               OCMStub([mock separator]).andReturn(',');

               MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
               expect([adapter separateString:@"a, b, c"]).to(equal(@[ @"a", @" b", @" c" ]));
           });

        it(@"can included space without using quote, if separator is not space", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn('|');

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"a | I have a pen | c"]).to(equal(@[ @"a", @"I have a pen", @"c" ]));
        });
    });

    describe(@"chooseFormatByPropertyKey:withCount:", ^{
        it(@"returns fragments, when all fragment is requirements", ^{
            NSArray<MAEFragment*>* fragments = @[ MAEQuoted(@"a"), MAEQuoted(@"b"), MAEQuoted(@"c") ];
            expect([MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:fragments.count]).to(equal(fragments));
        });

        it(@"returns nil, if elements less", ^{
            NSArray<MAEFragment*>* fragments = @[ MAEQuoted(@"a"), MAEQuoted(@"b"), MAEQuoted(@"c") ];
            expect([MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:1]).to(beNil());
        });

        it(@"can returns fragments, if there are optional fragments", ^{
            NSArray<MAEFragment*>* fragments = @[ MAEQuoted(@"a"), MAEOptional(@"b"), MAEQuoted(@"c"), MAEOptional(@"d") ];
            __block NSArray<MAEFragment*>* gotFragments = nil;
            expect(gotFragments = [MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:2]).notTo(beNil());
            expect(gotFragments.count).to(equal(2));
            expect(gotFragments[0].propertyName).to(equal(@"a"));
            expect(gotFragments[1].propertyName).to(equal(@"c"));

            expect(gotFragments = [MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:3]).notTo(beNil());
            expect(gotFragments.count).to(equal(3));
            expect(gotFragments[0].propertyName).to(equal(@"a"));
            expect(gotFragments[1].propertyName).to(equal(@"b"));
            expect(gotFragments[2].propertyName).to(equal(@"c"));

            expect(gotFragments = [MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:4]).notTo(beNil());
            expect(gotFragments.count).to(equal(4));
            expect(gotFragments[0].propertyName).to(equal(@"a"));
            expect(gotFragments[1].propertyName).to(equal(@"b"));
            expect(gotFragments[2].propertyName).to(equal(@"c"));
            expect(gotFragments[3].propertyName).to(equal(@"d"));
        });

        it(@"can returns fragments, if there is variadic fragment", ^{
            NSArray<MAEFragment*>* fragments = @[ MAEQuoted(@"a"), MAEVariadic(@"b") ];
            __block NSArray<MAEFragment*>* gotFragments = nil;
            expect(gotFragments = [MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:2]).notTo(beNil());
            expect(gotFragments.count).to(equal(2));
            expect(gotFragments[0].propertyName).to(equal(@"a"));
            expect(gotFragments[1].propertyName).to(equal(@"b"));

            expect(gotFragments = [MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:3]).notTo(beNil());
            expect(gotFragments.count).to(equal(2));
            expect(gotFragments[0].propertyName).to(equal(@"a"));
            expect(gotFragments[1].propertyName).to(equal(@"b"));
        });

        it(@"remains the variadic that is not optional", ^{
            NSArray<MAEFragment*>* fragments = @[ MAEQuoted(@"a"), MAEOptional(@"b"), MAEVariadic(@"c") ];
            __block NSArray<MAEFragment*>* gotFragments = nil;
            expect(gotFragments = [MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:2]).notTo(beNil());
            expect(gotFragments.count).to(equal(3));
            expect(gotFragments[0].propertyName).to(equal(@"a"));
            expect(gotFragments[1].propertyName).to(equal(@"b"));
            expect(gotFragments[2].propertyName).to(equal(@"c"));

            expect(gotFragments = [MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:1]).notTo(beNil());
            expect(gotFragments.count).to(equal(2));
            expect(gotFragments[0].propertyName).to(equal(@"a"));
            expect(gotFragments[1].propertyName).to(equal(@"c"));

            fragments = @[ MAEQuoted(@"a"), MAEOptional(@"b"), MAEOptional(MAEVariadic(@"c")) ];
            expect(gotFragments = [MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:2]).notTo(beNil());
            expect(gotFragments.count).to(equal(2));
            expect(gotFragments[0].propertyName).to(equal(@"a"));
            expect(gotFragments[1].propertyName).to(equal(@"b"));

            expect(gotFragments = [MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:1]).notTo(beNil());
            expect(gotFragments.count).to(equal(1));
            expect(gotFragments[0].propertyName).to(equal(@"a"));
        });
    });
}
QuickSpecEnd