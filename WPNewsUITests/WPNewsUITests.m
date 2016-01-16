//
//  WPNewsUITests.m
//  WPNewsUITests
//
//  Created by Lyndsey on 1/16/16.
//  Copyright © 2016 Lyndsey Ferguson Software. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface WPNewsUITests : XCTestCase
@property (strong, retain) XCUIApplication* app;
@end

@implementation WPNewsUITests

- (void)setUp {
    [super setUp];
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    self.app = [[XCUIApplication alloc] init];
    self.app.launchArguments = @[ @"TESTING" ];
    [self.app launch];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testUponLoadTableViewVisible {
    XCTAssertTrue(self.app.tables[@"news-article-table"].exists);
}
@end
