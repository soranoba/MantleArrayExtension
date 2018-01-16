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
    return [[MAERawFragment alloc] initWithCandidates:@[ rawString ]];
}

extern MAERawFragment* _Nonnull MAERawEither(NSArray<NSString*>* _Nonnull candidates)
{
    return [[MAERawFragment alloc] initWithCandidates:candidates];
}

@interface MAERawFragment ()
@property (nonatomic, nullable, copy, readwrite) NSString* propertyName;
@property (nonatomic, assign, readwrite, getter=isOptional) BOOL optional;
@property (nonatomic, assign, readwrite, getter=isVariadic) BOOL variadic;
@property (nonatomic, nonnull, copy, readwrite) NSArray<NSString*>* candidates;
@end

@implementation MAERawFragment

#pragma mark - Lifecycle

- (instancetype _Nullable)init
{
    NSAssert(NO, @"%@ MUST be initialized with designated initializer", self.class);
    return nil;
}

- (instancetype _Nonnull)initWithCandidates:(NSArray<NSString*>* _Nonnull)candidates
{
    NSParameterAssert(candidates != nil);
    NSAssert(candidates.count > 0, @"candidates MUST NOT empty");

    if (self = [super init]) {
        self.candidates = candidates;
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
        return [[MAESeparatedString alloc] initWithOriginalCharacters:self.candidates.firstObject ignoreEdgeBlank:NO];
    } else if ([self.candidates containsObject:transformedValue]) {
        return [[MAESeparatedString alloc] initWithOriginalCharacters:transformedValue ignoreEdgeBlank:NO];
    } else {
        SET_ERROR(error, MAEErrorInvalidInputData,
                  @{ NSLocalizedFailureReasonErrorKey :
                         format(@"expected one of (%@), but got %@", [self.candidates componentsJoinedByString:@", "], transformedValue) });
        return nil;
    }
}

- (BOOL)validateWithSeparatedString:(MAESeparatedString* _Nonnull)separatedString
                              error:(NSError* _Nullable* _Nullable)error
{
    if (![self.candidates containsObject:separatedString.originalCharacters]) {
        SET_ERROR(error, MAEErrorInvalidInputData,
                  @{ NSLocalizedFailureReasonErrorKey :
                         format(@"expected one of (%@), but got %@", [self.candidates componentsJoinedByString:@", "], separatedString.originalCharacters) });
        return NO;
    }
    return YES;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone* _Nullable)zone
{
    return self;
}

#pragma mark - NSObject (Override)

- (NSString* _Nonnull)description
{
    return format(@"<%@ : candidates=(%@), property=%@>", self.class,
                  [self.candidates componentsJoinedByString:@","], self.propertyName);
}

@end
