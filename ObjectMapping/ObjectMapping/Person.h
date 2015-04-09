//
//  Person.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Mapping.h"

typedef NS_ENUM(NSInteger, SEX) {
    FEMALE,
    MALE
};

@interface Person : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic) int age;

@property (nonatomic) SEX sex;

@property (nonatomic, strong) NSArray *children;

@end
