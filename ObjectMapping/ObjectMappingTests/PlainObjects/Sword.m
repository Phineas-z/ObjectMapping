//
//  Sword.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/17/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "Sword.h"

@implementation Sword

- (BOOL)isEqual:(id)object {
    Sword *sword = object;
    
    if (![super isEqual:object]) {
        return NO;
    }
    
    if (![self.damage isEqualToNumber:sword.damage]) {
        return NO;
    }
    
    if (self.userInfo) {
        return [self.userInfo isEqualToDictionary:sword.userInfo];
    } else {
        return !sword.userInfo;
    }
}

@end
