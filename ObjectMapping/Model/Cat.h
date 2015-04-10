//
//  Cat.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Animal.h"
#import "NSManagedObject+Mapping.h"

@class Mouse;

@interface Cat : Animal

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Mouse *food;

@end