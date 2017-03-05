//
//  MAEArrayAdapter+TransformersTests.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/03/05.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEArrayAdapter.h"
#import <Mantle/MTLTransformerErrorHandling.h>

QuickSpecBegin(MAEArrayAdapter_TransformersTests)
{
    describe(@"numberTransformer", ^{
        NSValueTransformer<MTLTransformerErrorHandling>* transformer = [MAEArrayAdapter numberTransformer];

        it(@"can convert between integer and string", ^{
            expect([transformer transformedValue:@"1389477961"]).to(equal(@1389477961));
            expect([transformer transformedValue:@"-1389477961"]).to(equal(@(-1389477961)));

            expect([transformer reverseTransformedValue:@1389477961]).to(equal(@"1389477961"));
            expect([transformer reverseTransformedValue:@(-1389477961)]).to(equal(@"-1389477961"));
        });

        it(@"can convert to double from string", ^{
            expect([transformer transformedValue:@"1.797693"]).to(equal(@1.797693));
            expect([transformer transformedValue:@"-1.797693"]).to(equal(@(-1.797693)));

            expect([transformer reverseTransformedValue:@1.797693]).to(equal(@"1.797693"));
            expect([transformer reverseTransformedValue:@(-1.797693)]).to(equal(@"-1.797693"));
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
