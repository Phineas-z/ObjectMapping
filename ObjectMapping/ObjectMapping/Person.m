//
//  Person.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "Person.h"

@implementation Person

+ (NSDictionary *)arrayClassMapping {
    return @{@"children": [Person class]};
}

@end
