//
//  TumblrSharing.m
//  TumblrSharing
//
//  Created by Ash Furrow on 2012-08-27.
//  Copyright (c) 2012 AF. All rights reserved.
//

#import "TumblrSharing.h"
#import "OAuthCore.h"
#import "OAuth+Additions.h"

@interface NSString (URLEncoding)

- (NSString *) urlEncode;

@end

@implementation NSString (URLEncoding)

- (NSString *) urlEncode
{
    NSString * encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                   (__bridge CFStringRef)self,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8);
    return encodedString;
}

@end

@implementation TumblrSession

-(NSDictionary *)authenticateWithUserName:(NSString *)username password:(NSString *)password
{    
    NSMutableURLRequest *accessTokenURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.tumblr.com/oauth/access_token"]]];
    [accessTokenURLRequest setHTTPMethod:@"POST"];
    
    NSDictionary *accessTokenOptions = @{ @"x_auth_mode": @"client_auth", @"x_auth_password": password, @"x_auth_username" : username };
    
    NSMutableString *accessTokenParamsAsString = [[NSMutableString alloc] init];
    
    [accessTokenOptions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [accessTokenParamsAsString appendFormat:@"%@=%@&", key, obj];
    }];
        
    NSData *bodyData = [accessTokenParamsAsString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(accessTokenURLRequest.URL, @"POST", bodyData, self.consumerKey, self.consumerSecret, nil, nil);
    
    [accessTokenURLRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    [accessTokenURLRequest setHTTPBody:bodyData];
    
    NSError *error;
    NSHTTPURLResponse *response;
    
    NSData *returnedAccessTokenData = [NSURLConnection sendSynchronousRequest:accessTokenURLRequest returningResponse:&response error:&error];
    
    NSString *returnedAccessTokenString = [[NSString alloc] initWithData:returnedAccessTokenData encoding:NSUTF8StringEncoding];
    
    if (response.statusCode != 200)
    {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    NSDictionary *authDictionary = [returnedAccessTokenString ab_parseURLQueryString];
    
    _authToken = authDictionary[@"oauth_token"];
    _authSecret = authDictionary[@"oauth_token_secret"];
    
    return authDictionary;
}

-(NSArray *)retrievListOfBlogs
{
    NSMutableURLRequest *accessTokenURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.tumblr.com/v2/user/info"]]];
    [accessTokenURLRequest setHTTPMethod:@"POST"];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(accessTokenURLRequest.URL, @"POST", nil, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
    
    [accessTokenURLRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:accessTokenURLRequest returningResponse:&response error:&error];
    
    if (response.statusCode != 200)
    {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:returnedData options:0 error:nil];

    _blogArray = [responseDictionary valueForKeyPath:@"response.user.blogs"];
    _defaultBlogName = [responseDictionary valueForKeyPath:@"response.user.name"];
    
    return _blogArray;
}

-(BOOL)postToTumblrDomain:(NSString *)domain title:(NSString *)title body:(NSString *)body
{
    NSMutableURLRequest *postURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.tumblr.com/v2/blog/%@.tumblr.com/post", domain]]];
    [postURLRequest setHTTPMethod:@"POST"];
    
    NSDictionary *postOptions = @{ @"type" : @"text", @"format" : @"html", @"title": title, @"body": body };
    
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    
    [postOptions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [paramsAsString appendFormat:@"%@=%@&", key, obj];
    }];
    
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(postURLRequest.URL, @"POST", bodyData, self.consumerKey, self.consumerSecret, self.authToken, self.authSecret);
    
    [postURLRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    [postURLRequest setHTTPBody:bodyData];
    
    NSError *error;
    NSHTTPURLResponse *response;
    
    NSData *returnedData = [NSURLConnection sendSynchronousRequest:postURLRequest returningResponse:&response error:&error];
    
//    NSString *returnedString = [[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding];
    
    if (response.statusCode >= 400)
    {
        NSLog(@"Error: %@", error);
        return NO;
    }
    
    return YES;
}

@end
