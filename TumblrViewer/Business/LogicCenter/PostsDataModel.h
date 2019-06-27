//
//  PostsDataCenter.h
//  TumblrViewer
//
//  Created by Danielyu on 2019/5/25.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTPost.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    Type_Dashboard = 0,
    Type_BlogPost
}PostsType;

typedef enum {
    Data_Status_Normal,
    Data_Status_End
}PostDataStatus;

typedef void (^PostsDataCallback)(NSArray<BTPost*> * _Nullable posts, NSError * _Nullable error, PostDataStatus status);

@interface PostsDataModel : NSObject <NSCopying>

@property (nonatomic, strong, readonly) NSArray *posts;

@property (nonatomic, assign, readonly) BOOL isLoadingPosts;

@property (nonatomic, assign, readonly) BOOL isNoMoreData;


/**
 Load Post Data

 @param isLoadMore A BOOL value, is perform load more action, YES is load more
 @param callback  perform after load data return value, the callback param "posts" of callback is for this time return data, to get the whole posts data can use the "posts" property of PostDataCenter.
 */
- (void)loadData:(BOOL)isLoadMore callback:(nonnull PostsDataCallback)callback;

- (void)loadDataFromBlog:(NSString*)blogId loadMore:(BOOL)isLoadMore callback:(nonnull PostsDataCallback)callback;
@end

NS_ASSUME_NONNULL_END
