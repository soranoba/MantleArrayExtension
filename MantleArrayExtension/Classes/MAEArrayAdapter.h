//
//  MAEArrayAdapter.h
//  MantleArrayExtension
//
//  Created by Hinagiku Soranoba on 2017/01/27.
//  Copyright © 2017年 Hinagiku Soranoba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>

@protocol MAEArraySerializing <MTLModel>

/**
 * Specifies how to map property keys to index in Array.
 *
 * ------ 1st case -----
 *
 * Input Data
 *      ./command "format" argA argB "argC"
 *
 * ```
 * @property (nonatomic, nullable, copy) NSString* command;               // @"./command"
 * @property (nonatomic, nullable, copy) NSString* format;                // @"format"
 * @property (nonatomic, nullable, copy) NSArray<NSString*>* arguments;   // @[@"argA", @"argB", @"argC"]
 *
 * ```
 *
 * ```
 * + (NSArray _Nonnull)formatByPropertyKey
 * {
 *     return @[ @"command", MAEQuoted(@"format"), MAEVariadic(MAEMaybeQuoted(@"args")) ];
 * }
 * ```
 *
 * ----- 2nd case -----
 *
 * Input Data
 *      2017-01-27T01:00:00 MAEArraySerializing:+formatByPropertyKey:20 message
 *
 * ```
 * @property (nonatomic, nullable, strong) NSDate* date;     // 2017-01-27T01:00:00
 * @property (nonatomic, nullable, strong) Model* location;
 * @property (nonatomic, nullable, strong) NSString* msg;    // @"message"
 * ```
 *
 * ```
 * + (NSArray _Nonnull)formatByPropertyKey
 * {
 *     return @[ @"date", @"location", @"msg" ];
 * }
 * ```
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
+ (NSString* _Nonnull)separator;

/**
 * If it is YES, empty strings is removed when it split string with separator.
 * If it is NO, empty strings is remained.
 *
 * Default is YES.
 */
+ (BOOL)ignoreEmptyString;

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
+ (Class _Nullable)classForParsingArray:(NSArray<NSString*>* _Nonnull)array;

@end

@interface MAEArrayAdapter : NSObject

#pragma mark - Conversion between Array and Model

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
                                            error:(NSError* _Nullable *_Nullable)error;
/**
 * Convert to string of array from model
 *
 * @param model a MAEArraySerializing model object
 * @param error If it return nil, error information is saved here.
 * @return If conversion is success, it returns an array. Otherwise, it returns nil.
 */
+ (NSArray<NSString*>* _Nullable)arrayFromModel:(id<MAEArraySerializing> _Nullable)model
                                          error:(NSError* _Nullable* _Nullable)error;

/**
 * Convert to string from model
 *
 * @param model a MAEArraySerializing model object
 * @param error If it return nil, error information is saved here.
 * @return If conversion is success, it returns a string. Otherwise, it returns nil.
 */
+ (NSString* _Nullable)stringFromModel:(id<MAEArraySerializing> _Nullable)model
                                 error:(NSError* _Nullable *_Nullable)error;

@end
