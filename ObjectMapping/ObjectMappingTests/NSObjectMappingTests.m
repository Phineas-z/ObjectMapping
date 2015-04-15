//
//  NSObjectMappingTests.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/13/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tool.h"

/**
 * The classes used to test is from the scenario of MineCraft game, and also
 * straight forward
 */

@interface NSObjectMappingTests : XCTestCase

@end

@implementation NSObjectMappingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 * Basic test for NSObject+Mapping, the test object only have primitive JSON type properties
 */

- (void)testPrimitiveJSONTypes {
    // Create a tool object
    Tool *firstTool = [[Tool alloc] init];
    
    // Define attributes
    NSString *name = @"Stick";
    float speed = 34.5;
    NSNumber *durability = @20;
    NSDate *createdDate = [NSDate date];
    BOOL isNew = YES;
    
    // Assign value to object properties
    firstTool.name = name;
    firstTool.speed = speed;
    firstTool.durability = durability;
    firstTool.createdDate = createdDate;
    firstTool.isNew = isNew;
    
    // Object -> JSON
    NSDictionary *JSONObject =  (NSDictionary*)[firstTool JSONObject];
    
    // Verify JSONObject has and only has corresponding correct key/value pairs
    XCTAssertEqualObjects(JSONObject[@"name"], name, @"name not match");
    XCTAssertEqualObjects(JSONObject[@"speed"], [NSNumber numberWithFloat:speed], @"speed not match");
    XCTAssertEqualObjects(JSONObject[@"durability"], durability, @"durability not match");
    XCTAssertEqualObjects(JSONObject[@"createdDate"], [Tool JSONValueFromDate:createdDate], @"date not match");
    XCTAssertEqualObjects(JSONObject[@"isNew"], [NSNumber numberWithBool:isNew], @"isNew not match");
    // Only have corresponding keys
    XCTAssertEqual([JSONObject allKeys].count, 5, @"json key not mapping to properties");
    
    // JSON -> Object
    Tool *clonedFirstTool = [Tool instanceWithJSONObject:JSONObject];
    
    // Verify clonedFirstTool has and only has corresponding correct properties
    XCTAssertEqualObjects(clonedFirstTool.name, name, @"name not match");
    XCTAssertEqual(clonedFirstTool.speed, speed, @"speed not match");
    XCTAssertEqualObjects(clonedFirstTool.durability, durability, @"durability not match");
    XCTAssertEqual([clonedFirstTool.createdDate timeIntervalSince1970], [createdDate timeIntervalSince1970], @"date not match");
    XCTAssertEqual(clonedFirstTool.isNew, isNew, @"isNew not match");
}

@end
