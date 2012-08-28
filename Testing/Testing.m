//
//  Testing.m
//  Testing
//
//  Created by Ash Furrow on 2012-08-27.
//  Copyright (c) 2012 AF. All rights reserved.
//

#import "Testing.h"
#import "TumblrSharing.h"

@implementation Testing
{
    TumblrSession *session;
}

- (void)setUp
{
    [super setUp];
    
    session = [[TumblrSession alloc] init];
    session.host = @"http://www.tumblr.com";
    session.consumerKey = @"CHANGE ME";
    session.consumerSecret = @"CHANGE ME";
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSInteger responseCode = [session authenticateWithUserName:@"CHANGE ME" password:@"CHANGE ME"];
    
    STAssertEquals(200, responseCode, @"Tumblr Authentication returned non-200 response: %d", responseCode);
    
}

@end
