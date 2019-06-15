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

NSString * const API_KEY = @"F767mxg0z6h2vPxOboi7bkrSM0wjz1otu46PDybj5P9hsfJYHe";
NSString * const SECRET_KEY = @"dhu6fBM6rN1HZAXnHyTLFLdVCBLlPquiO0TxeIDIr9mOW9gUR7";
NSString * const TOKEN_KEY = @"TOKEN_KEY";
NSString * const TOKEN_SECRET_KEY = @"TOKEN_SECRET_KEY";
NSString * const USERINFO_KEY = @"BT_USERINFO_KEY";

NSString * const TUMBLR_BLOG_SUFFIX = @".tumblr.com";

#pragma mark Tumblr API

//API header
NSString * const API_HEADER = @"https://api.tumblr.com/";

//API Version
NSString * const API_VERSION = @"v2";

//API Placeholder
NSString * const BLOG_PH = @"{blog-identifier}";

NSString * const KEY_PH = @"{key}";

NSString * const TYPE_OPTION = @"[/type]";

NSString * const SIZE_OPTION = @"[/size]";

//API
NSString * const BLOG_INFO = @"/blog/{blog-identifier}/info?api_key={key}";

NSString * const LIKE_INFO = @"/blog/{blog-identifier}/likes?api_key={key}";

NSString * const FOLLOW_INFO = @"/blog/{blog-identifier}/following";

NSString * const FOLLOWER_INFO = @"/blog/{blog-identifier}/followers";

NSString * const POST_INFO = @"/blog/{blog-identifier}/posts[/type]?api_key={key}&[optional-params=]";

NSString * const AVATAR_INFO = @"/blog/{blog-identifier}/avatar[/size]";
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

#endif /* CommonConstants_h */
