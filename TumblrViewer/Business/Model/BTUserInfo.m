//
//  BTUserInfo.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/6/9.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTUserInfo.h"

@implementation BTUserInfo

//自定义对象转换NSData
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeInteger:self.likes forKey:@"likes"];
    [aCoder encodeInteger:self.follows forKey:@"follows"];
    [aCoder encodeObject:self.blogList forKey:@"blogList"];
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.likes = [aDecoder decodeIntegerForKey:@"likes"];
        self.follows = [aDecoder decodeIntegerForKey:@"follows"];
        self.blogList = [aDecoder decodeObjectForKey:@"blogList"];
    }
    return self;
}

@end

@implementation BTBlogInfo

//自定义对象转换NSData
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.blogUrl forKey:@"blogUrl"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
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
        self.uuid = [aDecoder decodeObjectForKey:@"uuid"];
        self.isNsfw = [aDecoder decodeBoolForKey:@"isNsfw"];
        self.isBlockedFromPrimary = [aDecoder decodeBoolForKey:@"isBlockedFromPrimary"];
    }
    return self;
}

@end
