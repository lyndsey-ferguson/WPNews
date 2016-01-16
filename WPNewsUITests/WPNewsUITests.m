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
@property (strong, retain) NSDateFormatter* dateFormat;
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
    
    // hardcoded duplicate NSDateFormatter
    self.dateFormat = [[NSDateFormatter alloc] init];
    [self.dateFormat setDateFormat:@"yyyy-dd-MM H:mm:ss"]; //2014-02-12 20:29:36

}

- (void)tearDown {
    [super tearDown];
}

- (void)testUponLoadTableViewVisible {
    XCTAssertTrue(self.app.tables[@"news-article-table"].exists);
}

- (void)testUponLoadTableViewHasCells {
    XCTAssertGreaterThan(self.app.tables[@"news-article-table"].cells.count, 0);
}

- (void)testUponLoadTableViewCellDisplaysLabels {
    XCTAssertTrue(self.app.tables[@"news-article-table"].cells.staticTexts[@"Matt Drudge and Hillary Clinton: A History"].exists);
}

- (void)testUponLoadTableViewCellDisplaysLabelWithNoHTMLCharacterCodes {
    XCTAssertFalse(self.app.tables[@"news-article-table"].cells.staticTexts[@"How &#8216;Red Sox vs. Yankees&#8217; explains Connecticut politics"].exists);

    XCTAssertTrue(self.app.tables[@"news-article-table"].cells.staticTexts[@"How ‘Red Sox vs. Yankees’ explains Connecticut politics"].exists);
}

- (void)testUponLoadTappingCellShowsDetailView {
    [self.app.tables[@"news-article-table"].cells.staticTexts[@"Matt Drudge and Hillary Clinton: A History"] tap];
    
    NSPredicate* bodyContentElementExistsPredicate = [NSPredicate predicateWithFormat:@"exists = 1"];
    [self expectationForPredicate:bodyContentElementExistsPredicate
              evaluatedWithObject:self.app.textViews[@"body-text"]
                          handler:nil];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    
    NSString* expectedContentSegment = @"An inverse relationship seems to exist between the length of time since a Clinton has orbited the White House and the power held by the mythology of Matt Drudge";
    XCTAssertTrue([self.app.textViews[@"body-text"].value containsString:expectedContentSegment]);
}

- (void)testUponLoadArticlesAreSortedByDateDescending {
    XCUIElement* article1Element = [self.app.tables[@"news-article-table"].cells elementBoundByIndex:0];
    XCUIElement* article2Element = [self.app.tables[@"news-article-table"].cells elementBoundByIndex:1];
    
    NSString* article1DateString = article1Element.staticTexts[@"date"].label;
    NSString* article2DateString = article2Element.staticTexts[@"date"].label;
    
    NSDate *date1 = [self.dateFormat dateFromString:article1DateString];
    NSDate *date2 = [self.dateFormat dateFromString:article2DateString];

    XCTAssertEqual([date1 compare:date2], NSOrderedDescending);
}

@end
