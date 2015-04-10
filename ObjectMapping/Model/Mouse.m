//
//  Mouse.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "Mouse.h"
#import "Cat.h"


@implementation Mouse

@dynamic enemy;

+ (NSDictionary *)propertyDictionary {
    return [[self superclass] propertyDictionary];
}

@end
