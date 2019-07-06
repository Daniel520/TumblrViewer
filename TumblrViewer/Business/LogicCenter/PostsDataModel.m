//
//  PostsDataCenter.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/5/25.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "PostsDataModel.h"
#import "APIAccessHelper.h"
#import "HTMLParser.h"
#import "BTToastManager.h"

#define PAGELEN 20


@interface PostsDataModel()

@property (nonatomic, strong) NSMutableArray *postArr;
@property (nonatomic, assign) NSInteger currentOffset;
@property (nonatomic, assign, readwrite) BOOL isLoadingPosts;
@property (nonatomic, assign, readwrite) BOOL isNoMoreData;
@property (nonatomic, assign) NSUInteger lastDataHash;
@property (nonatomic, strong) NSDictionary *lastDataDic;
@property (nonatomic, assign) NSInteger totalPosts;

@end

@implementation PostsDataModel

- (id)copyWithZone:(NSZone *)zone
{
    PostsDataModel *postDataModel = [[[self class] allocWithZone:zone] init];
    postDataModel.postArr = [self.postArr mutableCopy];
    postDataModel.currentOffset = self.currentOffset;
    return postDataModel;
}

- (NSArray*)posts
{
    return [self.postArr copy];
}

- (void)loadData:(BOOL)isLoadMore callback:(nonnull PostsDataCallback)callback;
{
    if (self.isLoadingPosts) {
        return;
    }
    
    self.isLoadingPosts = YES;
    BTWeakSelf(weakSelf);
    
    if (!isLoadMore) {
        
        //refresh current offset
        self.currentOffset = 0;
        
        // clear data to refresh
        //        self.dashboardImgArr = [NSArray new];
        self.postArr = [NSMutableArray new];
    } else if(self.isNoMoreData) {
        //No more data, so do nothing
        callback(nil, nil, Data_Status_End);
        return;
    }
    
#warning todo try to use since_id as use offset we find it will return the same data
    NSLog(@"load dashboard data from offset:%d, length:%d",self.currentOffset, PAGELEN);
    if (self.currentOffset == 0) {
        [[APIAccessHelper shareApiAccessHelper] requestDashboardStart:self.currentOffset count:PAGELEN callback:^(NSDictionary *dashboardDic, NSError *error){
            
            if (error) {
                [BTToastManager showToastWithText:@"Network Error, please try again"];
                NSLog(@"error info:%@",error);
            }
            
//            if ([self isPostDataEnd:dashboardDic]) {
//                self.isNoMoreData = YES;
//                callback(nil, error, Data_Status_End);
//            }
            //
            //        if (dashboardDic != nil) {
            //            weakSelf.lastDataHash = [[dashboardDic description] hash];
            //            weakSelf.lastDataDic = dashboardDic;
            //        }
            
            //                weakSelf.currentOffset += weakSelf.postArr.count;
            //                weakSelf.currentOffset += PAGELEN;
            NSArray *returnPosts = [weakSelf translteDashboardData:dashboardDic];
            
            [weakSelf.postArr addObjectsFromArray:returnPosts];
            
            callback(returnPosts, error, Data_Status_Normal);
            
            weakSelf.isLoadingPosts = NO;
        }];
    } else {
        NSInteger sinceId  = [[self.posts lastObject] postid];
        [[APIAccessHelper shareApiAccessHelper] requestDashboardSince:sinceId count:PAGELEN callback:^(NSDictionary *dashboardDic, NSError *error){

            if (error) {
                [BTToastManager showToastWithText:@"Network Error, please try again"];
                NSLog(@"error info:%@",error);
            }

//            if ([self isPostDataEnd:dashboardDic]) {
//                self.isNoMoreData = YES;
//                callback(nil, error, Data_Status_End);
//            }
            //
            //        if (dashboardDic != nil) {
            //            weakSelf.lastDataHash = [[dashboardDic description] hash];
            //            weakSelf.lastDataDic = dashboardDic;
            //        }

            //                weakSelf.currentOffset += weakSelf.postArr.count;
            //                weakSelf.currentOffset += PAGELEN;
            NSArray *returnPosts = [weakSelf translteDashboardData:dashboardDic];

            [weakSelf.postArr addObjectsFromArray:returnPosts];

            callback(returnPosts, error, Data_Status_Normal);

            weakSelf.isLoadingPosts = NO;
        }];
    }
    
//    break;
//}
//        case Type_BlogPost:{
////            [APIAccessHelper shareApiAccessHelper] requestPostFromBlogId:<#(nonnull NSString *)#> type:<#(nonnull NSString *)#> Start:<#(NSInteger)#> count:<#(NSInteger)#> callback:<#^(NSDictionary * _Nonnull dashboardDic, NSError * _Nonnull error)callback#>
//        }
//
//            break;
//
//        default:
//            break;
//    }
}

- (void)loadDataFromBlog:(NSString*)blogId loadMore:(BOOL)isLoadMore callback:(nonnull PostsDataCallback)callback;
{
    if (self.isLoadingPosts) {
        return;
    }
 
    if ([BTUtils isStringEmpty:blogId]) {
        [BTToastManager showToastWithText:NSLocalizedString(@"network_error", nil)];
        return;
    }
    
    if (self.totalPosts == self.posts.count || self.isNoMoreData) {
        self.isNoMoreData = YES;
        callback(nil, nil, Data_Status_End);
    }
    
    self.isLoadingPosts = YES;
    BTWeakSelf(weakSelf);
    
    if (!isLoadMore) {
        
        //refresh current offset
        self.currentOffset = 0;
        
        // clear data to refresh
        //        self.dashboardImgArr = [NSArray new];
        self.postArr = [NSMutableArray new];
    }
    
    NSLog(@"load posts data from offset:%d, length:%d",self.currentOffset, PAGELEN);
    
    [[APIAccessHelper shareApiAccessHelper] requestPostFromBlogId:blogId type:nil Start:self.currentOffset count:PAGELEN callback:^(NSDictionary *dashboardDic, NSError *error){
        
        if (error) {
            [BTToastManager showToastWithText:NSLocalizedString(@"network_error", nil)];
            NSLog(@"error info:%@",error);
        }
        
        self.totalPosts = [[[dashboardDic objectForKey:@"blog"] objectForKey:@"posts"] integerValue];
        
        if ([self isPostDataEnd:dashboardDic] || self.totalPosts == self.posts.count) {
            self.isNoMoreData = YES;
            callback(nil, error, Data_Status_End);
            weakSelf.isLoadingPosts = NO;
        }
        
        //                weakSelf.currentOffset += weakSelf.postArr.count;
        //                weakSelf.currentOffset += PAGELEN;
        NSArray *returnPosts = [weakSelf translteDashboardData:dashboardDic];
        
        [weakSelf.postArr addObjectsFromArray:returnPosts];
        
        callback(returnPosts, error, Data_Status_Normal);
        
        weakSelf.isLoadingPosts = NO;
    }];
}

- (BOOL)isPostDataEnd:(NSDictionary*)postsDic
{
//    NSArray *tmPosts = [postsDic objectForKey:@"posts"];
//    if (tmPosts.count > 0) {
//        NSInteger lastPostID = [[[tmPosts lastObject] objectForKey:@"id"] integerValue];
//
//        // if the last return data post id equal to the current loaded data last post instance post id, then it should be the end of data
//        if (lastPostID == [(BTPost*)[self.posts lastObject] postid]) {
//            return YES;
//        }
//    }
    
    if (self.lastDataHash == [[postsDic description] hash]) {
        //two data hash the same mean it's the end of data
        return YES;
    }
    return NO;
}

- (NSArray *)translteDashboardData:(NSDictionary*)dashboardDic
{
    NSArray *tmPosts = [dashboardDic objectForKey:@"posts"];
    
    self.currentOffset += tmPosts.count;
    
    NSMutableArray *posts = [NSMutableArray new];
    
    for (NSDictionary *postDic in tmPosts) {
        NSString *type = [postDic objectForKey:@"type"];
        //        BTPost *post = [BTPost new];
        
        BTBlogInfo *blog = [BTBlogInfo createBlogInfoByDic:[postDic objectForKey:@"blog"]];
        BTPost *post = nil;
        if ([type isEqualToString:@"text"]) {
            //            NSString *body = [postDic objectForKey:@"body"];
            post = [self translatePostDic:postDic];
            post.postid = [[postDic objectForKey:@"id"] integerValue];
            post.reblogKey = [postDic objectForKey:@"reblog_key"];
            
//            if (post) {
//                [posts addObject:post];
//            }
            
        } else if ([type isEqualToString:@"photo"]) {
            
            //            NSArray *postImages = [postDic objectForKey:@"photos"];
            //            NSArray *imgURLs = [self getImageURLsFromPhotos:postImages];
            
            NSArray *imageInfos = [self translateImageFromDic:postDic];
            
            NSDictionary *reblogDic = [postDic objectForKey:@"reblog"];
            NSString *reblogContent = [reblogDic objectForKey:@"tree_html"];
            
            NSArray *reblogImageInfos = [self extractImageFromHtml:reblogContent withPostDic:postDic];
            
            imageInfos = [imageInfos arrayByAddingObjectsFromArray:reblogImageInfos];
            
            if (imageInfos && imageInfos.count > 0) {
                post = [BTPost new];
                post.type = BTPhoto;
                NSString *title = [postDic objectForKey:@"title"];
                if ([title isKindOfClass:[NSNull class]] || [title isEqualToString:@"<null>"]) {
                    post.title = [postDic objectForKey:@"blog_name"];
                }else{
                    post.title = title;
                }
                //                post.imgURLs = imgURLs;
                post.imageInfos = imageInfos;
                post.postid = [[postDic objectForKey:@"id"] integerValue];
                post.reblogKey = [postDic objectForKey:@"reblog_key"];
                
//                [posts addObject:post];
            }
        } else if ([type isEqualToString:@"video"]) {
            
            post = [self translateVideoPostDic:postDic];
            post.postid = [[postDic objectForKey:@"id"] integerValue];
            post.reblogKey = [postDic objectForKey:@"reblog_key"];
            
//            if (post) {
//                [posts addObject:post];
//            }
        }
        
        if (post) {
            post.blogInfo = blog;
            [posts addObject:post];
        }
    }
    
    
    return posts;
    //    self.dashboardImgArr = [self.dashboardImgArr arrayByAddingObjectsFromArray:posts];
}

- (NSArray *)extractImageFromHtml:(NSString*)bodyString withPostDic:(NSDictionary*)postDic
{
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:bodyString error:&error];
    
    if (error) {
        NSLog(@"Error: %@ withbody:%@ in postid:%@", error, bodyString, [postDic objectForKey:@"id"]);
        return nil;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSMutableArray<BTImageInfo*> *imageInfos = [NSMutableArray new];
    
    NSArray *imgNodes = [bodyNode findChildTags:@"img"];
    
    if (imgNodes.count > 0) {
        
        for (HTMLNode *imgNode in imgNodes) {
            
            //            NSDictionary *imgDic = [self translateImgDicByHTMLNode:imgNode];
            //            [imgURLs addObject:imgDic];
            BTImageInfo *imageInfo = [self translateImgDicByHTMLNode:imgNode];
            if (imageInfo) {
                [imageInfos addObject:imageInfo];
            }
        }
        
    } else if (imgNodes.count == 0) {
        
        NSArray *imageNodes = [bodyNode findChildTags:@"image"];
        
        for (HTMLNode *imgNode in imageNodes) {
            
            //            NSDictionary *imgDic = [self translateImgDicByHTMLNode:imgNode];
            //            [imgURLs addObject:imgDic];
            BTImageInfo *imageInfo = [self translateImgDicByHTMLNode:imgNode];
            if (imageInfo) {
                [imageInfos addObject:imageInfo];
            }
        }
        
    }
    
    if (imageInfos.count > 0) {
        return imageInfos;
    }
    
    return nil;
}

- (BTPost*)translatePostDic:(NSDictionary*)postDic
{
    NSError *error = nil;
//    NSMutableArray<BTImageInfo*> *imageInfos = [NSMutableArray new];
    NSString *content = @"";
    
    NSString *body = [postDic objectForKey:@"body"];
    
    if ([BTUtils isStringEmpty:body]) {
        content = [postDic objectForKey:@"title"];
        BTPost *post = [BTPost new];
        post.type = BTText;
        NSString *title = [postDic objectForKey:@"title"];
        if ([title isKindOfClass:[NSNull class]] || [title isEqualToString:@"<null>"]) {
            post.title = [postDic objectForKey:@"blog_name"];
        }else{
            post.title = title;
        }
        post.text = content;
        
        return post;
    }
    
//    HTMLParser *parser = [[HTMLParser alloc] initWithString:body error:&error];
//
//    if (error) {
//        NSLog(@"Error: %@", error);
//        return nil;
//    }
//
//    HTMLNode *bodyNode = [parser body];
    
    NSArray *imageInfos = [self extractImageFromHtml:body withPostDic:postDic];
    
//    //load html reblog image. but find it's duplicate with the main post images, so comment first
//    NSDictionary *reblogDic = [postDic objectForKey:@"reblog"];
//    NSString *reblogContent = [reblogDic objectForKey:@"tree_html"];
//
//    NSArray *reblogImageInfos = [self extractImageFromHtml:reblogContent];
//
//    imageInfos = [imageInfos arrayByAddingObjectsFromArray:reblogImageInfos];
    
    if (imageInfos.count == 0) {
        HTMLParser *parser = [[HTMLParser alloc] initWithString:body error:&error];
        
        if (error) {
            NSLog(@"Error: %@ with bodyString:%@ in postid:%@", error, body, [postDic objectForKey:@"id"]);
            return nil;
        }
        
        HTMLNode *bodyNode = [parser body];
        
        NSArray *videoNodes = [bodyNode findChildTags:@"video"];
        
        if (videoNodes.count > 0) {
#warning todo translate video wording
            content = [@"video:\n" stringByAppendingString:[bodyNode allContents]];
        }else{
            content = [bodyNode allContents];
        }
    }
    
    BTPost *post = [BTPost new];
    post.contentBody = body;
    NSString *title = [postDic objectForKey:@"title"];
    if ([title isKindOfClass:[NSNull class]] || [title isEqualToString:@"<null>"]) {
        post.title = [postDic objectForKey:@"blog_name"];
    }else{
        post.title = title;
    }
    
    if (imageInfos && imageInfos.count > 0) {
        post.type = BTPhotoText;
        //        post.imgURLs = imgURLs;
        post.imageInfos = [imageInfos copy];
    } else {
        post.type = BTText;
        post.text = content;
    }
    
    return post;
}

- (NSArray*)translateImageFromDic:(NSDictionary*)postDic
{
    
    NSArray *postImages = [postDic objectForKey:@"photos"];
    
    if (postImages.count > 0) {
        
        NSMutableArray<BTImageInfo*> *imageInfos = [NSMutableArray new];
        
        for (NSDictionary *photoDic in postImages) {
            
            BTImageInfo *imageInfo = [BTImageInfo new];
            
            BTResInfo *originRes = [BTResInfo new];
            
            NSDictionary *originSizeDic = [postDic objectForKey:@"original_size"];
            
            originRes.resUrl = [NSURL URLWithString:[originSizeDic objectForKey:@"url"]];
            originRes.size = CGSizeMake([[originSizeDic objectForKey:@"width"] floatValue], [[originSizeDic objectForKey:@"height"] floatValue]);
            
            imageInfo.originResInfo = originRes;
            
            NSMutableArray<BTResInfo*> *imageResArr = [NSMutableArray new];
            
            NSArray *alt_sizes = [photoDic objectForKey:@"alt_sizes"];
            
            for (NSDictionary *sizeDic in alt_sizes) {
                BTResInfo *resInfo = [BTResInfo new];
                resInfo.resUrl = [NSURL URLWithString:[sizeDic objectForKey:@"url"]];
                resInfo.size = CGSizeMake([[sizeDic objectForKey:@"width"] floatValue], [[sizeDic objectForKey:@"height"] floatValue]);
                [imageResArr addObject:resInfo];
            }
            
            //By default, the image resolutaion array is sort by Descending, suppose no need to sort again.
            //            [imageResArr sortUsingComparator:^NSComparisonResult(BTResInfo* info1, BTResInfo* info2){
            //
            //                if (info1.size.width > info2.size.width) {
            //                    return NSOrderedAscending;
            //                } else {
            //                    return NSOrderedDescending;
            //                }
            //
            //            }];
            
            imageInfo.imageResArr = [imageResArr copy];
            [imageInfos addObject:imageInfo];
        }
        
        return imageInfos;
    }
    
    return nil;
}

- (BTImageInfo *)translateImgDicByHTMLNode:(HTMLNode*)htmlNode
{
    NSString *imgURL = [htmlNode getAttributeNamed:@"src"];
    long imgHeight  = [[htmlNode getAttributeNamed:@"data-orig-height"] longLongValue];
    long imgWidth   = [[htmlNode getAttributeNamed:@"data-orig-width"] longLongValue];
    
    if (![BTUtils isStringEmpty:imgURL]) {
        BTImageInfo *imageInfo = [BTImageInfo new];
        BTResInfo *oriResInfo = [BTResInfo new];
        
        oriResInfo.resUrl = [NSURL URLWithString:imgURL];
        oriResInfo.size = CGSizeMake(imgWidth, imgHeight);
        
        imageInfo.originResInfo = oriResInfo;
        return imageInfo;
    }
    
    return nil;
}

- (BTPost*)translateVideoPostDic:(NSDictionary*)postDic
{
    NSArray *videoInfos = [postDic objectForKey:@"player"];
    BTPost *post = nil;
    NSError *error = nil;
    
    BTVideoInfo *videoInfo = [BTVideoInfo new];
    NSMutableArray *resInfoArray = [NSMutableArray new];
    
    for (NSDictionary *videoDic in videoInfos) {
        NSString *videoInfoString = [videoDic objectForKey:@"embed_code"];
        
        //found there's chance the emded_code without any video info but just Bool Type NO. So add a kindOfClass condition to avoid crash
        if ([videoInfoString isKindOfClass:[NSString class]] && ![BTUtils isStringEmpty:videoInfoString]) {
            
            
//            if (error) {
//                NSLog(@"Error: %@", error);
//                continue;
//            }
            
            HTMLParser *parser = [[HTMLParser alloc] initWithString:videoInfoString error:&error];
            
            if (error) {
                NSLog(@"Error: %@ with videoInfoString:%@ in postid:%@", error, videoInfoString, [postDic objectForKey:@"id"]);
                return nil;
            }
            
            HTMLNode *bodyNode = [parser body];
            
            NSArray *videoNodes = [bodyNode findChildTags:@"video"];
            if (videoNodes.count == 0) {
#warning todo, to support order third party video link, like youtube
                continue;
            }
            HTMLNode *videoNode = [bodyNode findChildTags:@"video"][0];
            CGFloat width = [[videoNode getAttributeNamed:@"width"] floatValue];
            CGFloat height = [[videoNode getAttributeNamed:@"height"] floatValue];
            videoInfo.posterURL = [NSURL URLWithString:[videoNode getAttributeNamed:@"poster"]];
            videoInfo.originVideoURL = [NSURL URLWithString:[videoNode getAttributeNamed:@"video_url"]];
            
            
            
            BTResInfo *resInfo = [BTResInfo new];
            resInfo.size = CGSizeMake(width, height);
            
            HTMLNode *sourceNode = [videoNode findChildTags:@"source"][0];
            videoInfo.fileType = [sourceNode getAttributeNamed:@"type"];
            resInfo.resUrl = [NSURL URLWithString:[sourceNode getAttributeNamed:@"src"]];
            
            
            [resInfoArray addObject:resInfo];
            
        } else {
            continue;
        }
    }
    
    if (resInfoArray.count > 0) {
        //By default, the video resolutaion array is sort by Descending, suppose no need to sort again.
        //        [resInfoArray sortUsingComparator:^NSComparisonResult(BTResInfo* info1, BTResInfo* info2){
        //
        //            if (info1.size.width > info2.size.width) {
        //                return NSOrderedAscending;
        //            } else {
        //                return NSOrderedDescending;
        //            }
        //
        //        }];
        
        videoInfo.resolutionInfo = [resInfoArray copy];
        
        post = [BTPost new];
        post.videoInfo = videoInfo;
        
        NSString *title = [postDic objectForKey:@"title"];
        if ([title isKindOfClass:[NSNull class]] || [title isEqualToString:@"<null>"]) {
            post.title = [postDic objectForKey:@"blog_name"];
        }else{
            post.title = title;
        }
        
        post.type = BTVideo;
    }
    
    return post;
    
}

@end
