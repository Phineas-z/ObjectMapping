//
//  Tool.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/13/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Mapping.h"

@interface Tool : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic) float speed;

@property (nonatomic, strong) NSNumber *durability;

@property (nonatomic, strong) NSDate *createdDate;

@property (nonatomic) BOOL isNew;

@end
