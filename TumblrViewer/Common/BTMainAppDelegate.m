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
    
    self.apiHelper = [APIAccessHelper shareApiAccessHelper];
    
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    
    UINavigationController *navVC = nil;
    
    if ([self.apiHelper isNeedLogin]) {
         navVC = [[UINavigationController alloc] initWithRootViewController:[LoginViewController new]];
    }else{
        BTRootViewController *rootVC = [[BTRootViewController alloc] init];
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
