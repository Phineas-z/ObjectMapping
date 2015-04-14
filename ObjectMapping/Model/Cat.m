//
//  Cat.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "Cat.h"
#import "Mouse.h"


@implementation Cat

@dynamic name;
@dynamic foods;

+ (NSDictionary *)collectionClassMapping {
    return @{@"foods": [Mouse class]};
}

@end
