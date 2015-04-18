//
//  Survivor.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/17/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tool.h"

@interface Survivor : NSObject

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) Tool *favoriteTool;

@property (nonatomic, strong) NSArray *tools;

@end
