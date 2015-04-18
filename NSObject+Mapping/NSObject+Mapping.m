//
//  NSObject+Mapping.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "NSObject+Mapping.h"
#import <objc/runtime.h>

@implementation NSObject (Mapping)

#pragma mark - Object to JSON

/*
 For NSArray and NSSet, need to return an array as JSON object. Both NSArray and NSSet are treated
 as any to-many relationship.
 */
- (instancetype)JSONObject {
    // Returned JSON value could be array/dictionary
    // Support NSArray for to-many relationship
    if ([self isKindOfClass:[NSArray class]]) {
        //
        NSMutableArray *jsonObject = [NSMutableArray array];
        
        for (id arrayItem in (NSArray*)self) {
            if ([NSObject isPrimitiveType:arrayItem]) {
                [jsonObject addObject:[NSObject primitiveValueWithObject:arrayItem]];
            } else {
                [jsonObject addObject:[arrayItem JSONObject]];
            }
        }
        
        return [NSArray arrayWithArray:jsonObject];
        
    }
    
    // Currently no support for NSDictionary, ignore it
    if ([self isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    // Single object
    else {
        NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
        // Iterate property dictionary
        NSDictionary *propertyDictionary = [[self class] propertyDictionary];
        for (NSString *jsonkey in propertyDictionary) {
            // Get corresponding property key
            NSString *propertyKey = propertyDictionary[jsonkey];
            
            id jsonValue = [self JSONValueForPropertyKey:propertyKey];
            
            if (jsonValue) {
                jsonObject[jsonkey] = jsonValue;
            }
        }
        
        return [NSDictionary dictionaryWithDictionary:jsonObject];
    }
}

/*
 For each property in an object, return the desired JSON value
 */
- (instancetype)JSONValueForPropertyKey:(NSString *)propertyKey {
    id propertyValue = [self valueForKey:propertyKey];
    
    if (!propertyValue) {
        return nil;
    }
    
    if ([NSObject isPrimitiveType:propertyValue]) {
        return [NSObject primitiveValueWithObject:propertyValue];
        
    } else {
        // Nested object, nested array
        return [propertyValue JSONObject];
    }
}

/*
 Return all the properties until inherit boundary (not included).
 The default dictionary key and value are all property name.
 */
+ (NSDictionary *)propertyDictionary {
    // If called on NSObject class, return an empty dictionary
    if ([self class] == [self inheritBoundary]) {
        return @{};
    }
    
    // Add properties of self
    NSMutableDictionary *propertyDictionary = [NSMutableDictionary dictionary];
    
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(self, &count);
    for (NSInteger i = 0; i < count; i++) {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
        propertyDictionary[propertyName] = propertyName;
    }
    
    free(properties);
    
    // Should inherit properties from super class
    // Merge property dictionary from super class
    [propertyDictionary addEntriesFromDictionary:[[self superclass] propertyDictionary]];
    
    // Return the Dict
    return [NSDictionary dictionaryWithDictionary:propertyDictionary];
}

#pragma mark - JSON to Object

// Create a new instance with JSON object
+ (instancetype)instanceWithJSONObject:(NSDictionary *)JSONObject {
    // Create a new object
    id newObject = [[self alloc] init];
    
    [newObject updateWithJSONObject:JSONObject];
    
    return newObject;
}

// Create an array of instances with JSON object, which has to be an array
+ (NSArray *)instanceArrayWithJSONObject:(NSArray *)JSONObject {
    NSMutableArray *instanceArray = [NSMutableArray array];
    
    for (id arrayItem in JSONObject) {
        [instanceArray addObject:[self instanceWithJSONObject:arrayItem]];
    }
    
    return [NSArray arrayWithArray:instanceArray];
}

// Update properties of an instance with JSON object
- (void)updateWithJSONObject:(NSDictionary *)JSONObject {
    // Iterate property dictionary
    NSDictionary *propertyDictionary = [[self class] propertyDictionary];
    
    for (NSString *jsonKey in propertyDictionary) {
        id jsonValue = JSONObject[jsonKey];
        NSString *propertyKey = propertyDictionary[jsonKey];
        
        if (!jsonValue || [jsonValue isEqual:[NSNull null]]) {
            // No json value for this key, no need to translate
            continue;
        }
        
        id propertyValue = [self propertyValueForPropertyKey:propertyKey withJSONValue:jsonValue];
        
        if (propertyValue) {
            [self setValue:propertyValue forKey:propertyKey];
        }
    }
}

// For each property in an object, return property value from JSON value
- (instancetype)propertyValueForPropertyKey:(NSString *)propertyKey
                             withJSONValue:(id)JSONObject {
    // Nested array indicates to-many relationship.
    // Need to read arrayClassMapping to find out what objects should be created in array
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        Class relationClass = [[self class] arrayClassMapping][propertyKey];
        if (relationClass) {
            return [relationClass instanceArrayWithJSONObject:JSONObject];
        }
    }
    
    // Nested object indicates to-one relationship
    else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSString *className = [[self class] classNameOfProperty:propertyKey];
        if (className && ![className isEqualToString:NSStringFromClass([NSDictionary class])]) { // no support for NSDictionary
            return [NSClassFromString(className) instanceWithJSONObject:JSONObject];
        }
    }
    
    // Primitive JSON type
    else {
        // Need to check property class, if it is special case (date), need to do conversion
        NSString *className = [[self class] classNameOfProperty:propertyKey];
        if ([className isEqualToString:@"NSDate"]) {
            return [NSObject dateFromJSONValue:JSONObject];
        }
        
        // Return original value
        return JSONObject;
    }
    
    return nil;
}

// Customize this method to support to-many relationship, default empty dictionary
+ (NSDictionary *)arrayClassMapping {
    return @{};
}

#pragma mark - Utils

// Get class name of a specific property
+ (NSString *)classNameOfProperty:(NSString *)propertyKey {
    objc_property_t theProperty = class_getProperty(self, [propertyKey UTF8String]);
    
    const char *attributes = property_getAttributes(theProperty);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.*/
            NSString *typeName = [[NSString alloc] initWithData:[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] encoding:NSUTF8StringEncoding];
            return typeName;
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return @"id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSData *data = [NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4];
            NSString *className = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return className;
        }
    }
    
    return @"";
}

// Check if an object is String/Number/Date
+ (BOOL)isPrimitiveType:(id)object {
    return [object isKindOfClass:[NSString class]]
    || [object isKindOfClass:[NSNumber class]]
    || [object isKindOfClass:[NSDate class]];
}

// Map String/Number/Date to JSON value
+ (instancetype)primitiveValueWithObject:(id)object {
    if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
        return object;
    } else if ([object isKindOfClass:[NSDate class]]) {
        return [NSObject JSONValueFromDate:object];
    } else {
        NSAssert(NO, @"Never call primitive value on non-primitive object");
        return nil; // suppress compilor complaints
    }
}

// Indicate the inherit boundary below which object inherits properties
+ (Class)inheritBoundary {
    return [NSObject class];
}

// Default is linux time, could be overriden
+ (NSDate *)dateFromJSONValue:(NSNumber *)value {
    return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
}

+ (NSNumber *)JSONValueFromDate:(NSDate *)date {
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]];
}

@end
