//
//  Animal.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Animal : NSManagedObject

@property (nonatomic) int64_t age;
@property (nonatomic) double weight;
@property (nonatomic) BOOL predator;

@end
