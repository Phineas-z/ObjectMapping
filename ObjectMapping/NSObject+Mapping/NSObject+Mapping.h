//
//  NSObject+Mapping.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Mapping)

#pragma mark - Object to JSON
- (instancetype)JSONObject;

// Intercept for key translation
- (instancetype)JSONValueForPropertyKey:(NSString *)propertyKey;

// Default implementation automatically generate all properties with same names as JSON key.
// Use this method to customize key mapping
// JSONKey: PropertyKey
+ (NSDictionary *)propertyDictionary;

+ (NSDate *)dateFromJSONValue:(NSNumber *)value;

+ (NSNumber *)JSONValueFromDate:(NSDate *)date;

// Todo:
// JSON data, JSON string, dictionary support, error handle, Class method call

#pragma mark - JSON to Object

- (void)updateWithJSONObject:(NSDictionary *)JSONObject;

- (instancetype)propertyValueForPropertyKey:(NSString *)propertyKey withJSONObject:(id)JSONObject;

+ (instancetype)instanceWithJSONObject:(NSDictionary *)JSONObject;

+ (NSArray *)instanceArrayWithJSONObject:(NSArray *)JSONObject;

// PropertyKey: Class
// Represent to-many relationship
+ (NSDictionary *)arrayClassMapping;

+ (NSString *)classNameOfProperty:(NSString *)propertyKey;

@end
