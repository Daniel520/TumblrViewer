//
//  BTUserInfo.h
//  TumblrViewer
//
//  Created by Danielyu on 2019/6/9.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTUserInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, assign) NSInteger follows;
@property (nonatomic, strong) NSArray *blogList;

@end

@interface BTBlogInfo : NSObject <NSCoding>

@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, assign) NSInteger followers;
@property (nonatomic, strong) NSString *blogUrl;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) BOOL isNsfw;
@property (nonatomic, assign) BOOL isBlockedFromPrimary;

@end

NS_ASSUME_NONNULL_END

//"blogs": [
//          {
//              "admin": true,
//              "ask": false,
//              "ask_anon": false,
//              "ask_page_title": "Ask me anything",
//              "can_chat": true,
//              "can_send_fan_mail": true,
//              "can_subscribe": false,
//              "description": "",
//              "drafts": 0,
//              "facebook": "N",
//              "facebook_opengraph_enabled": "N",
//              "followed": false,
//              "followers": 47,
//              "is_blocked_from_primary": false,
//              "is_nsfw": false,
//              "messages": 0,
//              "name": "dainiu520",
//              "posts": 1249,
//              "primary": true,
//              "queue": 0,
//              "share_likes": false,
//              "subscribed": false,
//              "title": "无标题",
//              "total_posts": 1249,
//              "tweet": "N",
//              "twitter_enabled": false,
//              "twitter_send": false,
//              "type": "public",
//              "updated": 1559965643,
//              "url": "https://dainiu520.tumblr.com/",
//              "uuid": "t:dxkw0cB7EghVZdY8HA9mAA"
//          }
//
