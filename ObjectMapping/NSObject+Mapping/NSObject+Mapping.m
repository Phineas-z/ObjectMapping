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

- (instancetype)JSONObject {
    // Returned JSON value could be array/dictionary
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
        
    } else {
        // Single object
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

+ (NSDictionary *)propertyDictionary {
    // If called on NSObject class, return an empty dictionary
    if ([self class] == [self rootClassForPropertyInherit]) {
        return @{};
    }
    
    // Add properties of Self
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
    [propertyDictionary addEntriesFromDictionary:[class_getSuperclass(self) propertyDictionary]];
    
    // Return the Dict
    return [NSDictionary dictionaryWithDictionary:propertyDictionary];
}

+ (BOOL)isPrimitiveType:(id)object {
    return [object isKindOfClass:[NSString class]]
        || [object isKindOfClass:[NSNumber class]]
        || [object isKindOfClass:[NSDate class]];
}

// String/Number/Date, object -> json
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

+ (Class)rootClassForPropertyInherit {
    return [NSObject class];
}

// Todo
+ (NSDate *)dateFromJSONValue:(NSNumber *)value {
    return nil;
}

+ (NSNumber *)JSONValueFromDate:(NSDate *)date {
    return nil;
}

#pragma mark - JSON to Object

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
        
        id propertyValue = [self propertyValueForPropertyKey:propertyKey withJSONObject:jsonValue];
        
        if (propertyValue) {
            [self setValue:propertyValue forKey:propertyKey];
        }
    }
}

+ (instancetype)instanceWithJSONObject:(NSDictionary *)JSONObject {
    // Create a new object
    id newObject = [[self alloc] init];
    
    [newObject updateWithJSONObject:JSONObject];
    
    return newObject;
}

+ (NSArray *)instanceArrayWithJSONObject:(NSArray *)JSONObject {
    NSMutableArray *instanceArray = [NSMutableArray array];
    
    for (id arrayItem in JSONObject) {
        [instanceArray addObject:[self instanceWithJSONObject:arrayItem]];
    }
    
    return [NSArray arrayWithArray:instanceArray];
}

- (instancetype)propertyValueForPropertyKey:(NSString *)propertyKey
                             withJSONObject:(id)JSONObject {
    // Nested array, need to read array-class mapping
    // to-many relationship
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        Class relationClass = [[self class] arrayClassMapping][propertyKey];
        if (relationClass) {
            return [relationClass instanceArrayWithJSONObject:JSONObject];
        }
    }
    
    // Nested object
    // to-one relationship
    else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSString *className = [[self class] classNameOfProperty:propertyKey];
        if (className) {
            return [NSClassFromString(className) instanceWithJSONObject:JSONObject];
        }
    }
    
    // Plain String/Number/Bool, correspond to String/Number/Date, i.e. primitive type
    else {
        // Need to check property class/type, if it is special case (date), need to do conversion
        NSString *className = [[self class] classNameOfProperty:propertyKey];
        if ([className isEqualToString:@"NSDate"]) {
            return [NSObject dateFromJSONValue:JSONObject];
        }
        
        // Return original value
        return JSONObject;
    }
    
    return nil;
}

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

// Customize this method to support to-many relationship
+ (NSDictionary *)arrayClassMapping {
    return @{};
}

@end
