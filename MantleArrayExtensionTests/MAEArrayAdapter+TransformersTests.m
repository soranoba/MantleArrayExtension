//
//  MAEArrayAdapter+TransformersTests.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/03/05.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEArrayAdapter.h"
#import "MAETModel.h"
#import <Mantle/MTLTransformerErrorHandling.h>

static inline MAESeparatedString* separatedString(NSString* string)
{
    return [[MAESeparatedString alloc] initWithOriginalCharacters:string ignoreEdgeBlank:NO];
}

QuickSpecBegin(MAEArrayAdapter_TransformersTests)
{
    describe(@"variadicTransformerWithArrayModelClass:", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer
            = [MAEArrayAdapter variadicTransformerWithArrayModelClass:MAETModel1.class];

        it(@"can convert from array to model", ^{
            MAETModel1* model
                = [transformer transformedValue:@[ separatedString(@"true"), separatedString(@"5348765123"),
                                                   separatedString(@"-1389477961"), separatedString(@"-2.5"),
                                                   separatedString(@"1.797693") ]];
            expect(model.b).to(equal(YES));
            expect(model.ui).to(equal(5348765123));
            expect(model.i).to(equal(-1389477961));
            expect(model.f).to(equal(-2.5f));
            expect(model.d).to(equal(1.797693));
        });

        it(@"can convert from model to array", ^{
            MAETModel1* model = [MAETModel1 new];
            model.b = YES;
            model.ui = 5348765123;
            model.i = -1389477961;
            model.f = -2.5f;
            model.d = 1.797693;
            expect([transformer reverseTransformedValue:model])
                .to(equal(@[ @"true", @"5348765123", @"-1389477961", @"-2.5", @"1.797693" ]));
        });

        it(@"validate of type correct", ^{
            id mock = OCMClassMock([MAETModel1 class]);
            OCMStub([mock formatByPropertyKey])
                .andReturn((@[ MAEEnum(@"b"), MAEQuoted(@"ui"), MAESingleQuoted(@"i"), @"f", @"d" ]));

            NSArray* data1 = @[ separatedString(@"true"), separatedString(@"5348765123"),
                                separatedString(@"-1389477961"), separatedString(@"-2.5"),
                                separatedString(@"1.797693") ];
            NSArray* data2 = @[ separatedString(@"true"), separatedString(@"\"5348765123\""),
                                separatedString(@"'-1389477961'"), separatedString(@"'-2.5'"),
                                separatedString(@"1.797693") ];

            __block MAETModel1* model;
            __block BOOL success = YES;
            __block NSError* error = nil;
            expect(model = [transformer transformedValue:data1 success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorNotMatchFragmentType));

            success = NO;
            error = nil;
            expect(model = [transformer transformedValue:data2 success:&success error:&error]).notTo(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
            expect(model.ui).to(equal(5348765123));
            expect(model.i).to(equal(-1389477961));
            expect(model.f).to(equal(-2.5f));
            expect(model.d).to(equal(1.797693));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            __block MAETModel1* model;
            NSArray* data = @[ separatedString(@"true"), separatedString(@"5348765123"),
                               separatedString(@"-1389477961"), separatedString(@"-2.5"),
                               separatedString(@"1.797693") ];

            expect(model = [transformer transformedValue:data success:&success error:&error]).notTo(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:model success:&success error:&error]).to(equal(data));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@1 success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
            expect(error.userInfo[MAEErrorInputDataKey]).to(equal(@1));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"1" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
            expect(error.userInfo[MAEErrorInputDataKey]).to(equal(@"1"));
        });
    });

    describe(@"stringTransformerWithArrayModelClass:", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer
            = [MAEArrayAdapter stringTransformerWithArrayModelClass:MAETModel1.class];

        it(@"can convert between model and string", ^{
            MAETModel1* model = [transformer transformedValue:@"true,5348765123,-1389477961,-2.5,1.797693"];
            expect(model.b).to(equal(YES));
            expect(model.ui).to(equal(5348765123));
            expect(model.i).to(equal(-1389477961));
            expect(model.f).to(equal(-2.5f));
            expect(model.d).to(equal(1.797693));

            expect([transformer reverseTransformedValue:model]).to(equal(@"true,5348765123,-1389477961,-2.5,1.797693"));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            __block MAETModel1* model;
            expect(model = [transformer transformedValue:@"true,5348765123,-1389477961,-2.5,1.797693" success:&success error:&error])
                .notTo(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:model success:&success error:&error])
                .to(equal(@"true,5348765123,-1389477961,-2.5,1.797693"));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@1 success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
            expect(error.userInfo[MAEErrorInputDataKey]).to(equal(@1));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"1" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
            expect(error.userInfo[MAEErrorInputDataKey]).to(equal(@"1"));
        });
    });

    describe(@"numberTransformer", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer = [MAEArrayAdapter numberTransformer];

        it(@"can convert between integer and string", ^{
            expect([transformer transformedValue:[@(ULONG_LONG_MAX) stringValue]]).to(equal(ULONG_LONG_MAX));
            expect([transformer transformedValue:[@(LONG_LONG_MIN) stringValue]]).to(equal(LONG_LONG_MIN));

            expect([transformer transformedValue:@"1389477961"]).to(equal(@1389477961));
            expect([transformer transformedValue:@"-1389477961"]).to(equal(@(-1389477961)));

            expect([transformer reverseTransformedValue:@1389477961]).to(equal(@"1389477961"));
            expect([transformer reverseTransformedValue:@(-1389477961)]).to(equal(@"-1389477961"));
        });

        it(@"can convert to double from string", ^{
            expect([transformer transformedValue:@"1.797693"]).to(equal(1.797693));
            expect([transformer transformedValue:@"-1.797693"]).to(equal(-1.797693));

            expect([transformer reverseTransformedValue:@1.797693]).to(equal(@"1.797693"));
            expect([transformer reverseTransformedValue:@(-1.797693)]).to(equal(@"-1.797693"));
        });

        it(@"can convert accurately at expression range", ^{
            expect([transformer transformedValue:[@(DBL_DIG) stringValue]]).to(equal(DBL_DIG));
            expect([transformer transformedValue:[@(-DBL_DIG) stringValue]]).to(equal(-DBL_DIG));

            expect([transformer reverseTransformedValue:@(DBL_DIG)]).to(equal([@(DBL_DIG) stringValue]));
            expect([transformer reverseTransformedValue:@(-DBL_DIG)]).to(equal([@(-DBL_DIG) stringValue]));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@"1389477961" success:&success error:&error]).to(equal(@1389477961));
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:@1389477961 success:&success error:&error]).to(equal(@"1389477961"));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@"aa" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MTLTransformerErrorHandlingErrorDomain));
            expect(error.code).to(equal(MTLTransformerErrorHandlingErrorInvalidInput));
            expect(error.userInfo[MTLTransformerErrorHandlingInputValueErrorKey]).to(equal(@"aa"));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"aa" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MTLTransformerErrorHandlingErrorDomain));
            expect(error.code).to(equal(MTLTransformerErrorHandlingErrorInvalidInput));
            expect(error.userInfo[MTLTransformerErrorHandlingInputValueErrorKey]).to(equal(@"aa"));
        });
    });

    describe(@"boolTransformer", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer = [MAEArrayAdapter boolTransformer];

        it(@"can convert to bool from string of integer", ^{
            expect([transformer transformedValue:@"1"]).to(equal(YES));
            expect([transformer transformedValue:@"-1"]).to(equal(YES));
            expect([transformer transformedValue:@"0"]).to(equal(NO));
        });

        it(@"can convert to bool from string of boolean", ^{
            expect([transformer transformedValue:@"true"]).to(equal(YES));
            expect([transformer transformedValue:@"false"]).to(equal(NO));
        });

        it(@"can convert to bool from string", ^{
            expect([transformer transformedValue:@"t"]).to(equal(YES));
            expect([transformer transformedValue:@"y"]).to(equal(YES));
            expect([transformer transformedValue:@"f"]).to(equal(NO));
            expect([transformer transformedValue:@"n"]).to(equal(NO));
            expect([transformer transformedValue:@""]).to(equal(NO));
        });

        it(@"can convert to string of boolean from bool", ^{
            expect([transformer reverseTransformedValue:@YES]).to(equal(@"true"));
            expect([transformer reverseTransformedValue:@NO]).to(equal(@"false"));
        });

        it(@"can convert to string of boolean from integer", ^{
            expect([transformer reverseTransformedValue:@1]).to(equal(@"true"));
            expect([transformer reverseTransformedValue:@(-1)]).to(equal(@"true"));
            expect([transformer reverseTransformedValue:@0]).to(equal(@"false"));
        });

        it(@"sets YES to success, when the conversion is successful", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@"true" success:&success error:&error]).to(equal(YES));
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:@YES success:&success error:&error]).to(equal(@"true"));
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets YES to success, if input value is nil", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());

            success = NO;
            expect([transformer reverseTransformedValue:nil success:&success error:&error]).to(beNil());
            expect(success).to(equal(YES));
            expect(error).to(beNil());
        });

        it(@"sets NO to success, when input value is invalid type", ^{
            __block BOOL success = NO;
            __block NSError* error = nil;
            expect([transformer transformedValue:@1 success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
            expect(error.userInfo[MAEErrorInputDataKey]).to(equal(@1));

            success = NO;
            error = nil;
            expect([transformer reverseTransformedValue:@"1" success:&success error:&error]).to(beNil());
            expect(success).to(equal(NO));
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
            expect(error.userInfo[MAEErrorInputDataKey]).to(equal(@"1"));
        });
    });
}
QuickSpecEnd
