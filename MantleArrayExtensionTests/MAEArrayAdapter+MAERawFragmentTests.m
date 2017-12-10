//
//  MAEArrayAdapter+MAERawFragmentTests.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/12/10.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEArrayAdapter.h"
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

typedef NS_ENUM(NSUInteger, MAETModelUsingRaw1Option) {
    MAETModelUsingRaw1OptionNone,
    MAETModelUsingRaw1OptionHead,
    MAETModelUsingRaw1OptionTail,
};

@interface MAETModelUsingRaw1 : MTLModel <MAEArraySerializing>
@property (nonatomic, nullable, copy) NSString* type;
@property (nonatomic, assign) MAETModelUsingRaw1Option option;
@end

@implementation MAETModelUsingRaw1

#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[ MAERaw(@"/command"), MAERawEither(@[ @"play", @"pause", @"seek" ]).withProperty(@"type"),
              MAEOptional(MAERawEither(@[ @"head", @"tail" ]).withProperty(@"option")) ];
}

+ (unichar)separator
{
    return ' ';
}

+ (NSValueTransformer* _Nonnull)optionArrayTransformer
{
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{ @"head" : @(MAETModelUsingRaw1OptionHead),
                                                                            @"tail" : @(MAETModelUsingRaw1OptionTail) }
                                                            defaultValue:@(MAETModelUsingRaw1OptionNone)
                                                     reverseDefaultValue:NSNull.null];
}

@end

@interface MAETModelUsingRaw2 : MTLModel <MAEArraySerializing>
@property (nonatomic, nullable, copy) NSString* name;
@end

@implementation MAETModelUsingRaw2

#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[ MAEOptional(MAERawEither(@[ @"Alice", @"Bob" ]).withProperty(@"name")) ];
}

+ (unichar)separator
{
    return ' ';
}

+ (NSValueTransformer* _Nonnull)nameArrayTransformer
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
            return value;

        }
        reverseBlock:^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
            return @"Bob";
        }];
}

@end

QuickSpecBegin(MAEArrayAdapter_MAERawFragmentTests)
{
    describe(@"convert between string and model", ^{
        it(@"can use transformer", ^{
            __block MAETModelUsingRaw1* model = nil;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModelUsingRaw1.class
                                              fromString:@"/command seek tail"
                                                   error:&error])
                .notTo(beNil());
            expect(model.type).to(equal(@"seek"));
            expect(@(model.option)).to(equal(MAETModelUsingRaw1OptionTail));
            expect(error).to(beNil());

            error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error])
                .to(equal(@"/command seek tail"));
            expect(error).to(beNil());
        });

        it(@"can use optional", ^{
            __block MAETModelUsingRaw1* model = nil;
            __block NSError* error = nil;
            expect(model = [MAEArrayAdapter modelOfClass:MAETModelUsingRaw1.class
                                              fromString:@"/command play"
                                                   error:&error])
                .notTo(beNil());
            expect(model.type).to(equal(@"play"));
            expect(@(model.option)).to(equal(MAETModelUsingRaw1OptionNone));
            expect(error).to(beNil());

            error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error])
                .to(equal(@"/command play"));
            expect(error).to(beNil());
        });

        it(@"returns error, if specified value is not one of candidates", ^{
            MAETModelUsingRaw1* model = [MAETModelUsingRaw1 new];
            model.type = @"invalid";

            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(beNil());
            expect(error.domain).to(equal(MAEErrorDomain));
            expect(error.code).to(equal(MAEErrorInvalidInputData));
        });

        it(@"does not call the transformer, when the fragment is optional and the value is nil", ^{
            MAETModelUsingRaw2* model = [MAETModelUsingRaw2 new];
            __block NSError* error = nil;
            expect([MAEArrayAdapter stringFromModel:model error:&error]).to(equal(@""));
            expect(error).to(beNil());
        });
    });
}
QuickSpecEnd
