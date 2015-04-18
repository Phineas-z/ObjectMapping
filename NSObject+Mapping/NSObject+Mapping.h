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

/*
 This method returns an JSON object mapped from an object. By default the corresponding key names in 
 returned JSON object are the same as object's property name. Override + (NSDictionary *)propertyDictionary;
 to customize JSON key names or exclude properties for mapping.
 
 @return The JSON object mapped from an object. If this method called on a colletion, i.e. NSArray or NSSet,
 the return value should be an array; otherwise, the return value is a dictionary.
 */

- (instancetype)JSONObject;

/*
 Override this method to intercept Object to JSON mapping for a specific property.
 In most cases, there is no need to override this method. But this method provide a chance in which you can
 customize the JSON value mapped from a property. If a property do not follow the default
 mapping rules, e.g., a property with delimiter seperated string {propertyName: @"a,b,c"} need to be mapped
 to a string array [@"a", @"b", @"c"], then should override this method for propertyName;
 
 @return The value to assign to JSON for this property.
 */

- (instancetype)JSONValueForPropertyKey:(NSString *)propertyKey;

#pragma mark - JSON to Object

/*
 Create a new instance from a JSON object.
 
 @param JSONObject The dictionary to deserialize into returned object.
 
 @return The new created instance.
 */

+ (instancetype)instanceWithJSONObject:(NSDictionary *)JSONObject;

/*
 Create an array of instances from a JSON object.
 
 @param JSONObject The JSON array to deserialize into returned object array.
 
 @return The new created array of instances.
 */

+ (NSArray *)instanceArrayWithJSONObject:(NSArray *)JSONObject;

/*
 Update properties of an already created object with JSON object.
 
 @param JSONObject The dictionary to update the properties of caller.
 */

- (void)updateWithJSONObject:(NSDictionary *)JSONObject;

/*
 Override this method to intercept JSON to Object mapping for a specific property.
 In most cases, there is no need to override this method. But this method provide a chance in which you can
 customize the property value mapped from JSON value. If a property do not follow the default
 mapping rules, e.g., map a string JSON value to number property value, then this method should be
 overriden.
 */
 
- (instancetype)propertyValueForPropertyKey:(NSString *)propertyKey withJSONValue:(id)JSONObject;

#pragma mark - Config mapping properties

/*
 This class method returns a dictionary in which keys are json keys and values are property names.
 Default return value of this class method is a dictionary with all properties of the class, and json
 keys are the same as property names.
 
 Should override this method if json keys are different from property names, or some properties should not be
 included in object mapping.
 */

+ (NSDictionary *)propertyDictionary;

/*
 This class method returns a dictionary in which keys are property names and values are Class variables.
 For example,
 {
    @"arrayPropertyName": [MyClass class]
 }
 
 Should override this method for mapping to-many relationships. The keys should be the name of property
 of NSArray or NSSet. This dictionary indicates what objects should be created in collection when mapping 
 to-many relationships from JSON.
 
 This class method is only needed for mapping JSON to Object. The default return value is an empty dictionary.
 */

+ (NSDictionary *)arrayClassMapping;

#pragma mark - Methods not to override

+ (NSString *)classNameOfProperty:(NSString *)propertyKey;

@end
