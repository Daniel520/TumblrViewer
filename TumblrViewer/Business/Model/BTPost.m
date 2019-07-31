//
//  BTPost.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/5/7.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTPost.h"

@implementation BTResInfo

- (NSString*)description
{
    NSDictionary *resDic = @{
                             @"url":self.resUrl? self.resUrl.absoluteString : [NSNull null],
                             @"width":@(self.size.width),
                             @"height":@(self.size.height)
                             };
    NSString *des = [resDic description];
    return des;
}

@end

@implementation BTImageInfo

- (NSString*)description
{
    NSDictionary *imgDic = @{
                             @"originRes":self.originResInfo ? self.originResInfo : [NSNull null],
                             @"resArray":self.imageResArr ? self.imageResArr : [NSNull null]
                             };
    NSString *des = [imgDic description];
    return des;
}

@end

@implementation BTVideoInfo

- (NSString*)description
{
    NSDictionary *videoDic = @{
                               @"originURL":self.originVideoURL ? self.originVideoURL.absoluteString : [NSNull null],
                               @"posterURL":self.posterURL ? self.posterURL : [NSNull null],
                               @"fileType":self.fileType ? self.fileType : [NSNull null],
                               @"resArray":self.resolutionInfo ? self.resolutionInfo : [NSNull null]
                               };
    NSString *des = [videoDic description];
    return des;
}

@end

@implementation BTPost

- (void)setTitle:(NSString *)title
{
    if ([title isKindOfClass:[NSNull class]] || [title isEqualToString:@"<null>"]) {
        _title = NULL;
    }else{
        _title = title;
    }
}

- (BOOL)isLiked
{
    return self.likedTimestamp > 0;
}

- (NSString*)description
{
    NSDictionary *postDic = @{
                              @"type":@(self.type),
                              @"id":@(self.postid),
                              @"title":self.title,
                              @"blog":self.blogInfo.name,
                              @"text":self.text ? self.text : [NSNull null],
                              @"photos":self.imageInfos ? self.imageInfos : [NSNull null],
                              @"videoInfo":self.videoInfo ? self.videoInfo : [NSNull null],
                              @"postTime":@(self.postTime),
                              @"isLiked":@(self.isLiked)
//                              @"contentBody":self.contentBody ? self.contentBody : [NSNull null]
                              };
    NSString *des = [postDic description];
    return des;
}

@end
