//
//  BTUserInfo.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/6/9.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTUserInfo.h"

@implementation BTUserInfo

+ (BTUserInfo*)createUserInfoByDic:(NSDictionary*)userInfoDic;
{
    BTUserInfo *userInfo = [BTUserInfo new];
    userInfo.name = [userInfoDic objectForKey:@"name"];
    userInfo.likes = [[userInfoDic objectForKey:@"likes"] integerValue];
    userInfo.follows = [[userInfoDic objectForKey:@"follows"] integerValue];
    
    NSMutableArray *blogList = [NSMutableArray new];
    
    for (NSDictionary *blogDic in [userInfoDic objectForKey:@"blogs"]) {
//        BTBlogInfo *blog = [BTBlogInfo new];
//        blog.followers = [[blogDic objectForKey:@"followers"] integerValue];
//        blog.isAdmin = [[blogDic objectForKey:@"admin"] boolValue];
//        blog.isNsfw = [[blogDic objectForKey:@"is_nsfw"] boolValue];
//        blog.blogUrl = [blogDic objectForKey:@"url"];
//        blog.uuid = [blogDic objectForKey:@"uuid"];
//        blog.isBlockedFromPrimary = [blogDic objectForKey:@"is_blocked_from_primary"];
        BTBlogInfo *blog = [BTBlogInfo createBlogInfoByDic:blogDic];
        [blogList addObject:blog];
    }
    
    userInfo.blogList = blogList;
    
    return userInfo;
}

//自定义对象转换NSData
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.likes forKey:@"likes"];
    [aCoder encodeInteger:self.follows forKey:@"follows"];
    [aCoder encodeObject:self.blogList forKey:@"blogList"];
//    [aCoder encodeObject:self.avatarUrl forKey:@"avatarUrl"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.likes = [aDecoder decodeIntegerForKey:@"likes"];
        self.follows = [aDecoder decodeIntegerForKey:@"follows"];
        self.blogList = [aDecoder decodeObjectForKey:@"blogList"];
//        self.avatarUrl = [aDecoder decodeObjectForKey:@"avatarUrl"];
    }
    return self;
}

@end

@implementation BTBlogInfo

+ (BTBlogInfo*)createBlogInfoByDic:(NSDictionary*)blogDic
{
    BTBlogInfo *blog = [BTBlogInfo new];
    blog.followers = [[blogDic objectForKey:@"followers"] integerValue];
    blog.isAdmin = [[blogDic objectForKey:@"admin"] boolValue];
    blog.isNsfw = [[blogDic objectForKey:@"is_nsfw"] boolValue];
    blog.name = [blogDic objectForKey:@"name"];
    blog.title = [blogDic objectForKey:@"title"];
    blog.blogUrl = [blogDic objectForKey:@"url"];
    blog.uuid = [blogDic objectForKey:@"uuid"];
    blog.isBlockedFromPrimary = [blogDic objectForKey:@"is_blocked_from_primary"];
    
    
    return blog;
}

- (NSString*)blogId
{
    NSString *blogId = [self.name stringByAppendingString:@".tumblr.com"];
    return blogId;
}

- (NSString*)avatarPath
{
    NSString *avatarPath = @"https://api.tumblr.com/v2/blog/%@.tumblr.com/avatar/30";
    avatarPath = [NSString stringWithFormat:avatarPath, self.name];
    return avatarPath;
}

- (NSString*)description
{
    NSDictionary *blogDic = @{
                              @"title":self.title,
                              @"name":self.name,
                              @"followers":@(self.followers),
                              @"is_nsfw":@(self.isNsfw),
                              @"blogUrl":self.blogUrl ? self.blogUrl : [NSNull null],
                              @"uuid":self.uuid ? self.uuid : [NSNull null]
                              };
    NSString *des = [blogDic description];
    return des;
}

//自定义对象转换NSData
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.blogUrl forKey:@"blogUrl"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeBool:self.isAdmin forKey:@"isAdmin"];
    [aCoder encodeBool:self.isNsfw forKey:@"isNsfw"];
    [aCoder encodeBool:self.isBlockedFromPrimary forKey:@"isBlockedFromPrimary"];
    [aCoder encodeInteger:self.followers forKey:@"followers"];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.isAdmin = [aDecoder decodeBoolForKey:@"isAdmin"];
        self.followers = [aDecoder decodeIntegerForKey:@"followers"];
        self.blogUrl = [aDecoder decodeObjectForKey:@"blogUrl"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.isNsfw = [aDecoder decodeBoolForKey:@"isNsfw"];
        self.isBlockedFromPrimary = [aDecoder decodeBoolForKey:@"isBlockedFromPrimary"];
    }
    return self;
}

@end
