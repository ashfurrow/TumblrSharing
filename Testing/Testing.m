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
    session.consumerKey = @"0z1vfCKYOvW8iZRiXYKbPZ8zGUoymG35te5S8lh6rsNJDZ3htz";
    session.consumerSecret = @"JOoevzFuTJZ8i5jjhzf3d0aC8CMWEAmnkfoev69qYssrwSBis6";
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSDictionary *authTokens = [session authenticateWithUserName:@"ash@ashfurrow.com" password:@"P@ssword1"];
    
    STAssertNotNil(authTokens, @"Tumblr Authentication returned nil auth tokens");
    
    NSArray *blogs = [session retrievListOfBlogs];
    
    STAssertNotNil(blogs, @"Blogs are nil.");
    
    BOOL createPost = [session postToTumblrDomain:session.defaultBlogName title:@"testing" body:@"<p>this is a body.</p>"];
    
    STAssertTrue(createPost, @"Didn't create post.");
}

@end
