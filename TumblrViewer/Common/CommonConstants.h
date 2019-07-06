//
//  CommonConstants.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/28.
//  Copyright © 2019 jingda yu. All rights reserved.
//

//#import <Foundation/Foundation.h>

#ifndef CommonConstants_h
#define CommonConstants_h

#pragma mark Common Parameter

#define API_KEY @"F767mxg0z6h2vPxOboi7bkrSM0wjz1otu46PDybj5P9hsfJYHe"
#define SECRET_KEY @"dhu6fBM6rN1HZAXnHyTLFLdVCBLlPquiO0TxeIDIr9mOW9gUR7"
#define TOKEN_KEY @"TOKEN_KEY"
#define TOKEN_SECRET_KEY @"TOKEN_SECRET_KEY"
#define USERINFO_KEY @"BT_USERINFO_KEY"

#define TUMBLR_BLOG_SUFFIX @".tumblr.com"

#pragma mark Tumblr API

//API header
#define API_HEADER @"https://api.tumblr.com/"

//API Version
#define API_VERSION @"v2"

//API Placeholder
#define BLOG_PH @"{blog-identifier}"

#define KEY_PH @"{key}"

#define TYPE_OPTION @"[/type]"

#define SIZE_OPTION @"[/size]"

//API
#define BLOG_INFO @"/blog/{blog-identifier}/info?api_key={key}"

#define LIKE_INFO @"/blog/{blog-identifier}/likes?api_key={key}"

#define FOLLOW_INFO @"/blog/{blog-identifier}/following"

#define FOLLOWER_INFO @"/blog/{blog-identifier}/followers"

#define POST_INFO @"/blog/{blog-identifier}/posts[/type]?api_key={key}&[optional-params=]"

#define AVATAR_INFO @"/blog/{blog-identifier}/avatar[/size]"
//
//NSString * const POST_TYPE_TEXT = @"text";
//
//NSString * const POST_TYPE_VIDEO = @"video";
//
//NSString * const POST_TYPE_PHOTO = @"photo";
//
//NSString * const POST_TYPE_LINT = @"link";
//
//NSString * const POST_TYPE_AUDIO = @"audio";
//
//NSString * const POST_TYPE_CHAT = @"chat";


#pragma mark Notification

#define BTUserInfoUpdateNotification @"BTUserInfoUpdateNotification"

#endif /* CommonConstants_h */
