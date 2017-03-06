//
//  MAEArrayAdapter+Transformers.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/03/05.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEArrayAdapter.h"
#import "NSError+MAEErrorCode.h"
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation MAEArrayAdapter (Transformers)

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    variadicArrayTransformerWithModelClass:(Class _Nonnull)modelClass
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^id _Nullable(NSArray* _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                if (!value) {
                    *success = YES;
                    return nil;
                }

                if (![value isKindOfClass:NSArray.class]) {
                    SET_ERROR(error, MAEErrorInvalidInputData,
                              @{ NSLocalizedFailureReasonErrorKey :
                                     format(@"arrayTransformerWithModelClass only support NSArray, but got %@", value.class),
                                 MAEErrorInputDataKey : value });
                    *success = NO;
                    return nil;
                }
                id model = [self modelOfClass:modelClass fromArray:value error:error];
                *success = model != nil;
                return model;
            }
        reverseBlock:
            ^NSArray* _Nullable(MTLModel<MAEArraySerializing>* _Nullable value, BOOL* _Nonnull success,
                                NSError* _Nullable* _Nullable error) {
                if (!value) {
                    *success = YES;
                    return nil;
                }

                if (!([value isKindOfClass:MTLModel.class] &&
                      [value conformsToProtocol:@protocol(MAEArraySerializing)])) {
                    SET_ERROR(error, MAEErrorInvalidInputData,
                              @{ NSLocalizedFailureReasonErrorKey :
                                     format(@"arrayTransformerWithModelClass only support MAEArraySerializing MTLModel, but got %@",
                                            value.class),
                                 MAEErrorInputDataKey : value });
                    *success = NO;
                    return nil;
                }

                NSArray* array = [self arrayFromModel:value error:error];
                *success = array != nil;
                return array;
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    arrayTransformerWithModelClass:(Class _Nonnull)modelClass
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^id _Nullable(NSString* _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                if (!value) {
                    *success = YES;
                    return nil;
                }

                if (![value isKindOfClass:NSString.class]) {
                    SET_ERROR(error, MAEErrorInvalidInputData,
                              @{ NSLocalizedFailureReasonErrorKey :
                                     format(@"arrayTransformerWithModelClass only support NSString, but got %@", value.class),
                                 MAEErrorInputDataKey : value });
                    *success = NO;
                    return nil;
                }
                id model = [self modelOfClass:modelClass fromString:value error:error];
                *success = model != nil;
                return model;
            }
        reverseBlock:
            ^NSString* _Nullable(MTLModel<MAEArraySerializing>* _Nullable value, BOOL* _Nonnull success,
                                 NSError* _Nullable* _Nullable error) {
                if (!value) {
                    *success = YES;
                    return nil;
                }

                if (!([value isKindOfClass:MTLModel.class] &&
                      [value conformsToProtocol:@protocol(MAEArraySerializing)])) {
                    SET_ERROR(error, MAEErrorInvalidInputData,
                              @{ NSLocalizedFailureReasonErrorKey :
                                     format(@"arrayTransformerWithModelClass only support MAEArraySerializing MTLModel, but got %@",
                                            value.class),
                                 MAEErrorInputDataKey : value });
                    *success = NO;
                    return nil;
                }

                NSString* str = [self stringFromModel:value error:error];
                *success = str != nil;
                return str;
            }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)numberTransformer
{
    NSNumberFormatter* formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.usesGroupingSeparator = NO;
    formatter.maximumSignificantDigits = 15; // Number of digits that can be represented by double.

    return [MTLValueTransformer mtl_transformerWithFormatter:formatter forObjectClass:NSNumber.class];
}

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)boolTransformer
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^NSNumber* _Nullable(NSString* _Nullable str, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = YES;
                if (!str) {
                    return nil;
                }
                if (![str isKindOfClass:NSString.class]) {
                    SET_ERROR(error, MAEErrorInvalidInputData,
                              @{ NSLocalizedFailureReasonErrorKey :
                                     format(@"Input data expected a numeric string, but got %@.", str.class),
                                 MAEErrorInputDataKey : str });
                    *success = NO;
                    return nil;
                }
                return [NSNumber numberWithBool:[str boolValue]];
            }
        reverseBlock:^NSString* _Nullable(NSNumber* _Nullable num, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
            *success = YES;
            if (!num) {
                return nil;
            }
            if (![num isKindOfClass:NSNumber.class]) {
                SET_ERROR(error, MAEErrorInvalidInputData,
                          @{ NSLocalizedFailureReasonErrorKey :
                                 format(@"Input data expected NSNumber, but got %@", num.class),
                             MAEErrorInputDataKey : num });
                *success = NO;
                return nil;
            }
            return [num integerValue] ? @"true" : @"false";
        }];
}

@end
