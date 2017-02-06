//
//  MAETModel.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAETModel.h"

@implementation MAETModel1

#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[ @"b", @"ui", @"i", @"f", @"d" ];
}

+ (unichar)separator
{
    return ',';
}

+ (BOOL)ignoreEdgeBlank
{
    return NO;
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
