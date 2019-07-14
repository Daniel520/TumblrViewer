//
//  UserDateCenter.h
//  TumblrViewer
//
//  Created by Daniel on 2019/7/14.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTUserInfo.h"
#import "LogicDataCenter.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^UserDataCallback)(NSArray<BTBlogInfo*> * _Nullable posts, NSError * _Nullable error, DataStatus status);

@interface UserDateCenter : NSObject

@property (nonatomic, strong, readonly) NSArray *users;

@property (atomic, assign, readonly) BOOL isLoading;

@property (atomic, assign, readonly) BOOL isNoMoreData;

/**
 Load Follow User Data for logon user
 
 @param isLoadMore A BOOL value, is perform load more action, YES is load more
 @param callback Perform after load data return value, the callback param "posts" of callback is for this time return data, to get the whole posts data can use the "posts" property of PostDataCenter.
 */
- (void)loadData:(BOOL)isLoadMore callback:(nonnull UserDataCallback)callback;

- (void)loadDataFromBlog:(NSString*)blogId loadMore:(BOOL)isLoadMore callback:(nonnull UserDataCallback)callback;

@end

NS_ASSUME_NONNULL_END
