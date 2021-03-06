//
//  NSManagedObject+Mapping.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "NSManagedObject+Mapping.h"

@implementation NSManagedObject (Mapping)

#pragma mark - Entity to JSON

/*
 Add NSSet to-many relationship support for Entity to JSON mapping.
 This override the default implementation in NSObject+Mapping.
 */
- (instancetype)JSONValueForPropertyKey:(NSString *)propertyKey {
    id propertyValue = [self valueForKey:propertyKey];
    
    if ([propertyValue isKindOfClass:[NSSet class]]) {
        return (id)[[(NSSet*)propertyValue allObjects] JSONObject];
        
    } else {
        // Inherit the implementation if it is not NSSet property
        return [super JSONValueForPropertyKey:propertyKey];
    }
}

#pragma mark - JSON to Entity

/*
 Insert or update an entity with JSON dictionary.
 */
+ (instancetype)entityWithJSONObject:(NSDictionary *)JSONObject inContext:(NSManagedObjectContext *)context {
    NSManagedObject *entity = nil;
    
    // Check if there are existing lookup properties
    if ([self lookupProperties] && [self lookupProperties].count > 0) {
        // Try to find existing entity by lookup properties
        entity = [self fetchEntityWithJSON:JSONObject
                                 inContext:context];
    }
    
    if (!entity) {
        // Create a new entity if needed
        entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
    }
    
    [entity updateWithJSONObject:JSONObject inContext:context];
    
    return entity;
}

/*
 Create an array of entities mapped from JSON array.
 */
+ (NSArray *)entityArrayWithJSONObject:(NSArray *)JSONObject inContext:(NSManagedObjectContext *)context {
    NSMutableArray *instanceArray = [NSMutableArray array];
    
    for (id arrayItem in JSONObject) {
        [instanceArray addObject:[self entityWithJSONObject:arrayItem inContext:context]];
    }
    
    return [NSArray arrayWithArray:instanceArray];
}

/*
 Update an entity with JSON object.
 */
- (void)updateWithJSONObject:(NSDictionary *)JSONObject inContext:(NSManagedObjectContext *)context {
    // Iterate property dictionary
    NSDictionary *propertyDictionary = [[self class] propertyDictionary];
    
    for (NSString *jsonKey in propertyDictionary) {
        id jsonValue = JSONObject[jsonKey];
        NSString *propertyKey = propertyDictionary[jsonKey];
        
        if (!jsonValue || [jsonValue isEqual:[NSNull null]]) {
            // No json value for this key, no need to translate
            continue;
        }
        
        id propertyValue = [self propertyValueForPropertyKey:propertyKey withJSONValue:jsonValue inContext:context];
        
        if (propertyValue) {
            [self setValue:propertyValue forKey:propertyKey];
        }
    }

}

/*
 Map a JSON value to property.
 */
- (instancetype)propertyValueForPropertyKey:(NSString *)propertyKey
                             withJSONValue:(id)JSONObject
                                  inContext:(NSManagedObjectContext *)context {
    // Get property class
    Class propertyClass = NSClassFromString([[self class] classNameOfProperty:propertyKey]);
    
    // Nested array, to-many relationship
    // For NSManagedObject, to-mant relationship could be NSSet
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        // Get the destination class of this to-many relationship
        Class relationClass = [[self class] arrayClassMapping][propertyKey];
        if (relationClass) {
            NSArray *objectArray = nil;
            // Check if relationship object is NSManagedObject
            if ([relationClass isSubclassOfClass:[NSManagedObject class]]) {
                // Initialize an array of entities
                objectArray = [relationClass entityArrayWithJSONObject:JSONObject inContext:context];
            } else {
                // Initialize an array of NSObject
                objectArray = [relationClass instanceArrayWithJSONObject:JSONObject];
            }
            
            // Check if the property class is NSSet or NSArray
            if ([propertyClass isSubclassOfClass:[NSSet class]]) {
                return (id)[NSSet setWithArray:objectArray];
            } else {
                return (id)objectArray;
            }
        }
    }
    
    // Nested object, to-one relationship
    else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        // Check if relationship object is NSManagedObject
        if ([propertyClass isSubclassOfClass:[NSManagedObject class]]) {
            return [propertyClass entityWithJSONObject:JSONObject inContext:context];
        } else {
            return [propertyClass instanceWithJSONObject:JSONObject];
        }
    }
    
    // Primitive JSON type
    else {
        // Need to check property class/type, if it is special case (date), need to do conversion
        if ([propertyClass isSubclassOfClass:[NSDate class]]) {
            return (id)[NSManagedObject dateFromJSONValue:JSONObject];
        }
        
        // Return original value
        return JSONObject;
    }
    
    return nil;
}

/*
 Default implementation is nil.
 */
+ (NSArray *)lookupProperties {
    return nil;
}

#pragma mark - Utils

/*
 Fetch existing entity with JSON and lookup properties.
 */
+ (NSManagedObject *)fetchEntityWithJSON:(NSDictionary *)JSONobject
                               inContext:(NSManagedObjectContext *)context {
    // Get reversed propertyDictionary, which maps from propertyKey to JSONKey
    NSDictionary *reversedPropertyDictionary = [self reverseDictionary:[self propertyDictionary]];
    
    // Try lookupProperties one by one
    for (NSString *propertyKey in [self lookupProperties]) {
        NSString *jsonKey = reversedPropertyDictionary[propertyKey];
        
        id jsonValue = JSONobject[jsonKey];
        
        if (!jsonValue) {
            continue;
        }
        
        // Create a fetch request
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
        fetchRequest.fetchLimit = 1; // only find one
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@", propertyKey, jsonValue];
        
        // Execute fetch
        NSError *error = nil;
        NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
        
        if (!error && results && results.lastObject) {
            return results.lastObject;
        }
    }
    
    return nil;
}

/*
 Reverse the key/value of dictionary.
 */
+ (NSDictionary *)reverseDictionary:(NSDictionary *)dict {
    NSMutableDictionary *reversedDict = [NSMutableDictionary dictionary];
    
    for (id key in dict) {
        reversedDict[dict[key]] = key;
    }
    
    return reversedDict;
}

// This method will be called to decide which properties to be inherited in default property dictionary
+ (Class)inheritBoundary {
    return [NSManagedObject class];
}

// Default is linux time, could be overriden
+ (NSDate *)dateFromJSONValue:(NSNumber *)value {
    return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
}

+ (NSNumber *)JSONValueFromDate:(NSDate *)date {
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]];
}


@end
