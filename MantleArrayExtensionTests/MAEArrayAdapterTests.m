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
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@interface MAEArrayAdapter ()
- (instancetype _Nonnull)initWithModelClass:(Class _Nonnull)modelClass;
- (NSArray<MAESeparatedString*>* _Nonnull)separateString:(NSString* _Nonnull)string;
+ (NSArray<MAEFragment*>* _Nullable)chooseFormatByPropertyKey:(NSArray<MAEFragment*>* _Nullable)fragments
                                                    withCount:(NSUInteger)count;

+ (NSDictionary* _Nonnull)valueTransformersForModelClass:(Class _Nonnull)modelClass;
+ (NSValueTransformer* _Nullable)stringTransformerForObjCType:(const char* _Nonnull)objCType;
@end

QuickSpecBegin(MAEArrayAdapterTests)
{
    describe(@"Initializer validation", ^{
        __block id mock = nil;

        beforeEach(^{
            mock = OCMClassMock(MAETModel1.class);
        });

        afterEach(^{
            [mock stopMocking];
        });

        it(@"throw exception, if formatByPropertyKey include properties that is not found in model", ^{
            OCMStub([mock formatByPropertyKey]).andReturn((@[ @"notFound", @"a" ]));
            expect([[MAEArrayAdapter alloc] initWithModelClass:MAETModel1.class]).to(raiseException());
        });
        it(@"throw exception, if return value is invalid format", ^{
            OCMStub([mock formatByPropertyKey]).andReturn((@[ @"a", @[ @1 ] ]));
            expect([[MAEArrayAdapter alloc] initWithModelClass:MAETModel1.class]).to(raiseException());
        });
        it(@"throw exception, if same propertyKey used in formatByPropertyKey", ^{
            OCMStub([mock formatByPropertyKey]).andReturn((@[ @"b", @"b" ]));
            expect([[MAEArrayAdapter alloc] initWithModelClass:MAETModel1.class]).to(raiseException());
        });
        it(@"throw exception, if fragments exist after the variadic fragment", ^{
            OCMStub([mock formatByPropertyKey]).andReturn((@[ MAEVariadic(@"i"), @"b" ]));
            expect([[MAEArrayAdapter alloc] initWithModelClass:MAETModel1.class]).to(raiseException());
        });
        it(@"formatByPropertyKey is valid", ^{
            OCMStub([mock formatByPropertyKey])
                .andReturn((@[ @"b", MAEQuoted(@"ui"), MAESingleQuoted(@"i"), MAEOptional(@"f"), MAEOptional(MAEQuoted(@"d")) ]));
            expect([[MAEArrayAdapter alloc] initWithModelClass:MAETModel1.class]).notTo(beNil());
        });
    });

    describe(@"input data is nil", ^{
        it(@"return nil, if input data is nil", ^{
            __block NSError* error = nil;

            void (^check)() = [^{
                expect(error).notTo(beNil());
                expect(error.domain).to(equal(MAEErrorDomain));
                expect(error.code).to(equal(MAEErrorNilInputData));
            } copy];

            error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel1.class fromArray:nil error:&error]).to(beNil());
            check();

            error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel1.class fromString:nil error:&error]).to(beNil());
            check();

            error = nil;
            expect([MAEArrayAdapter stringFromModel:nil error:&error]).to(beNil());
            check();

            error = nil;
            expect([MAEArrayAdapter arrayFromModel:nil error:&error]).to(beNil());
            check();
        });
    });

    describe(@"modelOfClass:fromString:error:", ^{
        __block id mock = nil;

        afterEach(^{
            [mock stopMocking];
        });

        it(@"can handle premitive type and NSNumber", ^{
            __block MAETModel1* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel1.class
                                              fromString:@"true,5348765123,-1389477961,-2.5,1.797693,-9437138961"
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.b).to(equal(YES));
            expect(model.ui).to(equal(5348765123));
            expect(model.i).to(equal(-1389477961));
            expect(model.f).to(equal(-2.5f));
            expect(model.d).to(equal(1.797693));
            expect(model.n).to(equal(-9437138961));
        });

        it(@"can return model, if there is optional in the middle", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);

            __block MAETModel2* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel2.class
                                              fromString:@"a \"c\""
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.a).to(equal(@"a"));
            expect(model.b).to(beNil()); // optional!!
            expect(model.c).to(equal(@"c"));
        });

        it(@"returns variadic that is empty array, if there is no value at required variadic", ^{
            __block MAETModel3* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel3.class
                                              fromString:@"require, \"optional\""
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.requireString).to(equal(@"require"));
            expect(model.optionalString).to(equal(@"optional"));
            expect(model.variadicArray).to(equal(@[]));
        });

        it(@"returns variadic that is nil, if there is no value at optional variadic", ^{
            mock = OCMClassMock(MAETModel3.class);
            OCMStub([mock formatByPropertyKey]).andReturn((@[ @"requireString", MAEOptional(@"optionalString"),
                                                              MAEOptional(MAEVariadic(@"variadicArray")) ]));
            __block MAETModel3* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel3.class
                                              fromString:@"require, \"optional\""
                                                   error:&error])
                .notTo(beNil());
            expect(model.requireString).to(equal(@"require"));
            expect(model.optionalString).to(equal(@"optional"));
            expect(model.variadicArray).to(beNil());
        });

        it(@"does not need that all elements in variadic are same types", ^{
            __block MAETModel3* model;
            __block NSError* error = nil;

            expect(model = [MAEArrayAdapter modelOfClass:MAETModel3.class
                                              fromString:@"a, b, \"c\", d"
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.requireString).to(equal(@"a"));
            expect(model.optionalString).to(equal(@"b"));
            expect(model.variadicArray).to(equal(@[ @"c", @"d" ]));
        });

        it(@"returns nil, if there is invalid type", ^{
            mock = OCMClassMock(MAETModel3.class);
            OCMStub([mock formatByPropertyKey]).andReturn((@[ MAEQuoted(@"requireString") ]));
            __block NSError* error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel3.class
                                      fromString:@"require"
                                           error:&error])
                .to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorNotMatchFragmentType));
        });

        it(@"returns nil, if there is invalid type in variadic", ^{
            mock = OCMClassMock(MAETModel3.class);
            OCMStub([mock formatByPropertyKey]).andReturn((@[ @"requireString", MAEOptional(@"optionalString"),
                                                              MAEOptional(MAEVariadic(MAEQuoted(@"variadicArray"))) ]));
            __block NSError* error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel3.class
                                      fromString:@"require, \"optional\", \"variadic1\", variadic2"
                                           error:&error])
                .to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorNotMatchFragmentType));
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

        it(@"returns nil, if fragment count does not support", ^{
            __block NSError* error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel2.class fromString:@"a" error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorNotMatchFragmentCount));
        });

        it(@"returns nil, if unclosed quoted is exist", ^{
            __block NSError* error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel2.class fromString:@"'" error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
        });
    });

    describe(@"modelOfClass:fromArray:error:", ^{
        it(@"returns a model, if there are no invalid types when input data is NSArray of NSString", ^{
            id mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock formatByPropertyKey]).andReturn((@[ MAEEnum(@"a"), MAESingleQuoted(@"b"), MAEQuoted(@"c") ]));
            __block MAETModel2* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel2.class
                                               fromArray:@[ @"a", @"'b'", @"\"c\"" ]
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.a).to(equal(@"a"));
            expect(model.b).to(equal(@"b"));
            expect(model.c).to(equal(@"c"));
        });

        it(@"returns nil, if there are invalid types when input data is NSArray of NSString", ^{
            id mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock formatByPropertyKey]).andReturn((@[ MAEEnum(@"a"), MAESingleQuoted(@"b"), MAEQuoted(@"c") ]));
            __block NSError* error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel2.class
                                       fromArray:@[ @"'a'", @"\"b\"", @"c" ]
                                           error:&error])
                .to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorNotMatchFragmentType));
        });

        it(@"retuns a model, if there are no invalid types when input data is NSArray of MAESeparatedString", ^{
            id mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock formatByPropertyKey]).andReturn((@[ MAEEnum(@"a"), MAESingleQuoted(@"b"), MAEQuoted(@"c") ]));
            __block MAETModel2* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel2.class
                                               fromArray:@[ [[MAESeparatedString alloc] initWithCharacters:@"a"
                                                                                                      type:MAEStringTypeEnumerate],
                                                            [[MAESeparatedString alloc] initWithCharacters:@"b"
                                                                                                      type:MAEStringTypeSingleQuoted],
                                                            [[MAESeparatedString alloc] initWithCharacters:@"c"
                                                                                                      type:MAEStringTypeDoubleQuoted] ]
                                                   error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.a).to(equal(@"a"));
            expect(model.b).to(equal(@"b"));
            expect(model.c).to(equal(@"c"));
        });

        it(@"returns nil, if there are invalid types when input data is NSArray of MAESeparatedString", ^{
            id mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock formatByPropertyKey]).andReturn((@[ MAEEnum(@"a"), MAESingleQuoted(@"b"), MAEQuoted(@"c") ]));
            __block NSError* error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel2.class
                                       fromArray:@[ [[MAESeparatedString alloc] initWithCharacters:@"a"
                                                                                              type:MAEStringTypeSingleQuoted],
                                                    [[MAESeparatedString alloc] initWithCharacters:@"b"
                                                                                              type:MAEStringTypeDoubleQuoted],
                                                    [[MAESeparatedString alloc] initWithCharacters:@"c"
                                                                                              type:MAEStringTypeEnumerate] ]
                                           error:&error])
                .to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorNotMatchFragmentType));
        });
    });

    describe(@"stringTransformerForObjCType:", ^{
        it(@"supported basic type", ^{
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(char)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(int8_t)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(short)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(int16_t)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(int)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(long)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(int32_t)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(long long)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(int64_t)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(unsigned char)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(uint8_t)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(unsigned int)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(unsigned short)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(uint16_t)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(unsigned long)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(uint32_t)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(unsigned long long)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(uint64_t)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(NSInteger)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(NSUInteger)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(bool)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(BOOL)]).notTo(beNil());
            expect([MAEArrayAdapter stringTransformerForObjCType:@encode(boolean_t)]).notTo(beNil());
        });
    });

    describe(@"stringFromModel:error:", ^{
        it(@"can handle premitive type and NSNumber", ^{
            MAETModel1* model = [MAETModel1 new];
            model.b = YES;
            model.ui = 5348765123;
            model.i = -1389477961;
            model.f = -2.5f;
            model.d = 1.797693;
            model.n = @(-9437138961);

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error])
                .to(equal(@"true,5348765123,-1389477961,-2.5,1.797693,-9437138961"));
            expect(error).to(beNil());
        });

        it(@"ignore optional value when it is nil", ^{
            MAETModel2* model = [MAETModel2 new];
            model.a = @"a";
            model.c = @"c";

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"a \"c\""));
            expect(error).to(beNil());
        });

        it(@"contains optional value when it is not nil", ^{
            MAETModel2* model = [MAETModel2 new];
            model.a = @"a";
            model.b = @"b";
            model.c = @"c";

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"a b \"c\""));
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
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"a|b,c,d"));
            expect(error).to(beNil());

            model.requireString = @"a";
            model.model3 = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"a"));
            expect(error).to(beNil());
        });

        it(@"automatically choose double quoted string, when value contains spaces and type is MaybeQuoted", ^{
            MAETModel2* model = [MAETModel2 new];
            model.a = @"maybe quoted string";
            model.b = @"maybe \"quoted\" string";
            model.c = @"quoted string";

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error])
                .to(equal(@"\"maybe quoted string\" \"maybe \\\"quoted\\\" string\" \"quoted string\""));
            expect(error).to(beNil());
        });

        it(@"automatically choose double quoted string, when value is empty string", ^{
            MAETModel2* model = [MAETModel2 new];
            model.a = @"";
            model.c = @"";

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"\"\" \"\""));
            expect(error).to(beNil());
        });
    });

    describe(@"arrayFromModel:error:", ^{
        it(@"returns NSArray of MAESeparatedString", ^{
            MAETModel2* model = [MAETModel2 new];
            model.a = @"maybe quoted string";
            model.b = @"maybe \"quoted\" string";
            model.c = @"quoted string";

            __block NSError* error = nil;
            __block NSArray<MAESeparatedString*>* array = nil;
            expect(array = [MAEArrayAdapter arrayFromModel:model error:&error])
                .to(equal(@[ @"maybe quoted string", @"maybe \"quoted\" string", @"quoted string" ]));
            expect(error).to(beNil());

            expect([array[0] isEqualToSeparatedString:@"\"maybe quoted string\""]).to(equal(YES));
            expect([array[1] isEqualToSeparatedString:@"\"maybe \\\"quoted\\\" string\""]).to(equal(YES));
            expect([array[2] isEqualToSeparatedString:@"\"quoted string\""]).to(equal(YES));
        });
    });

    describe(@"transformer", ^{
        NSValueTransformer* transformer = [NSValueTransformer valueTransformerForName:NSNegateBooleanTransformerName];

        it(@"can use transformers", ^{
            id modelMock = OCMClassMock(MAETModel6.class);
            OCMStub([modelMock booleanArrayTransformer]).andReturn(transformer);
            id transformerMock = OCMPartialMock(transformer);
            OCMStub([transformerMock reverseTransformedValue:OCMOCK_ANY]).andReturn(@"true");

            __block MAETModel6* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel6.class fromString:@"http://localhost,100" error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.url).to(equal([NSURL URLWithString:@"http://localhost"]));
            expect(model.boolean).to(equal(NO));

            error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"http://localhost,true"));
            expect(error).to(beNil());
        });

        it(@"returns nil, if errorHandlingTransformer returns error", ^{
            id modelMock = OCMClassMock(MAETModel6.class);
            OCMStub([modelMock booleanArrayTransformer]).andReturn(transformer);
            id transformerMock = OCMPartialMock(transformer);
            OCMStub([transformerMock reverseTransformedValue:OCMOCK_ANY]).andReturn(@"true");

            __block NSError* error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel6.class fromString:@"http://localhost,100,error" error:&error])
                .to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(@"domain"));
            expect(error.code).to(equal(1234));

            MAETModel6* model = [MAETModel6 new];
            model.url = [NSURL URLWithString:@"http://localhost"];
            model.boolean = @NO;
            model.empty = @"";
            error = nil;

            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(@"domain"));
            expect(error.code).to(equal(1234));
        });

        it(@"regard as success, when transformer that is not errorHandling returns nil", ^{
            id modelMock = OCMClassMock(MAETModel6.class);
            OCMStub([modelMock booleanArrayTransformer]).andReturn(transformer);
            id transformerMock = OCMPartialMock(transformer);
            __block id returnValue = nil;
            OCMStub([transformerMock transformedValue:OCMOCK_ANY]).andDo(^(NSInvocation* invocation) {
                [invocation setReturnValue:&returnValue];
            });
            OCMStub([transformerMock reverseTransformedValue:OCMOCK_ANY]).andDo(^(NSInvocation* invocation) {
                [invocation setReturnValue:&returnValue];
            });

            __block MAETModel6* model;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel6.class fromString:@"http://localhost,100" error:&error])
                .notTo(beNil());
            expect(error).to(beNil());
            expect(model.url).to(equal([NSURL URLWithString:@"http://localhost"]));
            expect(model.boolean).to(equal(NO)); // NO == nil

            error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@"http://localhost,\"\""));
            expect(error).to(beNil());
        });

        it(@"returns nil, if reverseTransformer returns object that is not NSString", ^{
            id modelMock = OCMClassMock(MAETModel6.class);
            OCMStub([modelMock booleanArrayTransformer]).andReturn(transformer);
            id transformerMock = OCMPartialMock(transformer);
            OCMStub([transformerMock reverseTransformedValue:OCMOCK_ANY]).andReturn(@1);

            MAETModel6* model = [MAETModel6 new];
            model.url = [NSURL URLWithString:@"http://localhost"];
            model.boolean = @NO;
            __block NSError* error = nil;

            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
        });
    });

    describe(@"classForParsingArray:", ^{
        __block id mock = nil;

        afterEach(^{
            [mock stopMocking];
        });

        it(@"corresponds to different separators", ^{
            __block MAETModel4* model;
            __block NSError* error = nil;

            mock = OCMClassMock(MAETModel5.class);
            id checkBlock =
                [OCMArg checkWithBlock:^BOOL(id arg) {
                    // NOTE: MAETModel5's separator is ' '.
                    expect(arg).to(equal(@[ [[MAESeparatedString alloc] initWithCharacters:@"a" type:MAEStringTypeEnumerate],
                                            [[MAESeparatedString alloc] initWithCharacters:@"|"
                                                                                      type:MAEStringTypeEnumerate],
                                            [[MAESeparatedString alloc] initWithCharacters:@"b,"
                                                                                      type:MAEStringTypeEnumerate],
                                            [[MAESeparatedString alloc] initWithCharacters:@"c,"
                                                                                      type:MAEStringTypeEnumerate],
                                            [[MAESeparatedString alloc] initWithCharacters:@"d"
                                                                                      type:MAEStringTypeEnumerate] ]));
                    return YES;
                }];
            OCMExpect([mock classForParsingArray:checkBlock]).andForwardToRealObject();

            // NOTE: It is specify to use MAETModel4 in MAETModel5
            expect(model = [MAEArrayAdapter modelOfClass:MAETModel5.class fromString:@"a | b, c, d" error:&error])
                .notTo(beNil());
            expect(model.requireString).to(equal(@"a"));
            expect(error).to(beNil());

            OCMVerify(mock);

            checkBlock = [OCMArg checkWithBlock:^BOOL(id arg) {
                expect(arg).to(equal(@[ [[MAESeparatedString alloc] initWithCharacters:@"a | b"
                                                                                  type:MAEStringTypeEnumerate],
                                        [[MAESeparatedString alloc] initWithCharacters:@"c"
                                                                                  type:MAEStringTypeEnumerate],
                                        [[MAESeparatedString alloc] initWithCharacters:@"d"
                                                                                  type:MAEStringTypeEnumerate] ]));
                return YES;
            }];
            OCMExpect([mock classForParsingArray:checkBlock]).andForwardToRealObject();

            expect(model = [MAEArrayAdapter modelOfClass:MAETModel5.class fromArray:@[ @"a | b", @"c", @"d" ] error:&error])
                .notTo(beNil());
            expect(model.requireString).to(equal(@"a"));
            expect(error).to(beNil());

            OCMVerify(mock);
        });

        it(@"can returns model, if classForParsingArray returns another class that have same separator", ^{
            __block MAETModel2* model;
            __block NSError* error = nil;

            mock = OCMClassMock(MAETModel5.class);
            OCMStub([mock classForParsingArray:OCMOCK_ANY]).andReturn(MAETModel2.class);

            expect(model = [MAEArrayAdapter modelOfClass:MAETModel5.class fromString:@"a b \"c\"" error:&error]).notTo(beNil());
            expect([model isKindOfClass:MAETModel2.class]).to(equal(YES));
            expect(model.a).to(equal(@"a"));
            expect(model.b).to(equal(@"b"));
            expect(model.c).to(equal(@"c"));
            expect(error).to(beNil());
        });

        it(@"corresponds to different quotedOptions", ^{
            __block MAETModel2* model;
            __block NSError* error = nil;

            mock = OCMClassMock(MAETModel5.class);
            OCMStub([mock classForParsingArray:OCMOCK_ANY]).andReturn(MAETModel2.class);

            id model2Mock = OCMClassMock(MAETModel2.class);
            OCMStub([model2Mock quotedOptions]).andReturn(0);

            expect(model = [MAEArrayAdapter modelOfClass:MAETModel5.class fromString:@"\"a b\" \"c\"" error:&error]).notTo(beNil());
            expect([model isKindOfClass:MAETModel2.class]).to(equal(YES));
            expect(model.a).to(equal(@"\"a"));
            expect(model.b).to(equal(@"b\""));
            expect(model.c).to(equal(@"c"));
            expect(error).to(beNil());
        });

        it(@"returns nil, if there is invalid type when classForParsingArray used", ^{
            __block NSError* error = nil;

            mock = OCMClassMock(MAETModel5.class);
            OCMStub([mock classForParsingArray:OCMOCK_ANY]).andReturn(MAETModel2.class);

            expect([MAEArrayAdapter modelOfClass:MAETModel5.class fromString:@"a b c" error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorNotMatchFragmentType));
        });

        it(@"can returns model, if classForParsingArray returns itself class.", ^{
            __block MAETModel5* model;
            __block NSError* error = nil;

            mock = OCMClassMock(MAETModel5.class);
            OCMStub([mock classForParsingArray:OCMOCK_ANY]).andReturn(MAETModel5.class);

            expect(model = [MAEArrayAdapter modelOfClass:MAETModel5.class fromString:@"a | b, c, d" error:&error]).notTo(beNil());
            expect(model.variadicArray).to(equal(@[ @"a", @"|", @"b,", @"c,", @"d" ]));
            expect(error).to(beNil());
        });

        it(@"returns nil, if classForParsingArray returns nil", ^{
            __block id returnValue = nil;

            id mock = OCMClassMock(MAETModel5.class);
            OCMStub([mock classForParsingArray:OCMOCK_ANY]).andDo(^(NSInvocation* invocation) {
                [invocation setReturnValue:&returnValue];
            });

            __block NSError* error = nil;
            expect([MAEArrayAdapter modelOfClass:MAETModel5.class fromString:@"a | b, c, d" error:&error]).to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorNoConversionTarget));
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
            expect([adapter separateString:@"'a\" b' c"]).to(equal(@[ @"a\" b", @"c" ]));
            expect([adapter separateString:@"\"a' b\"  c"]).to(equal(@[ @"a' b", @"c" ]));
        });

        it(@"can handle backslash", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn(' ');

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"'a\\' b' c"]).to(equal(@[ @"a' b", @"c" ]));
            expect([adapter separateString:@"\"a\\\" b\"  c"]).to(equal(@[ @"a\" b", @"c" ]));
            expect([adapter separateString:@"a b c\\"]).to(equal(@[ @"a", @"b", @"c\\" ]));
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

        it(@"returns list that does not contain empty string, if there contain two consecutive blanks and ignoreEdgeBlank is YES and separator is a space", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn(' ');

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"a  b  c"]).to(equal(@[ @"a", @"b", @"c" ]));
        });

        it(@"can use separator other than space", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn(',');

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"a, b, c"]).to(equal(@[ @"a", @"b", @"c" ]));
        });

        it(@"returns list of string that contain space, if ignoreEdgeBlank is NO", ^{
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

        it(@"consider single quoted as simple a character, if option does not include MAEArraySingleQuotedEnable", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn(' ');
            OCMStub([mock quotedOptions]).andReturn(MAEArrayDoubleQuotedEnable);

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"I'm not \"a Reflector\""]).to(equal(@[ @"I'm", @"not", @"a Reflector" ]));
        });

        it(@"consider double quoted as simple a character, if option does not include MAEArrayDoubleQuotedEnable", ^{
            mock = OCMClassMock(MAETModel2.class);
            OCMStub([mock ignoreEdgeBlank]).andReturn(YES);
            OCMStub([mock separator]).andReturn(' ');
            OCMStub([mock quotedOptions]).andReturn(MAEArraySingleQuotedEnable);

            MAEArrayAdapter* adapter = [[MAEArrayAdapter alloc] initWithModelClass:MAETModel2.class];
            expect([adapter separateString:@"\"Do you 'know Reflector?'\""]).to(equal(@[ @"\"Do", @"you", @"'know Reflector?'\"" ]));
        });
    });

    describe(@"chooseFormatByPropertyKey:withCount:", ^{
        it(@"returns fragments, when all fragment is requirements", ^{
            NSArray<MAEFragment*>* fragments = @[ MAEQuoted(@"a"), MAEQuoted(@"b"), MAEQuoted(@"c") ];
            expect([MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:fragments.count]).to(equal(fragments));
        });

        it(@"returns nil, if count is too small", ^{
            NSArray<MAEFragment*>* fragments = @[ MAEQuoted(@"a"), MAEQuoted(@"b"), MAEQuoted(@"c") ];
            expect([MAEArrayAdapter chooseFormatByPropertyKey:fragments withCount:1]).to(beNil());
        });

        it(@"can returns fragments, if count is less than number of fragments, but there are optional fragments", ^{
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

        it(@"can returns fragments, if count is less than number of fragments and there is variadic fragment", ^{
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

    describe(@"valueTransformersForModelClass:", ^{
        __block id mock;

        afterEach(^{
            [mock stopMocking];
        });

        it(@"use the result, if arrayTransformerForKey: is defined", ^{
            expect([MAETModel4 respondsToSelector:NSSelectorFromString(@"requireStringArrayTransformer")]).to(equal(NO));
            mock = OCMClassMock(MAETModel4.class);

            OCMStub([mock arrayTransformerForKey:
                              [OCMArg checkWithBlock:^BOOL(NSString* _Nonnull key) {
                                  return [key isEqualToString:@"requireString"];
                              }]])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"1" : @"!!mock!!" }]);

            NSDictionary* transformers = [MAEArrayAdapter valueTransformersForModelClass:MAETModel4.class];
            expect([transformers[@"requireString"] transformedValue:@"1"]).to(equal(@"!!mock!!"));
        });

        it(@"use the transformer, if <key>ArayTransformer is defined", ^{
            mock = OCMClassMock(MAETModel4.class);

            OCMStub([mock model3ArrayTransformer])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"2" : @"!!mock!!" }]);

            NSDictionary* transformers = [MAEArrayAdapter valueTransformersForModelClass:MAETModel4.class];
            expect([transformers[@"model3"] transformedValue:@"2"]).to(equal(@"!!mock!!"));
        });

        it(@"choose <key>ArayTransformer in preference to arayTransformerForKey:", ^{
            mock = OCMClassMock(MAETModel4.class);

            OCMStub([mock model3ArrayTransformer])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"3" : @"model3ArrayTransformer" }]);

            OCMStub([mock arrayTransformerForKey:
                              [OCMArg checkWithBlock:^BOOL(NSString* _Nonnull key) {
                                  return [key isEqualToString:@"model3"];
                              }]])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"3" : @"ArrayTransformerForKey:" }]);

            NSDictionary* transformers = [MAEArrayAdapter valueTransformersForModelClass:MAETModel4.class];
            expect([transformers[@"model3"] transformedValue:@"3"]).to(equal(@"model3ArrayTransformer"));
        });

        it(@"does not choose arayTransformerForKey:, if <key>ArayTransformer returns nil", ^{
            mock = OCMClassMock(MAETModel4.class);

            OCMStub([mock model3ArrayTransformer]).andReturn(nil);

            OCMStub([mock arrayTransformerForKey:
                              [OCMArg checkWithBlock:^BOOL(NSString* _Nonnull key) {
                                  return [key isEqualToString:@"model3"];
                              }]])
                .andReturn([NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"4" : @"arayTransformerForKey:" }]);

            NSDictionary* transformers = [MAEArrayAdapter valueTransformersForModelClass:MAETModel4.class];
            expect([transformers[@"model3"] transformedValue:@"4"]).to(beNil());
        });

        it(@"choose defaultTransformer, if <key>ArayTransformer is not defined and arayTransformerForKey: returns nil", ^{
            expect([MAETModel1 respondsToSelector:NSSelectorFromString(@"bArrayTransformer")]).to(equal(NO));
            expect([MAETModel1 respondsToSelector:@selector(arrayTransformerForKey:)]).to(equal(YES));
            expect([MAETModel1 arrayTransformerForKey:@"b"]).to(beNil());

            NSDictionary* transformers = [MAEArrayAdapter valueTransformersForModelClass:MAETModel1.class];
            expect([transformers[@"b"] transformedValue:@"true"]).to(equal(@YES));
        });
    });

    describe(@"valueByFragmentWithFormat:separatedStrings:error:", ^{
        it(@"returns nil, if the separatedString is invalid format", ^{
            NSArray* format = @[ MAEEnum(@"hoge"), MAEEnum(@"fuga") ];
            __block NSError* error = nil;

            expect([MAEArrayAdapter valueByFragmentWithFormat:format
                                             separatedStrings:@[ [[MAESeparatedString alloc] initWithCharacters:@"hoge" type:MAEStringTypeEnumerate] ]
                                                        error:&error])
                .to(beNil());
            expect(error).notTo(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorNotMatchFragmentCount));
        });

        it(@"returns valueByFragment", ^{
            NSArray* format = @[ MAEEnum(@"hoge"), MAEOptional(@"fuga"), MAEQuoted(@"piyo") ];
            __block NSError* error = nil;
            __block NSDictionary* valueByFragment = nil;

            NSArray<MAESeparatedString*>* separatedStrings = @[ [[MAESeparatedString alloc] initWithCharacters:@"hoge_value" type:MAEStringTypeEnumerate],
                                                                [[MAESeparatedString alloc] initWithCharacters:@"piyo_value"
                                                                                                          type:MAEStringTypeDoubleQuoted] ];
            expect(valueByFragment = [MAEArrayAdapter valueByFragmentWithFormat:format
                                                               separatedStrings:separatedStrings
                                                                          error:&error])
                .notTo(beNil());
            expect(valueByFragment).to(equal(@{ format[0] : separatedStrings[0],
                                                format[2] : separatedStrings[1] }));
            expect(error).to(beNil());
        });

        it(@"returns value is array with variadic", ^{
            NSArray* format = @[ MAEVariadic(@"hoge") ];
            __block NSError* error = nil;
            __block NSDictionary* valueByFragment = nil;

            NSArray<MAESeparatedString*>* separatedStrings = @[ [[MAESeparatedString alloc] initWithCharacters:@"hoge_value" type:MAEStringTypeEnumerate],
                                                                [[MAESeparatedString alloc] initWithCharacters:@"fuga_value"
                                                                                                          type:MAEStringTypeDoubleQuoted] ];
            expect(valueByFragment = [MAEArrayAdapter valueByFragmentWithFormat:format
                                                               separatedStrings:separatedStrings
                                                                          error:&error])
                .notTo(beNil());
            expect(valueByFragment).to(equal(@{ format[0] : separatedStrings }));
            expect(error).to(beNil());
        });
    });
}
QuickSpecEnd
