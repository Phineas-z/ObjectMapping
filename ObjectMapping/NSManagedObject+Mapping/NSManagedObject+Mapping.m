//
//  NSManagedObject+Mapping.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "NSManagedObject+Mapping.h"

@implementation NSManagedObject (Mapping)

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
        
        id propertyValue = [self propertyValueForPropertyKey:propertyKey withJSONObject:jsonValue inContext:context];
        
        if (propertyValue) {
            [self setValue:propertyValue forKey:propertyKey];
        }
    }

}

- (instancetype)propertyValueForPropertyKey:(NSString *)propertyKey
                             withJSONObject:(id)JSONObject
                                  inContext:(NSManagedObjectContext *)context {
    // Nested array, need to read array-class mapping
    // to-many relationship
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        Class relationClass = [[self class] arrayClassMapping][propertyKey];
        if (relationClass) {
            return (id)[relationClass instanceArrayWithJSONObject:JSONObject inContext:context];
        }
    }
    
    // Nested object
    // to-one relationship
    else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSString *className = [[self class] classNameOfProperty:propertyKey];
        if (className) {
            return [NSClassFromString(className) instanceWithJSONObject:JSONObject inContext:context];
        }
    }
    
    // Plain String/Number/Bool, correspond to String/Number/Date, i.e. primitive type
    else {
        // Need to check property class/type, if it is special case (date), need to do conversion
        NSString *className = [[self class] classNameOfProperty:propertyKey];
        if ([className isEqualToString:@"NSDate"]) {
            return (id)[NSObject dateFromJSONValue:JSONObject];
        }
        
        // Return original value
        return JSONObject;
    }
    
    return nil;
}

+ (instancetype)instanceWithJSONObject:(NSDictionary *)JSONObject inContext:(NSManagedObjectContext *)context {
    // Create a new object
    // Not every object is NSManagedObject, the creation of object should be taken care
    id newObject = nil;
    if ([[self class] isSubclassOfClass:[NSManagedObject class]]) {
        newObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self) inManagedObjectContext:context];
    } else {
        newObject = [[self alloc] init];
    }
    
    [newObject updateWithJSONObject:JSONObject inContext:context];
    
    return newObject;
}

+ (NSArray *)instanceArrayWithJSONObject:(NSArray *)JSONObject inContext:(NSManagedObjectContext *)context {
    NSMutableArray *instanceArray = [NSMutableArray array];
    
    for (id arrayItem in JSONObject) {
        [instanceArray addObject:[self instanceWithJSONObject:arrayItem inContext:context]];
    }
    
    return [NSArray arrayWithArray:instanceArray];
}

+ (Class)rootClassForPropertyInherit {
    return [NSManagedObject class];
}

@end
