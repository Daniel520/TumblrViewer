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

typedef void (^PostsDataCallback)(NSArray<BTPost*> * _Nullable posts, NSError * _Nullable error);

@interface PostsDataModel : NSObject <NSCopying>

@property (nonatomic, strong, readonly) NSArray *posts;


/**
 Load Post Data

 @param isLoadMore A BOOL value, is perform load more action, YES is load more
 @param callback  perform after load data return value, the callback param "posts" of callback is for this time return data, to get the whole posts data can use the "posts" property of PostDataCenter.
 */
- (void)loadData:(BOOL)isLoadMore withType:(PostsType)type callback:(nonnull PostsDataCallback)callback;


@end

NS_ASSUME_NONNULL_END
