//
//  Tool.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/13/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "Tool.h"

@implementation Tool

- (BOOL)isEqual:(id)object {
    Tool *tool = object;
    
    if (self == tool) {
        return YES;
    }
    
    //
    if (![self.name isEqualToString:tool.name]) {
        return NO;
    }
    
    if (self.speed != tool.speed) {
        return NO;
    }
    
    if (![self.durability isEqualToNumber:tool.durability]) {
        return NO;
    }
    
    return self.isNew == tool.isNew;
}

- (NSUInteger)hash {
    return (NSUInteger)self.speed;
}

@end
