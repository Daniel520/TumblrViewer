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

//#import <AFNetworking.h>



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

- (TMAPIClient*)generateApiClient
{
    TMRequestFactory *requestFactory = [[TMRequestFactory alloc] initWithBaseURLDeterminer:[[TMBasicBaseURLDeterminer alloc] init]];
    
    TMAPIClient *apiClient = [[TMAPIClient alloc] initWithSession:self.session requestFactory:requestFactory];
    return apiClient;
}

- (void)authenticate {
    [self authenticate:^(NSError *error){}];
}

- (void)authenticate:(BTAuthenticationCallback)callback
{
    BTWeakSelf(weakSelf);
    [self.authenticator authenticate:@"BTTumblrViewer" callback:^(TMAPIUserCredentials *creds, NSError *networkingError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (networkingError) {
                //                self.authResultsTextView.text = [NSString stringWithFormat:@"Error: %@", networkingError.localizedDescription];
                NSLog(@"login fail:%@",networkingError.localizedDescription);
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
                
                callback(networkingError);
            }
        });
    }];
}

- (NSURLSessionConfiguration*)getNetworkConfiguration
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForResource = 10;
    config.timeoutIntervalForRequest = 10;
    
    return config;
}

- (void)requestDashboardStart:(NSInteger)offset count:(NSInteger)count callback:( void(^)(NSDictionary *dashboardDic, NSError * error))callback
{
    TMAPIClient *apiClient = [[APIAccessHelper shareApiAccessHelper] generateApiClient];
    
    NSURLSessionTask *task = nil;
    
    task = [apiClient dashboardRequest:@{@"limit":@(count),@"offset":@(offset)} callback:^( id _Nullable response, NSError * _Nullable error){
        
        
        if (error) {
            NSLog(@"error info:%@",error);
        }
        callback(response, error);
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
