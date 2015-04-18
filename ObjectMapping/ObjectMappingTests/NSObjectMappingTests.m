//
//  NSObjectMappingTests.m
//  ObjectMapping
//
//  Created by Yuanshuo Lu on 4/13/15.
//  Copyright (c) 2015 Yuanshuo Lu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Tool.h"
#import "Survivor.h"
#import "Sword.h"

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

/*
 Test mapping object which only has primitive JSON type properties. Test both object to JSON and reverse.
 */

- (void)testPrimitiveJSONTypes {
    // Create a tool object
    Tool *firstTool = [[Tool alloc] init];
    
    firstTool.name = @"Stick";
    firstTool.speed = 34;
    firstTool.durability = @20;
    firstTool.isNew = YES;
    
    // Object -> JSON
    NSDictionary *JSONObject =  (NSDictionary*)[firstTool JSONObject];
    
    // Verify JSONObject has and only has corresponding correct key/value pairs
    XCTAssertEqualObjects(JSONObject[@"name"], firstTool.name, @"name not match");
    XCTAssertEqualObjects(JSONObject[@"speed"], [NSNumber numberWithFloat:firstTool.speed], @"speed not match");
    XCTAssertEqualObjects(JSONObject[@"durability"], firstTool.durability, @"durability not match");
    XCTAssertEqualObjects(JSONObject[@"isNew"], [NSNumber numberWithBool:firstTool.isNew], @"isNew not match");
    // Only have corresponding keys
    XCTAssertEqual([JSONObject allKeys].count, 4, @"json key not mapping to properties");
    
    // JSON -> Object
    Tool *clonedFirstTool = [Tool instanceWithJSONObject:JSONObject];
    
    // Verify clonedFirstTool has and only has corresponding correct properties
    XCTAssertTrue([clonedFirstTool isEqual:firstTool], @"Tool mapped from JSON not match");
}

/*
 Test mapping object with to-one relationships
 */

- (void)testToOneRelationship {
    // Create a tool object
    Tool *axe = [[Tool alloc] init];
    
    axe.name = @"Axe";
    axe.speed = 20;
    axe.durability = @24;
    axe.isNew = NO;
    
    // Create a survivor
    Survivor *survivor = [[Survivor alloc] init];
    survivor.name = @"Jerry";
    survivor.favoriteTool = axe;
    
    // Object -> JSON
    NSDictionary *JSONObject = (NSDictionary*)[survivor JSONObject];
    
    // Verify JSON
    XCTAssertEqual(JSONObject[@"name"], survivor.name, @"name not match");
    XCTAssertTrue([JSONObject[@"favoriteTool"] isEqualToDictionary:(NSDictionary*)[axe JSONObject]], @"favriteTool not match");
    
    // JSON -> Object
    Survivor *clonedSurvivor = [Survivor instanceWithJSONObject:JSONObject];
    
    // Verify clonedSurvivor
    XCTAssertTrue([clonedSurvivor isEqual:survivor], @"Survivor mapped from JSON not match");
}

/*
 Test mapping object with to-many relationships
*/

- (void)testToManyRelationship {
    // Create tools
    Tool *axe = [[Tool alloc] init];
    axe.name = @"Axe";
    axe.speed = 20;
    axe.durability = @24;
    axe.isNew = NO;
    
    Tool *stick = [[Tool alloc] init];
    stick.name = @"Stick";
    stick.speed = 34;
    stick.durability = @20;
    stick.isNew = YES;
    
    // Create survivor with to-many relationships to tool
    Survivor *survivor = [[Survivor alloc] init];
    survivor.favoriteTool = axe;
    survivor.tools = @[axe, stick];
    survivor.name = @"Jerry";
    
    // Object to JSON
    NSDictionary *survivorJSON = (NSDictionary*)[survivor JSONObject];

    // Verity survivorJSON
    NSDictionary *groundTruth = @{
                                  @"name": @"Jerry",
                                  @"favoriteTool": @{
                                        @"name": @"Axe",
                                        @"speed": @20,
                                        @"durability": @24,
                                        @"isNew": @NO
                                    },
                                  @"tools": @[
                                          @{
                                              @"name": @"Axe",
                                              @"speed": @20,
                                              @"durability": @24,
                                              @"isNew": @NO
                                              },
                                          @{
                                              @"name": @"Stick",
                                              @"speed": @34,
                                              @"durability": @20,
                                              @"isNew": @YES
                                              }
                                    ]
                                  };
    
    XCTAssertTrue([survivorJSON isEqualToDictionary:groundTruth], @"JSON mapping incorrect");
    
    // JSON -> Object
    Survivor *clonedSurvivor = [Survivor instanceWithJSONObject:survivorJSON];
    
    // Verify clonedSurvivor
    XCTAssertTrue([clonedSurvivor isEqual:survivor], @"Survivor mapped from JSON incorrect");
}

/*
 Test property inheritance
 */

- (void)testPropertyInheritance {
    // Create a sword, which is a subclass of tool
    Sword *sword = [[Sword alloc] init];
    sword.damage = @11;
    sword.name = @"Sword";
    sword.speed = 24;
    sword.durability = @44;
    sword.isNew = @YES;
    
    // Object to JSON
    NSDictionary *swordJSON = (NSDictionary*)[sword JSONObject];
    
    // Verify swordJSON
    NSDictionary *groundTruth = @{
                                  @"damage": @11,
                                  @"name": @"Sword",
                                  @"speed": @24,
                                  @"durability": @44,
                                  @"isNew": @YES
                                  };
    
    XCTAssertTrue([swordJSON isEqualToDictionary:groundTruth], @"Object to JSON mapping incorrect");
    
    // JSON to Object
    Sword *clonedSword = [Sword instanceWithJSONObject:swordJSON];
    
    // Verify clonedSword
    XCTAssertTrue([clonedSword isEqual:sword], @"JSON to Object mapping incorrect");
}

/*
 Test mapping of NSArray
 */

- (void)testArrayMapping {
    // Create tools
    Tool *axe = [[Tool alloc] init];
    axe.name = @"Axe";
    axe.speed = 20;
    axe.durability = @24;
    axe.isNew = NO;
    
    Tool *stick = [[Tool alloc] init];
    stick.name = @"Stick";
    stick.speed = 34;
    stick.durability = @20;
    stick.isNew = YES;
    
    NSArray *tools = @[stick, axe];
    
    // Object ot JSON
    NSArray *toolsJSON = [tools JSONObject];
    
    // Verity toolsJSON
    NSArray *groundTruth = @[
                             @{
                                 @"name": @"Stick",
                                 @"speed": @34,
                                 @"durability": @20,
                                 @"isNew": @YES
                                 },
                             @{
                                 @"name": @"Axe",
                                 @"speed": @20,
                                 @"durability": @24,
                                 @"isNew": @NO
                                 }
                             ];

    XCTAssertTrue([toolsJSON isEqualToArray:groundTruth], @"Object to JSON mapping incorrect");
    
    // JSON to Object
    NSArray *clonedTools = [Tool instanceArrayWithJSONObject:toolsJSON];
    
    // Verify clonedTools
    XCTAssertTrue([clonedTools isEqualToArray:tools], @"JSON to Object mapping incorrect");
}

/*
 Test customize JSON key name
 */

/*
 Test intercept a specific property mapping
 */

/*
 Test mapping object with NSDictionary property
 */

- (void)testDictionaryProperty {
    // We should not support dictionary porperty in both direction!
    
    // Create a sword, which is a subclass of tool
    Sword *sword = [[Sword alloc] init];
    sword.damage = @11;
    sword.name = @"Sword";
    sword.speed = 24;
    sword.durability = @44;
    sword.isNew = @YES;
    sword.userInfo = @{
                       @"sharpness": @22
                       };
    
    // Object to JSON
    NSDictionary *swordJSON = (NSDictionary*)[sword JSONObject];
    
    // Verify swordJSON
    NSDictionary *groundTruth = @{
                                  @"damage": @11,
                                  @"name": @"Sword",
                                  @"speed": @24,
                                  @"durability": @44,
                                  @"isNew": @YES
                                  };
    
    XCTAssertTrue([swordJSON isEqualToDictionary:groundTruth], @"Object to JSON mapping incorrect");
    
    // JSON to Object
    // Add userInfo dictionary into JSON object, and JSON to Object should ignore the dictionary
    NSMutableDictionary *jsonWithDictionaryProperty = [NSMutableDictionary dictionaryWithDictionary:swordJSON];
    [jsonWithDictionaryProperty addEntriesFromDictionary:@{@"userInfo": @{@"sharpness": @22}}];
    swordJSON = [NSDictionary dictionaryWithDictionary:jsonWithDictionaryProperty];
    
    Sword *clonedSword = [Sword instanceWithJSONObject:swordJSON];
    
    // Verify clonedSword
    XCTAssertFalse([clonedSword isEqual:sword], @"JSON to Object mapping incorrect");
    sword.userInfo = nil;
    XCTAssertTrue([clonedSword isEqual:sword], @"JSON to Object mapping incorrect");
}

/*
 Test mapping object with NSSet property
 */

/*
 Test date mapping
 */

/*
 Test float value
 */


@end
