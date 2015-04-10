//
//  ViewController.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "ViewController.h"
#import "Teacher.h"
#import "Mouse.h"
#import "Cat.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSManagedObjectContext *moc = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    Cat *tom = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Cat class]) inManagedObjectContext:moc];
    Mouse *jerry = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Mouse class]) inManagedObjectContext:moc];
    
    jerry.age = 1;
    jerry.predator = NO;
    jerry.weight = .5;
    
    tom.food = jerry;
    tom.name = @"Tom";
    tom.weight = 5;
    tom.age = 2;
    tom.predator = YES;
    
    NSDictionary *test = [tom JSONObject];
    
    Cat *tom2 = [Cat instanceWithJSONObject:test inContext:moc];
}

@end
