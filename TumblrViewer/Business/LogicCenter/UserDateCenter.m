//
//  UserDateCenter.m
//  TumblrViewer
//
//  Created by Daniel on 2019/7/14.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "UserDateCenter.h"
#import "APIAccessHelper.h"
#import "BTToastManager.h"

#define PAGELEN 100

@interface UserDateCenter()

@property (nonatomic, strong) NSMutableArray *userArr;
@property (nonatomic, assign) NSInteger currentOffset;
@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, assign, readwrite) BOOL isNoMoreData;
@property (nonatomic, assign) NSUInteger lastDataHash;
@property (nonatomic, strong) NSDictionary *lastDataDic;
@property (nonatomic, assign) NSInteger totalUsers;

@end


@implementation UserDateCenter

- (void)loadData:(BOOL)isLoadMore callback:(nonnull UserDataCallback)callback
{
    if (self.isLoading) {
        return;
    }
    
    self.isLoading = YES;
    BTWeakSelf(weakSelf);
    
    if (!isLoadMore) {
        
        //refresh current offset
        self.currentOffset = 0;
        
        // clear data to refresh
        //        self.dashboardImgArr = [NSArray new];
        self.userArr = [NSMutableArray new];
    } else if(self.isNoMoreData || self.totalUsers <= self.userArr.count) {
        //No more data, so do nothing
        callback(nil, nil, Data_Status_End);
        return;
    }
    
    [[APIAccessHelper shareApiAccessHelper] requestFollowing:self.currentOffset count:PAGELEN callback:^(NSDictionary *usersDic, NSError *error){
        
        if (error) {
            [BTToastManager showToastWithText:@"Network Error, please try again"];
            NSLog(@"error info:%@",error);
        }
        
        NSArray *blogs = [usersDic objectForKey:@"blogs"];
        
        //Set total user number in the first time, to avoid the total number update in the load more request, but the data is under "Reverse order".
        //So the data will never hit the total number during load more.
        if (!isLoadMore) {
            weakSelf.totalUsers = [[usersDic objectForKey:@"total_blogs"] integerValue];
        }
        
        NSMutableArray *tmblogList = [NSMutableArray new];
        for (NSDictionary *blogDic in blogs) {
            //        BTBlogInfo *blog = [BTBlogInfo new];
            //        blog.followers = [[blogDic objectForKey:@"followers"] integerValue];
            //        blog.isAdmin = [[blogDic objectForKey:@"admin"] boolValue];
            //        blog.isNsfw = [[blogDic objectForKey:@"is_nsfw"] boolValue];
            //        blog.blogUrl = [blogDic objectForKey:@"url"];
            //        blog.uuid = [blogDic objectForKey:@"uuid"];
            //        blog.isBlockedFromPrimary = [blogDic objectForKey:@"is_blocked_from_primary"];
            BTBlogInfo *blog = [BTBlogInfo createBlogInfoByDic:blogDic];
            [tmblogList addObject:blog];
        }
        
        self.currentOffset += tmblogList.count;
        
        [weakSelf.userArr addObjectsFromArray:tmblogList];
        
        if (weakSelf.userArr.count >= weakSelf.totalUsers) {
            self.isNoMoreData = YES;
            callback(nil, nil, Data_Status_End);
        }else{
            callback(tmblogList, error, Data_Status_Normal);
        }
        
        
        weakSelf.isLoading = NO;
    }];
}

- (void)loadDataFromBlog:(NSString*)blogId loadMore:(BOOL)isLoadMore callback:(nonnull UserDataCallback)callback
{
    
}

- (NSArray*)users
{
    return [self.userArr copy];
}

@end
