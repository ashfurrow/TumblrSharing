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
    session.consumerKey = @"__CHANGE_ME__";
    session.consumerSecret = @"__CHANGE_ME__";
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSDictionary *authTokens = [session authenticateWithUserName:@"__CHANGE_ME" password:@"__CHANGE_ME__"];
    
    STAssertNotNil(authTokens, @"Tumblr Authentication returned nil auth tokens");
    
    NSArray *blogs = [session retrievListOfBlogs];
    
    STAssertNotNil(blogs, @"Blogs are nil.");
    
    BOOL createPost = [session postToTumblrDomain:session.defaultBlogName title:@"testing" body:@"<p>this is a body.</p>"];
    
    STAssertTrue(createPost, @"Didn't create post.");
}

@end
