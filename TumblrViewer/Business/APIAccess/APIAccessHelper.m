//
//  APIAccessHelper.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/28.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TMTumblrSDK/TMOAuth.h>
#import <TMTumblrSDK/TMHTTPRequest.h>

#import "APIAccessHelper.h"
#import "CommonConstants.h"
#import "BTUtils.h"
#import "BTUserInfo.h"
#import "BTPost.h"
#import "BTToastManager.h"

//#import <AFNetworking.h>

#define APIProfileName @"BTTumblrViewer"

@interface APIAccessHelper() <TMOAuthAuthenticatorDelegate>

@property (nonatomic,readwrite,strong) TMOAuthAuthenticator *authenticator;
@property (nonatomic,readwrite,strong) TMURLSession *session;
@property (nonatomic,readwrite,strong) TMAPIApplicationCredentials *applicationCredentials;
@property (nonatomic,strong) NSString *tmToken;
@property (nonatomic,strong) NSString *tmTokenSecret;

@end

@implementation APIAccessHelper

static APIAccessHelper *instance = nil;

+ (APIAccessHelper*)shareApiAccessHelper
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[APIAccessHelper alloc] init];
        }
    }
    
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        
        [self initBaseInfo];
        
        self.applicationCredentials = [[TMAPIApplicationCredentials alloc] initWithConsumerKey:API_KEY consumerSecret:SECRET_KEY];
        
        if ([self isNeedLogin]) {
            self.session = [[TMURLSession alloc] initWithConfiguration:[self getNetworkConfiguration]
                                                applicationCredentials:self.applicationCredentials
                                                       userCredentials:[TMAPIUserCredentials new]
                                                networkActivityManager:nil
                                             sessionTaskUpdateDelegate:nil
                                                sessionMetricsDelegate:nil
                                                    requestTransformer:nil
                                                     additionalHeaders:nil];
        }else{
            self.session = [[TMURLSession alloc] initWithConfiguration:[self getNetworkConfiguration] applicationCredentials:self.applicationCredentials userCredentials:[[TMAPIUserCredentials alloc] initWithToken:self.tmToken tokenSecret:self.tmTokenSecret]];
        }
        
        
        self.authenticator = [[TMOAuthAuthenticator alloc] initWithSession:self.session
                                                    applicationCredentials:self.applicationCredentials
                                                                  delegate:self];
    }
    return self;
}

- (void)initBaseInfo
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.tmToken = [userDefault objectForKey:TOKEN_KEY];
    self.tmTokenSecret = [userDefault objectForKey:TOKEN_SECRET_KEY];
}

- (BOOL)isNeedLogin
{
    if ([BTUtils isStringEmpty:self.tmToken] && [BTUtils isStringEmpty:self.tmTokenSecret]) {
        return TRUE;
    }
    return NO;
}

- (BTUserInfo*)getUserInfo
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSData *data = (NSData*)[userDefault objectForKey:USERINFO_KEY];
    
    BTUserInfo *userInfo = (BTUserInfo*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    return userInfo;
}

- (TMAPIClient*)generateApiClient
{
    TMRequestFactory *requestFactory = [[TMRequestFactory alloc] initWithBaseURLDeterminer:[[TMBasicBaseURLDeterminer alloc] init]];
    
    TMAPIClient *apiClient = [[TMAPIClient alloc] initWithSession:self.session requestFactory:requestFactory];
    return apiClient;
}

- (void)authenticate {
    [self authenticate:^(NSError *error){}];
}

- (void)logout
{
    self.tmToken = nil;
    self.tmTokenSecret = nil;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:TOKEN_KEY];
    [userDefault removeObjectForKey:TOKEN_SECRET_KEY];
    [userDefault removeObjectForKey:USERINFO_KEY];
    [userDefault synchronize];
    
}

- (void)authenticate:(BTAuthenticationCallback)callback
{
    BTWeakSelf(weakSelf);
    [self.authenticator authenticate:APIProfileName callback:^(TMAPIUserCredentials *creds, NSError *networkingError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (networkingError) {
                //                self.authResultsTextView.text = [NSString stringWithFormat:@"Error: %@", networkingError.localizedDescription];
                NSLog(@"login fail:%@",networkingError.localizedDescription);
                callback(networkingError);
            }
            else {
                weakSelf.tmToken = creds.token;
                weakSelf.tmTokenSecret = creds.tokenSecret;
                
                weakSelf.session = [[TMURLSession alloc] initWithConfiguration:[self getNetworkConfiguration] applicationCredentials:self.applicationCredentials userCredentials:[[TMAPIUserCredentials alloc] initWithToken:creds.token tokenSecret:creds.tokenSecret]];
                //                self.authResultsTextView.text = [NSString stringWithFormat:@"Success!\nToken: %@\nSecret: %@", creds.token, creds.tokenSecret];
                //                [self request];
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                [userDefault setObject:creds.token forKey:TOKEN_KEY];
                [userDefault setObject:creds.tokenSecret forKey:TOKEN_SECRET_KEY];
                [userDefault synchronize];
                
                [weakSelf fetchUserInfo];
                
                callback(networkingError);
            }
        });
    }];
}

- (void)fetchUserInfo
{
    TMAPIClient *apiClient = [[APIAccessHelper shareApiAccessHelper] generateApiClient];
    
    NSURLSessionTask *task = [apiClient userInfoDataTaskWithCallback:^( id _Nullable response, NSError * _Nullable error){
        
        if (error != nil) {
            NSLog(@"get user info fail with error:%@",error);
            return;
        }
        
        NSDictionary *userInfoDic = [(NSDictionary*)response objectForKey:@"user"];
        BTUserInfo *userInfo = [BTUserInfo createUserInfoByDic:userInfoDic];
//        BTUserInfo *userInfo = [BTUserInfo new];
        
//        userInfo.name = [userInfoDic objectForKey:@"name"];
//        userInfo.likes = [[userInfoDic objectForKey:@"likes"] integerValue];
//        userInfo.follows = [[userInfoDic objectForKey:@"follows"] integerValue];
//
//        NSMutableArray *blogList = [NSMutableArray new];
//
//        for (NSDictionary *blogDic in [userInfoDic objectForKey:@"blogs"]) {
//            BTBlogInfo *blog = [BTBlogInfo new];
//            blog.followers = [[blogDic objectForKey:@"followers"] integerValue];
//            blog.isAdmin = [[blogDic objectForKey:@"admin"] boolValue];
//            blog.isNsfw = [[blogDic objectForKey:@"is_nsfw"] boolValue];
//            blog.blogUrl = [blogDic objectForKey:@"url"];
//            blog.uuid = [blogDic objectForKey:@"uuid"];
//            blog.isBlockedFromPrimary = [blogDic objectForKey:@"is_blocked_from_primary"];
//            [blogList addObject:blog];
//        }
//
//        userInfo.blogList = blogList;
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:data forKey:USERINFO_KEY];
        [userDefault synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:BTUserInfoUpdateNotification object:userInfo];
    }];
    
    [task resume];
}

- (NSURLSessionConfiguration*)getNetworkConfiguration
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForResource = 10;
    config.timeoutIntervalForRequest = 10;
    
    return config;
}

- (void)requestDashboardSince:(NSInteger)sinceId count:(NSInteger)count callback:( void(^)(NSDictionary *dashboardDic, NSError * error))callback
{
    TMAPIClient *apiClient = [[APIAccessHelper shareApiAccessHelper] generateApiClient];
    
    NSURLSessionTask *task = nil;
    
    task = [apiClient dashboardRequest:@{@"limit":@(count),@"before_id":@(sinceId),@"reblog_info" : @(YES), @"notes_info" : @(YES)} callback:^( id _Nullable response, NSError * _Nullable error){
        
        
        if (error) {
            NSLog(@"error info:%@",error);
        }
        callback(response, error);
    }];
    
    [task resume];
}

- (void)requestDashboardStart:(NSInteger)offset count:(NSInteger)count callback:( void(^)(NSDictionary *dashboardDic, NSError * error))callback
{
    TMAPIClient *apiClient = [[APIAccessHelper shareApiAccessHelper] generateApiClient];
    
    NSURLSessionTask *task = nil;
    
    task = [apiClient dashboardRequest:@{@"limit":@(count),@"offset":@(offset),@"reblog_info" : @(YES), @"notes_info" : @(YES)} callback:^( id _Nullable response, NSError * _Nullable error){
        
        
        if (error) {
            NSLog(@"error info:%@",error);
        }
        callback(response, error);
    }];
    
    [task resume];
}

- (void)requestPostFromBlogId:(NSString*)blogId type:(NSString*)type Start:(NSInteger)offset count:(NSInteger)count callback:( void(^)(NSDictionary *dashboardDic, NSError * error))callback
{
    TMAPIClient *apiClient = [[APIAccessHelper shareApiAccessHelper] generateApiClient];
    
    NSURLSessionTask *task = nil;
    
    task = [apiClient postsTask:blogId type:type queryParameters:@{@"limit":@(count),@"offset":@(offset)} callback:^( id _Nullable response, NSError * _Nullable error){
        
        
        if (error) {
            NSLog(@"error info:%@",error);
        }
        callback(response, error);
    }];
    
    [task resume];
}

- (void)forwardPost:(BTPost*)post
{
    TMAPIClient *apiClient = [[APIAccessHelper shareApiAccessHelper] generateApiClient];
    
    BTUserInfo *userInfo = [[APIAccessHelper shareApiAccessHelper] getUserInfo];
    
    if (!userInfo) {
        NSLog(@"No UserInfo, please wait or try login again");
    }
    
    NSURLSessionTask *task = nil;
    
    id <TMRequest> request = [apiClient.requestFactory reblogPostRequestWithBlogName:[userInfo.name stringByAppendingString:TUMBLR_BLOG_SUFFIX] parameters:@{ @"id" : @(post.postid) , @"reblog_key" : post.reblogKey } ];

    task = [apiClient taskWithRequest:request callback:^( id _Nullable response, NSError * _Nullable error){
#warning todo show toast
        if (error != nil) {
            NSLog(@"reblog error:%@",error);
        }
        
        [BTToastManager  showToastWithText:@"Forward Successed"];
        NSLog(@"reblog sucess");
    }];
    
    [task resume];
}

//- (void)getBlogBaseInfo:(NSString*)blogID
//{
//    NSString *accessURI = [[API_HEADER stringByAppendingString:API_VERSION] stringByAppendingString:BLOG_INFO];
//    
//    accessURI = [accessURI stringByReplacingOccurrencesOfString:BLOG_PH withString:blogID];
//    accessURI = [accessURI stringByReplacingOccurrencesOfString:KEY_PH withString:API_KEY];
//    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//
//    NSURL *URL = [NSURL URLWithString:accessURI];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"%@ %@", response, responseObject);
//        }
//    }];
//    [dataTask resume];
//}
#pragma mark - TMOAuthAuthenticatorDelegate

- (void)openURLInBrowser:(NSURL *)url {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
