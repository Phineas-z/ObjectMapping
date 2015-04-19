//
//  Stone.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/17/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "Stone.h"

@implementation Stone

+ (NSDictionary *)propertyDictionary {
    return @{
             @"stone_hard": @"hardness",
             @"stone_type": @"type"
             };
}

- (BOOL)isEqual:(id)object {
    Stone *stone = object;
    
    if (self == stone) {
        return YES;
    }
    
    if (![self.hardness isEqualToNumber:stone.hardness]) {
        return NO;
    }
    
    if (![self.type isEqualToString:stone.type]) {
        return NO;
    }
    
    return [self.color isEqual:stone.color];
}

@end
