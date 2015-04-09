//
//  ViewController.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/9/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import "ViewController.h"
#import "Teacher.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    Teacher *dean = [[Teacher alloc] init];
    dean.name = @"Ham";
    dean.age = 50;
    dean.children = @[];
    dean.title = @"Dean";
    dean.sex = MALE;
    
    Person *son = [[Person alloc] init];
    son.name = @"Son";
    son.sex = MALE;
    son.age = 14;
    
    Person *daughter = [[Person alloc] init];
    daughter.name = @"Daughter";
    daughter.sex = FEMALE;
    daughter.age = 15;
    
    Teacher *alice = [[Teacher alloc] init];
    alice.name = @"Alice";
    alice.age = 25;
    alice.sex = FEMALE;
    alice.title = @"Professor";
    alice.children = @[son, daughter];
    alice.dean = dean;
    
    NSDictionary *test = [alice JSONObject];
    
    Teacher *backTest = [Teacher instanceWithJSONObject:test];
}

@end
