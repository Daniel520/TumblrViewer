//
//  APIAccessHelper.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/28.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <TMTumblrSDK/TMURLSession.h>
#import <TMTumblrSDK/TMAPIClient.h>
#import <TMTumblrSDK/TMOAuthAuthenticator.h>
#import <TMTumblrSDK/TMBasicBaseURLDeterminer.h>

NS_ASSUME_NONNULL_BEGIN

// Alias for callbacks on network requests that return user credentials
typedef void (^BTAuthenticationCallback)(NSError * _Nullable);

@interface APIAccessHelper : NSObject

@property (nonatomic,readonly) TMOAuthAuthenticator *authenticator;
@property (nonatomic,readonly) TMURLSession *session;
@property (nonatomic,readonly) TMAPIApplicationCredentials *applicationCredentials;

+ (APIAccessHelper*)shareApiAccessHelper;

- (TMAPIClient*)generateApiClient;
- (BOOL)isNeedLogin;
- (void)authenticate;

/**
 Authenticate for Tumblr.
 
 @param callback a callback after login response, and it will run under main thread.
 */
- (void)authenticate:(BTAuthenticationCallback)callback;
//- (void)getBlogBaseInfo:(NSString*)blogID;

@end

NS_ASSUME_NONNULL_END
