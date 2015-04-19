//
//  Stone.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/17/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSObject+Mapping.h"

@interface Stone : NSObject

@property (nonatomic, strong) NSNumber *hardness;

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) UIColor *color;

@end
