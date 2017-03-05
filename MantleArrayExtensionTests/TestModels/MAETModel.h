//
//  MAETModel.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/29.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEArrayAdapter.h"
#import <Foundation/Foundation.h>

@interface MAETModel1 : MTLModel <MAEArraySerializing>

@property (nonatomic, assign) BOOL b;
@property (nonatomic, assign) NSUInteger ui;
@property (nonatomic, assign) NSInteger i;
@property (nonatomic, assign) float f;
@property (nonatomic, assign) double d;

@end

@interface MAETModel2 : MTLModel <MAEArraySerializing>

@property (nonatomic, nullable, copy) NSString* a;
@property (nonatomic, nullable, copy) NSString* b;
@property (nonatomic, nullable, copy) NSString* c;

@end

@interface MAETModel3 : MTLModel <MAEArraySerializing>

@property (nonatomic, nullable, copy) NSString* requireString;
@property (nonatomic, nullable, copy) NSString* optionalString;
@property (nonatomic, nullable, copy) NSArray<NSString*>* variadicArray;

@end

@interface MAETModel4 : MTLModel <MAEArraySerializing>

@property (nonatomic, nullable, copy) NSString* requireString;
@property (nonatomic, nullable, strong) MAETModel3* model3;

+ (NSValueTransformer* _Nullable)model3ArrayTransformer;
+ (NSValueTransformer* _Nullable)arrayTransformerForKey:(NSString* _Nonnull)key;

@end

@interface MAETModel5 : MTLModel <MAEArraySerializing>

@property (nonatomic, nullable, copy) NSArray<NSString*>* variadicArray;

@end
