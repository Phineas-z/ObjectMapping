//
//  Mouse.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Animal.h"
#import "NSManagedObject+Mapping.h"

@class Cat;

@interface Mouse : Animal

@property (nonatomic, retain) Cat *enemy;

@end
