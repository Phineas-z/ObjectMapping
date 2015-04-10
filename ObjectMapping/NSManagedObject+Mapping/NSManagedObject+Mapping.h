//
//  NSManagedObject+Mapping.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSObject+Mapping.h"

@interface NSManagedObject (Mapping)

/**
 * NSObject+Mapping already handles all the Object to JSON work, the extra work
 * we need to implement for NSManagedObject is NSManagedObject creation with MOC
 */

#pragma mark - JSON to Object

// Todo: add more NSManagedObject related functionality (object create/fetch, check existence config)
// Prone: Cycle Reference is very normal in CoreData, a easy solution to deadlock
// Relationship is set not array in NSManagedObject

- (void)updateWithJSONObject:(NSDictionary *)JSONObject
                   inContext:(NSManagedObjectContext *)context;

- (instancetype)propertyValueForPropertyKey:(NSString *)propertyKey
                             withJSONObject:(id)JSONObject
                                  inContext:(NSManagedObjectContext *)context;

+ (instancetype)instanceWithJSONObject:(NSDictionary *)JSONObject
                             inContext:(NSManagedObjectContext *)context;

+ (NSArray *)instanceArrayWithJSONObject:(NSArray *)JSONObject
                               inContext:(NSManagedObjectContext *)context;

@end
