//
//  MAEArrayAdapter.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/27.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import "MAEErrorCode.h"
#import "MAEFragment.h"
#import "MAESeparatedString.h"
#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLTransformerErrorHandling.h>

@protocol MAEArraySerializing <MTLModel>

/**
 * Specifies how to map property keys to index in Array.
 *
 * Kind of format:
 *    - @"propetyName"
 *    - MAEQuoted(@"propertyName")
 *    - MAESingleQuoted(@"propertyName")
 *    - MAEOptional(@"propertyName")
 *    - MAEVariadic(@"propertyName")
 *
 *    Please refer to MAEFragment.h
 *
 * Treatment of quoted-string:
 *    - Not limited to format, unbalanced quoted is not allowed.
 *    - While enclosed in quoted-string, separator and another quoted-string will be invalid.
 *    - While enclosed in quoted-string, you can use quoted-string by using backslash.
 *
 * Optional and Variadic:
 *    - If the number of elements does not match, it is deleted from the last optional or variadic element.
 *    - Variadic can only be used for the last element.
 *    - Variadic will be nonnull unless Optional is set. 
 *      (Conversely, if optional is set, nil is set when there is no value)
 *
 * Nested model:
 *    - You MUST be sure to specify different separator for parent and child except when using variadic.
 *
 */
+ (NSArray* _Nonnull)formatByPropertyKey;

@optional

/**
 * When it convert between model and string, it is used.
 * It unlike with NSString # componentsSeparatedByString: that the empty string is ignored.
 *
 * @see MAEArrayAdapter # modelOfClass:fromString:error:
 * @see MAEArrayAdapter # stringFromModel:error:
 */
+ (unichar)separator;

/**
 * If it is YES, the first and last spaces of the splited string are deleted.
 * If it is NO, the first and last spaces are remained.
 *
 * Default is YES.
 */
+ (BOOL)ignoreEdgeBlank;

/**
 * Specifies how to convert a Value to the given property key.
 *
 * If the receiver implements a `+<key>ArrayTransformer` method,
 * MAEArrayAdapter will use the result of that method instead.
 */
+ (NSValueTransformer* _Nullable)arrayTransformerForKey:(NSString* _Nonnull)key;

/**
 * If you want to use different classes based on parse data, you can use this.
 *
 * @param array An array that will be parsed.
 * @return a MAEArraySerializing class
 */
+ (Class _Nullable)classForParsingArray:(NSArray<MAESeparatedString*>* _Nonnull)array;

@end

@interface MAEArrayAdapter : NSObject

#pragma mark - Public Methods

/**
 * Convert to model from string
 *
 * @param modelClass MAEArraySerializing model class
 * @param string     A string
 * @param error      If it return nil, error information is saved here.
 * @return If conversion is success, it returns model object. Otherwise, it returns nil.
 */
+ (id<MAEArraySerializing> _Nullable)modelOfClass:(Class _Nonnull)modelClass
                                       fromString:(NSString* _Nullable)string
                                            error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to model from array
 *
 * @param modelClass  MAEArraySerializing model class
 * @param array       An array of string
 * @param error       If it return nil, error information is saved here.
 * @return If conversion is success, it returns model object. Otherwise, it returns nil.
 */
+ (id<MAEArraySerializing> _Nullable)modelOfClass:(Class _Nonnull)modelClass
                                        fromArray:(NSArray<NSString*>* _Nullable)array
                                            error:(NSError* _Nullable* _Nullable)error;
/**
 * Convert to string of array from model
 *
 * @param model a MAEArraySerializing model object
 * @param error If it return nil, error information is saved here.
 * @return If conversion is success, it returns an array. Otherwise, it returns nil.
 */
+ (NSArray<MAESeparatedString*>* _Nullable)arrayFromModel:(id<MAEArraySerializing> _Nullable)model
                                                    error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to string from model
 *
 * @param model a MAEArraySerializing model object
 * @param error If it return nil, error information is saved here.
 * @return If conversion is success, it returns a string. Otherwise, it returns nil.
 */
+ (NSString* _Nullable)stringFromModel:(id<MAEArraySerializing> _Nullable)model
                                 error:(NSError* _Nullable* _Nullable)error;

/**
 * @see modelOfClass:fromString:error:
 */
- (id<MAEArraySerializing> _Nullable)modelFromString:(NSString* _Nullable)string
                                               error:(NSError* _Nullable* _Nullable)error;

/**
 * @see modelOfClass:fromArray:error:
 */
- (id<MAEArraySerializing> _Nullable)modelFromArray:(NSArray<NSString*>* _Nullable)array
                                              error:(NSError* _Nullable* _Nullable)error;

/**
 * @see arrayFromModel:error:
 */
- (NSArray<MAESeparatedString*>* _Nullable)arrayFromModel:(id<MAEArraySerializing> _Nullable)model
                                                    error:(NSError* _Nullable* _Nullable)error;

/**
 * @see stringFromModel:error:
 */
- (NSString* _Nullable)stringFromModel:(id<MAEArraySerializing> _Nullable)model
                                 error:(NSError* _Nullable* _Nullable)error;

@end

@interface MAEArrayAdapter (Transformers)

/**
 * It returns a transformer for converting MAEArraySerializing modelClass and NSArray.
 * It can be used to define another model a part defined by MAEVariadic.
 *
 * @param modelClass A modelClass that conforms MAEArraySerializing
 * @return A transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    variadicTransformerWithArrayModelClass:(Class _Nonnull)modelClass;

/**
 * It returns a transformer for converting MAEArraySerializing modelClass and NSString.
 *
 * @param modelClass A modelClass that conforms MAEArraySerializing
 * @return A transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    stringTransformerWithArrayModelClass:(Class _Nonnull)modelClass;

/**
 * It returns transformer for converting between number and NSString.
 *
 * @return A transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)numberTransformer;

/**
 * It returns transformer for converting between bool and NSString.
 *
 * @return A transformer
 */
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)boolTransformer;

@end

@interface MAEArrayAdapter (Deprecated)

+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)numberStringTransformer
    __attribute__((unavailable("Replaced by numberTransformer")));
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)boolStringTransformer
    __attribute__((unavailable("Replaced by boolTransformer")));
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    arrayTransformerWithModelClass:(Class _Nonnull)modelClass
    __attribute__((unavailable("Replaced by stringTransformerWithArrayModelClass:")));
+ (NSValueTransformer<MTLTransformerErrorHandling>* _Nonnull)
    variadicArrayTransformerWithModelClass:(Class _Nonnull)modelClass
    __attribute__((unavailable("Replaced by variadicTransformerWithArrayModelClass:")));
@end
