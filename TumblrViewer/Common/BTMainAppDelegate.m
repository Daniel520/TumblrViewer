//
//  BTMainAppDelegate.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/27.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTMainAppDelegate.h"
#import <TMTumblrSDK/TMOAuthAuthenticator.h>
#import <TMTumblrSDK/TMURLSession.h>
//#import <Bugly/Bugly.h>

#import "APIAccessHelper.h"

#import "BTMaintabViewController.h"
#import "BTRootViewController.h"
#import "LoginViewController.h"

@interface BTMainAppDelegate()

@property (nonatomic, weak) APIAccessHelper *apiHelper;

@end

@implementation BTMainAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    [Bugly startWithAppId:@"e42f20fad7"];
    
    self.apiHelper = [APIAccessHelper shareApiAccessHelper];
    
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    
    UINavigationController *navVC = nil;
    
    if ([self.apiHelper isNeedLogin]) {
         navVC = [[UINavigationController alloc] initWithRootViewController:[LoginViewController new]];
    }else{
        BTUserInfo *userInfo = [[APIAccessHelper shareApiAccessHelper] getUserInfo];
        BTBlogInfo *blogInfo = [userInfo.blogList objectAtIndex:0];
        if (!userInfo || !blogInfo || [BTUtils isStringEmpty:blogInfo.name]) {
            [[APIAccessHelper shareApiAccessHelper] fetchUserInfo];
        }
        
        BTBlogInfo *blog = [[[APIAccessHelper shareApiAccessHelper] getUserInfo].blogList objectAtIndex:0];
        BTRootViewController *rootVC = [[BTRootViewController alloc] initWithBlog:blog WithDataType:Type_Dashboard];
        navVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
    }

    self.window.rootViewController = navVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    [self.apiHelper.authenticator handleOpenURL:url];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Do the work associated with the task, preferably in chunks.
        
        [application endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
    });
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
