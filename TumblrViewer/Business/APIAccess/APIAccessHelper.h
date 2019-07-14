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

@class BTUserInfo;
@class BTPost;
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
- (void)fetchUserInfo;
- (BTUserInfo*)getUserInfo;
/**
 Authenticate for Tumblr.
 
 @param callback a callback after login response, and it will run under main thread.
 */
- (void)authenticate:(BTAuthenticationCallback)callback;
//- (void)getBlogBaseInfo:(NSString*)blogID;


/**
 Get Following Users Info

 @param offset <#offset description#>
 @param count <#count description#>
 @param callback <#callback description#>
 */
- (void)requestFollowing:(NSInteger)offset count:(NSInteger)count callback:( void(^)(NSDictionary *usersDic, NSError * error))callback;

/**
 <#Description#>

 @param beforeTime <#beforeTime description#>
 @param count <#count description#>
 @param callback <#callback description#>
 */
- (void)requestLikedBeforeTime:(NSTimeInterval)beforeTime count:(NSInteger)count callback:( void(^)(NSDictionary *dashboardDic, NSError * error))callback;


/**
 <#Description#>

 @param offset <#offset description#>
 @param count <#count description#>
 @param callback <#callback description#>
 */
- (void)requestDashboardStart:(NSInteger)offset count:(NSInteger)count callback:( void(^)(NSDictionary *dashboardDic, NSError * error))callback;


/**
 <#Description#>

 @param before_id <#sinceId description#>
 @param count <#count description#>
 @param callback <#callback description#>
 */
- (void)requestDashboardSince:(NSInteger)before_id count:(NSInteger)count callback:( void(^)(NSDictionary *dashboardDic, NSError * error))callback;

/**
 <#Description#>

 @param blogId <#blogId description#>
 @param type <#type description#>
 @param offset <#offset description#>
 @param count <#count description#>
 @param callback <#callback description#>
 */
- (void)requestPostFromBlogId:(NSString*)blogId type:(NSString*)type Start:(NSInteger)offset count:(NSInteger)count callback:( void(^)(NSDictionary *dashboardDic, NSError * error))callback;


/**
 <#Description#>

 @param post <#post description#>
 */
- (void)forwardPost:(BTPost*)post;


/**
 Log out profile
 */
- (void)logout;
@end

NS_ASSUME_NONNULL_END
