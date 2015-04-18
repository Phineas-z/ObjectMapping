//
//  Survivor.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/17/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "Survivor.h"

@implementation Survivor

// Define class for to-many relationship
+ (NSDictionary *)arrayClassMapping {
    return @{@"tools": [Tool class]};
}

- (BOOL)isEqual:(id)object {
    Survivor *survivor = object;
    
    
    if (self == survivor) {
        return YES;
    }
    
    if (![self.favoriteTool isEqual:survivor.favoriteTool]) {
        return NO;
    }
    
    if (self.tools) {
        return [self.tools isEqualToArray:survivor.tools];
    } else {
        return !survivor.tools;
    }
}

- (NSUInteger)hash {
    return [self.favoriteTool hash];
}

@end
