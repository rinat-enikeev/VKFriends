//
//  VKFriendsTests.m
//  VKFriendsTests
//
//  Created by Rinat Enikeev on 28/10/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "YTVKLoader.h"

// Set the flag for a block completion handler
#define StartBlock() __block BOOL waitingForBlock = YES

// Set the flag to stop the loop
#define EndBlock() waitingForBlock = NO

// Wait and loop until flag is set
#define WaitUntilBlockCompletes() WaitWhile(waitingForBlock)

// Macro - Wait for condition to be NO/false in blocks and asynchronous calls
#define WaitWhile(condition) do { while(condition) {[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];    } } while(0)

@interface VKFriendsTests : XCTestCase

@end

@implementation VKFriendsTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

// check http://vk.com/friends?id=1
- (void)testDurovHas693Friends {
    StartBlock();
    [[YTVKLoader defaultLoader] loadFriendsOfUserId:1 withLimit:10 fromOffset:0 completion:^(NSArray *friends, NSNumber *totalCount, NSError *error) {
        EndBlock();
        XCTAssert([totalCount integerValue] == 693, @"Check Durovs page if fails http://vk.com/friends?id=1");
    }];
    WaitUntilBlockCompletes();
}

// check http://vk.com/id1409261
- (void)testVkIDisDeleted {
    StartBlock();
    [[YTVKLoader defaultLoader] loadFriendsOfUserId:1409261 withLimit:10 fromOffset:0 completion:^(NSArray *friends, NSNumber *totalCount, NSError *error) {
        EndBlock();
        XCTAssert(error != nil && [error domain] == YTVKErrorDomain && [error code] == 15, @"Check users page if fails http://vk.com/id1409261");
    }];
    WaitUntilBlockCompletes();
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
