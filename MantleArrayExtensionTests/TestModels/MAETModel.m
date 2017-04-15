//
//  MAETModel.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAETModel.h"
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>

@implementation MAETModel1

#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[ @"b", @"ui", @"i", @"f", @"d", MAEOptional(@"n") ];
}

+ (unichar)separator
{
    return ',';
}

+ (BOOL)ignoreEdgeBlank
{
    return NO;
}

+ (NSValueTransformer* _Nullable)arrayTransformerForKey:(NSString* _Nonnull)key
{
    return nil;
}

@end

@implementation MAETModel2

#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[ @"a", MAEOptional(@"b"), MAEQuoted(@"c") ];
}

+ (unichar)separator
{
    return ' ';
}

+ (BOOL)ignoreEdgeBlank
{
    return NO;
}

+ (MAEArrayQuotedOptions)quotedOptions
{
    return MAEArraySingleQuotedEnable | MAEArrayDoubleQuotedEnable;
}

@end

@implementation MAETModel3

#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[
        @"requireString", MAEOptional(@"optionalString"),
        MAEVariadic(@"variadicArray")
    ];
}

+ (unichar)separator
{
    return ',';
}

+ (BOOL)ignoreEdgeBlank
{
    return YES;
}

@end

@implementation MAETModel4

#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[ @"requireString", MAEOptional(@"model3") ];
}

+ (unichar)separator
{
    return '|';
}

+ (BOOL)ignoreEdgeBlank
{
    return YES;
}

+ (NSValueTransformer* _Nullable)model3ArrayTransformer
{
    return [MAEArrayAdapter stringTransformerWithArrayModelClass:MAETModel3.class];
}

+ (NSValueTransformer* _Nullable)arrayTransformerForKey:(NSString* _Nonnull)key
{
    return nil;
}

@end

@implementation MAETModel5

#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[ MAEOptional(MAEVariadic(@"variadicArray")) ];
}

+ (unichar)separator
{
    return ' ';
}

+ (Class _Nullable)classForParsingArray:(NSArray<MAESeparatedString*>* _Nonnull)array
{
    return MAETModel4.class;
}

@end

@implementation MAETModel6

#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[ @"url", @"boolean", MAEOptional(@"empty") ];
}

+ (unichar)separator
{
    return ',';
}

+ (NSValueTransformer* _Nonnull)urlArrayTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer* _Nonnull)booleanArrayTransformer
{
    return [NSValueTransformer valueTransformerForName:NSNegateBooleanTransformerName];
}

+ (NSValueTransformer* _Nonnull)emptyArrayTransformer
{
    return [MTLValueTransformer
        transformerUsingForwardBlock:
            ^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = NO;
                if (error) {
                    *error = [NSError errorWithDomain:@"domain" code:1234 userInfo:nil];
                }
                return nil;
            }
        reverseBlock:
            ^id _Nullable(id _Nullable value, BOOL* _Nonnull success, NSError* _Nullable* _Nullable error) {
                *success = NO;
                if (error) {
                    *error = [NSError errorWithDomain:@"domain" code:1234 userInfo:nil];
                }
                return nil;
            }];
}

#pragma mark - NSObject (Override)

- (BOOL)validate:(NSError* _Nullable* _Nullable)error
{
    return YES;
}

@end
