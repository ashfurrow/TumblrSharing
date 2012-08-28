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

-(NSDictionary *)requestTokenAndSecret
{
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/oauth/request_token", self.host]];
    NSMutableURLRequest *requestTokenURLRequest = [NSMutableURLRequest requestWithURL:requestURL];
    [requestTokenURLRequest setHTTPMethod:@"POST"];
        
    NSString *requestTokenAuthorizationHeader = OAuthorizationHeader(requestURL, @"POST", nil, self.consumerKey, self.consumerSecret, nil, nil);
    
    [requestTokenURLRequest setHTTPMethod:@"POST"];
    [requestTokenURLRequest setValue:requestTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:requestTokenURLRequest returningResponse:&response error:&error];
    
    NSString *returnedRequestTokenString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary *returnedRequestTokenDictionary = [returnedRequestTokenString ab_parseURLQueryString];
    
    return returnedRequestTokenDictionary;
}

-(NSInteger)authenticateWithUserName:(NSString *)username password:(NSString *)password
{
    NSDictionary *returnedRequestTokenDictionary = [self requestTokenAndSecret];
    
    NSString *requestOauthToken = [returnedRequestTokenDictionary valueForKey:@"oauth_token"];
    NSString *requestOauthSecret = [returnedRequestTokenDictionary valueForKey:@"oauth_token_secret"];
    
    NSMutableURLRequest *accessTokenURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.tumblr.com/oauth/access_token"]]];
    [accessTokenURLRequest setHTTPMethod:@"POST"];
    
    NSDictionary *accessTokenOptions = @{ @"x_auth_mode": @"client_auth", @"x_auth_password": password, @"x_auth_username" : username };
    
    NSMutableString *accessTokenParamsAsString = [[NSMutableString alloc] init];
    
    [accessTokenOptions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [accessTokenParamsAsString appendFormat:@"%@=%@&", key, obj];
    }];
        
    NSData *bodyData = [accessTokenParamsAsString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *accessTokenAuthorizationHeader = OAuthorizationHeader(accessTokenURLRequest.URL, @"POST", bodyData, self.consumerKey, self.consumerSecret, requestOauthToken, requestOauthSecret);
    
    
    [accessTokenURLRequest setValue:accessTokenAuthorizationHeader forHTTPHeaderField:@"Authorization"];
    [accessTokenURLRequest setHTTPBody:bodyData];
    
    NSError *error;
    NSHTTPURLResponse *response;
    
    NSData *returnedAccessTokenData = [NSURLConnection sendSynchronousRequest:accessTokenURLRequest returningResponse:&response error:&error];
    
    NSString *returnedAccessTokenString = [[NSString alloc] initWithData:returnedAccessTokenData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", returnedAccessTokenString);
    
    return response.statusCode;
}

@end
