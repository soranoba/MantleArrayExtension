//
//  MAERawFragment.m
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/12/09.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAERawFragment.h"
#import "NSError+MAEErrorCode.h"

extern MAERawFragment* _Nonnull MAERaw(NSString* _Nonnull rawString)
{
    return [[MAERawFragment alloc] initWithRawStrings:@[ rawString ]];
}

extern MAERawFragment* _Nonnull MAERawEither(NSArray<NSString*>* _Nonnull rawStrings)
{
    return [[MAERawFragment alloc] initWithRawStrings:rawStrings];
}

@interface MAERawFragment ()
@property (nonatomic, nullable, copy, readwrite) NSString* propertyName;
@property (nonatomic, assign, readwrite, getter=isOptional) BOOL optional;
@property (nonatomic, assign, readwrite, getter=isVariadic) BOOL variadic;
@property (nonatomic, nonnull, copy, readwrite) NSArray<NSString*>* rawStrings;
@end

@implementation MAERawFragment

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    NSAssert(NO, @"%@ MUST be initialized with designated initializer", self.class);
    return nil;
}

- (instancetype _Nonnull)initWithRawStrings:(NSArray<NSString*>* _Nonnull)rawStrings
{
    NSParameterAssert(rawStrings != nil);
    NSAssert(rawStrings.count > 0, @"rawStrings MUST NOT empty");

    if (self = [super init]) {
        self.rawStrings = rawStrings;
    }
    return self;
}

#pragma mark - Public Methods

- (MAERawFragment* _Nonnull (^_Nonnull)(NSString* _Nullable propertyName))withProperty
{
    return ^(NSString* _Nullable propertyName) {
        self.propertyName = propertyName;
        return self;
    };
}

#pragma mark - MAEFragment

- (MAESeparatedString* _Nullable)separatedStringFromTransformedValue:(NSString* _Nullable)transformedValue
                                                               error:(NSError* _Nullable* _Nullable)error
{
    if (transformedValue == nil) {
        return [[MAESeparatedString alloc] initWithOriginalCharacters:self.rawStrings.firstObject ignoreEdgeBlank:NO];
    } else if ([self.rawStrings containsObject:transformedValue]) {
        return [[MAESeparatedString alloc] initWithOriginalCharacters:transformedValue ignoreEdgeBlank:NO];
    } else {
        SET_ERROR(error, MAEErrorInvalidInputData,
                  @{ NSLocalizedFailureReasonErrorKey :
                         format(@"expected one of %@, but got %@", self.rawStrings, transformedValue) });
        return nil;
    }
}

- (BOOL)validateWithSeparatedString:(MAESeparatedString* _Nonnull)separatedString
                              error:(NSError* _Nullable* _Nullable)error
{
    if (![self.rawStrings containsObject:separatedString.originalCharacters]) {
        SET_ERROR(error, MAEErrorInvalidInputData,
                  @{ NSLocalizedFailureReasonErrorKey :
                         format(@"expected one of %@, but got %@", self.rawStrings, separatedString.originalCharacters) });
        return NO;
    }
    return YES;
}

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    return format(@"<%@ : candidates=(%@), property=%@>", self.class,
                  [self.rawStrings componentsJoinedByString:@","], self.propertyName);
}

@end
