//
//  NSManagedObject+Mapping.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSObject+Mapping.h"

/*
 NSManagedObject+Mapping has dependency on NSObject+Mapping. Extra work include:
 1. add NSManagedObjectContext as interface parameter
 2. support NSSet for to-many relationship
 3. support updating existing entities
 */

@interface NSManagedObject (Mapping)

#pragma mark - JSON to Object

/*
 Insert an entity or update an existing entity from a JSON object.
 Whether or not insert a new entity depends on the return value of class method + (NSArray *)lookupProperties;,
 If the return value is nil or empty array, then this method will insert a new entity immediately. Otherwise,
 it will first check if there is any existing entity by lookup properties, a new entity would only be inserted when
 there is no match.
 
 @param JSONObject The JSON dictionary to deserialize into returned entity.
 @param context The NSManagedObjectContexts to insert or update entities.
 
 @return an updated or new inserted entity
 */

+ (instancetype)entityWithJSONObject:(NSDictionary *)JSONObject
                           inContext:(NSManagedObjectContext *)context;

/*
 Create an array of entities from JSON object. For each NSManagedObject in returned array, it could be inserted 
 when there is no match with lookup properties, or fetched and updated otherwise.
 
 @param JSONObject The JSON array to deserialize into an array of entities.
 @param context The NSManagedObjectContexts to insert or update entities.
 
 @return an array of entities
 */

+ (NSArray *)entityArrayWithJSONObject:(NSArray *)JSONObject
                             inContext:(NSManagedObjectContext *)context;

/*
 Update properties of an entity with JSONObject and NSManagedObjectContext.
 
 @param JSONObject The JSON object to update the properties of caller.
 @param context The NSManagedObjectContext to update entity and create/fetch relationship entities.
 */

- (void)updateWithJSONObject:(NSDictionary *)JSONObject
                   inContext:(NSManagedObjectContext *)context;

/*
 Override this method to intercept JSON to entity property by property. In most cases, there is no need for
 overriding this method. But if a property does not conforms to JSON mapping rules, then this method should
 be overriden to handle that property mapping.
 
 @param propertyKey The property name to be mapped from JSON value.
 @param JSONValue The JSON value to be mapped into property value.
 @param context The NSManagedObjectContext ot update entity and create/fetch relationship entities.
 
 @return the value to be assigned to that property
 */

- (instancetype)propertyValueForPropertyKey:(NSString *)propertyKey
                             withJSONValue:(id)JSONValue
                                  inContext:(NSManagedObjectContext *)context;

/*
 LookupProperties control whether mapping process create new entities from JSON. A common use case for mapping JSON
 to NSManagedObject is that update the existing entity property values with JSON if it was already in storage, and 
 if not create a new entity from JSON. 
 If lookupProperties is nil, then always create new entity when mapping from JSON. Otherwise, JSON to entity mapping 
 process will first try to find existing entity which matches one of the property, and update it with JSON.
 
 @return an array of NSString. For example, @[ @"personID", @"name" ] asks the JSON to entity mapping process should
 check if there is an entity with same personID or name as those in JSON. And only create an new entity when there is
 not such matching entity.
 
 The default implementation is nil, meaning that it will always create new entity.
 */
+ (NSArray *)lookupProperties;

@end
