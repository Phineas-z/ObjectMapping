//
//  Teacher.h
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "Person.h"
#import "NSObject+Mapping.h"

@interface Teacher : Person

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) Teacher *dean;

@end
