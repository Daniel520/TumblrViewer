//
//  BTRootViewController.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/28.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTRootViewController.h"
#import "APIAccessHelper.h"
#import "BTDashboardCollectionCell.h"
#import "BTPost.h"
#import "BTPostGallaryViewController.h"

#import "HTMLParser.h"
#import <MJRefresh.h>

#import <CHTCollectionViewWaterfallLayout.h>
//#import "LJJWaterFlowLayout.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>



@interface BTRootViewController () <UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) NSArray *dashboardImgArr;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

//test
#warning  now is skip post type video, so use currentOffset to mark the offset. should disable in future
@property (nonatomic, assign) NSInteger currentOffset;
@property (nonatomic, strong) NSArray<BTPost*> *dashboardArr;

@end

@implementation BTRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:TRUE animated:NO];
//    self.view.backgroundColor = [UIColor grayColor];
    self.currentOffset = 0;
    self.title = @"Dashboard";
    [self loadData:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initDashboardCollectView];
    
}

- (void)showLoading
{
    if (!self.loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loadingView = loadingView;
    }
    
    self.loadingView.center = self.view.center;
    self.loadingView.color = UIColor.grayColor;
    [self.view addSubview:self.loadingView];
    [self.loadingView startAnimating];
}

- (void)hideLoading
{
    [self.loadingView stopAnimating];
    [self.loadingView removeFromSuperview];
}

- (void)loadData:(BOOL)isLoadMore
{
    BTWeakSelf(weakSelf);
    
    TMAPIClient *apiClient = [[APIAccessHelper shareApiAccessHelper] generateApiClient];
    
    NSURLSessionTask *task = nil;
    
//    NSInteger offset = 0;
    
    if (!isLoadMore) {
        
        //refresh current offset
        self.currentOffset = 0;
        
        //Just refresh to show loading
        [self showLoading];
        
        // clear data to refresh
//        self.dashboardImgArr = [NSArray new];
        self.dashboardArr = [NSArray new];
    }
    
    task = [apiClient dashboardRequest:@{@"limit":@20,@"offset":@(self.currentOffset)} callback:^( id _Nullable response, NSError * _Nullable error){
        
        [weakSelf hideLoading];
        
        if (error) {
            NSLog(@"error info:%@",error);
        }
//        NSLog(@"%@",response);
//        weakSelf.textView.text = [response description];

//        weakSelf.dashboardDic = response;
        //to get the img data and set to self.dashboardImgArr
        weakSelf.currentOffset += 20;
        [weakSelf translteDashboardData:response];
        
        [weakSelf updateDashboard];
    }];

    [task resume];

//    task = [apiClient userInfoDataTaskWithCallback:^( id _Nullable response, NSError * _Nullable error){
//        NSLog(@"%@",response);
//    }];
//
//    [task resume];
//
//    task = [apiClient likesDataTaskWithParameters:@{@"limit":@20, @"after":@1498759736} callback:^( id _Nullable response, NSError * _Nullable error){
//        NSLog(@"%@",response);
//    }];
//
//    [task resume];
    
}

- (void)translteDashboardData:(NSDictionary*)response
{
    NSArray *tmPosts = [response objectForKey:@"posts"];
    
    NSMutableArray *posts = [NSMutableArray new];
    
    for (NSDictionary *postDic in tmPosts) {
        NSString *type = [postDic objectForKey:@"type"];
//        BTPost *post = [BTPost new];
        
        if ([type isEqualToString:@"text"]) {
//            NSString *body = [postDic objectForKey:@"body"];
            BTPost *post = [self translatePostDic:postDic];
            
            if (post) {
                [posts addObject:post];
            }
            
        } else if ([type isEqualToString:@"photo"]) {
            
//            NSArray *postImages = [postDic objectForKey:@"photos"];
//            NSArray *imgURLs = [self getImageURLsFromPhotos:postImages];
            
            NSArray *imageInfos = [self translateImageFromDic:postDic];
            
            if (imageInfos && imageInfos.count > 0) {
                BTPost *post = [BTPost new];
                post.type = DBPhoto;
//                post.imgURLs = imgURLs;
                post.imageInfos = imageInfos;
                
                [posts addObject:post];
            }
        } else if ([type isEqualToString:@"video"]) {
            
            BTPost *post = [self translateVideoPostDic:postDic];
            
            if (post) {
                [posts addObject:post];
            }
        }
    }
    
    
    self.dashboardArr = [self.dashboardArr arrayByAddingObjectsFromArray:posts];
//    self.dashboardImgArr = [self.dashboardImgArr arrayByAddingObjectsFromArray:posts];
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

- (NSArray*)getImageURLsFromPhotos:(NSArray *)photos
{
    NSMutableArray *imgURLs = [NSMutableArray new];
    
    for (NSDictionary *photoDic in photos) {
        NSArray *alt_sizes = [photoDic objectForKey:@"alt_sizes"];
        
        //get the last 2 (100 size) image for dashboard page show
        NSDictionary *imgDic = [alt_sizes objectAtIndex:alt_sizes.count - 2];
//        NSString *imgURL = [sizeDic objectForKey:@"url"];
        
        [imgURLs addObject:imgDic];
        
    }
    
    return imgURLs > 0 ? [imgURLs copy] : NULL;
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
        
        if (![BTUtils isStringEmpty:videoInfoString]) {
            
            
            if (error) {
                NSLog(@"Error: %@", error);
                continue;
            }
            
            HTMLParser *parser = [[HTMLParser alloc] initWithString:videoInfoString error:&error];
            
            if (error) {
                NSLog(@"Error: %@", error);
                return nil;
            }
            
            HTMLNode *bodyNode = [parser body];
            
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
        post.type = DBVideo;
    }
    
    return post;
    
}

- (BTPost*)translatePostDic:(NSDictionary*)postDic
{
    NSError *error = nil;
    NSMutableArray<BTImageInfo*> *imageInfos = [NSMutableArray new];
    NSString *content = @"";
    
    NSString *body = [postDic objectForKey:@"body"];
    
    if ([BTUtils isStringEmpty:body]) {
        content = [postDic objectForKey:@"title"];
        BTPost *post = [BTPost new];
        post.type = DBText;
        post.text = content;
        
        return post;
    }
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:body error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    HTMLNode *bodyNode = [parser body];
    
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
        
        if (imageNodes.count == 0) {
            content = [bodyNode allContents];
//            NSArray *textNodes = [bodyNode findChildTags:@"p"];
//
//            for (HTMLNode *textNode in textNodes) {
//                content = [[content stringByAppendingString:[textNode contents]] stringByAppendingString:@"\n"];
//
//            }
        }
        
    }
    
    BTPost *post = [BTPost new];
    post.contentBody = body;
    if (imageInfos && imageInfos.count > 0) {
        post.type = DBPhoto;
//        post.imgURLs = imgURLs;
        post.imageInfos = [imageInfos copy];
    } else {
        post.type = DBText;
        post.text = content;
    }
    
    return post;
}

//- (NSDictionary *)translateImgDicByHTMLNode:(HTMLNode*)htmlNode
//{
//    NSString *imgURL = [htmlNode getAttributeNamed:@"src"];
//    long imgHeight  = [[htmlNode getAttributeNamed:@"data-orig-height"] longLongValue];
//    long imgWidth   = [[htmlNode getAttributeNamed:@"data-orig-width"] longLongValue];
//
//    //translate the size to 100 to show in dashboard
//    imgHeight = 100 * imgHeight/imgWidth;
//    imgWidth = 100;
//
//    NSDictionary *imgDic = @{@"url":imgURL,@"width":[NSNumber numberWithLong:imgWidth],@"height":[NSNumber numberWithLong:imgHeight]};
//    return imgDic;
//}

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
    

- (void)updateDashboard
{
//    if (!self.mainCollectionView) {
//        [self initDashboardCollectView];
//    }
    
    [self.mainCollectionView reloadData];
    [self collectionStopRefreshData];
}

- (void)collectionStopRefreshData
{
    self.mainCollectionView.mj_header.endRefreshingCompletionBlock = ^{
        NSLog(@"header end refresh");
    };
    [self.mainCollectionView.mj_header endRefreshing];
    
    self.mainCollectionView.mj_footer.endRefreshingCompletionBlock = ^{
        NSLog(@"footer end refresh");
    };
    
    [self.mainCollectionView.mj_footer endRefreshing];
}

- (void)initDashboardCollectView
{
    BTWeakSelf(weakSelf);
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];

    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 5;
    layout.minimumInteritemSpacing = 0;
    layout.columnCount = 4;
//    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst;
    
    self.mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20) collectionViewLayout:layout];
    self.mainCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mainCollectionView.dataSource = self;
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.backgroundColor = [UIColor whiteColor];
    [self.mainCollectionView registerClass:[BTDashboardCollectionCell class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER];
    [self.view addSubview:self.mainCollectionView];
    //    [_collectionView registerClass:[CHTCollectionViewWaterfallHeader class]
    //        forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
    //               withReuseIdentifier:HEADER_IDENTIFIER];
    //    [_collectionView registerClass:[CHTCollectionViewWaterfallFooter class]
    //        forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
    //               withReuseIdentifier:FOOTER_IDENTIFIER];
    
    self.mainCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData:NO];
    }];
    
    self.mainCollectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadData:YES];
    }];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dashboardArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BTDashboardCollectionCell *cell =
    (BTDashboardCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                forIndexPath:indexPath];
    BTPost *post = [self.dashboardArr objectAtIndex:indexPath.item];
    [cell setPost:post];
    
//    cell.imgDicArr = [self.dashboardImgArr objectAtIndex:indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BTPost *post = [self.dashboardArr objectAtIndex:indexPath.item];
    
    switch (post.type) {
        case DBVideo:
            {
                BTPostGallaryViewController *vc = [[BTPostGallaryViewController alloc] initWithPost:post];
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
            
        default:
            break;
    }
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    UICollectionReusableView *reusableView = nil;
//
//    if ([kind isEqualToString:CHTCollectionElementKindSectionHeader]) {
//        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
//                                                          withReuseIdentifier:HEADER_IDENTIFIER
//                                                                 forIndexPath:indexPath];
//    } else if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
//        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
//                                                          withReuseIdentifier:FOOTER_IDENTIFIER
//                                                                 forIndexPath:indexPath];
//    }
//
//    return reusableView;
//}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BTPost *post = [self.dashboardArr objectAtIndex:indexPath.item];
//    if (post.type == DBPhoto) {
//        //now use 100 width to show, then the height should sum all the photos' height
//        long width = 100;
//        long height = 0;
//
//        for (NSDictionary *imgDic in post.imgURLs) {
//            long originWidth = [(NSNumber*)[imgDic objectForKey:@"width"] longValue];
//            long originHeight = [(NSNumber*)[imgDic objectForKey:@"height"] longValue];
//
//            long adjustHeight = originHeight * width/originWidth;
//
//            if (adjustHeight > SCREEN_HEIGHT) {
//                adjustHeight = SCREEN_HEIGHT;
//            }
//
//            height += adjustHeight;
//
//        }
//
//        return CGSizeMake(width, height);
//
//    } else if (post.type == DBText) {
//        //now use 100 width to show, text height hardcode now to 150;
//        return CGSizeMake(100, 150);
//    }
    
    
    //now use 100 width to show, then the height should sum all the photos/text/video's height
    long width = 100;
    
    switch (post.type) {
        case DBPhoto:
        {
           
            CGFloat height = 0;
            
            NSInteger resIndex = 0;
            
            CGFloat originWidth = 0, originHeight = 0;
            
            for (BTImageInfo *imageInfo in post.imageInfos) {
                if (imageInfo.imageResArr && imageInfo.imageResArr.count > 0) {
                    resIndex = imageInfo.imageResArr.count - 2;
                    //get the last - 1 res for list view to display
                    BTResInfo *resInfo = [imageInfo.imageResArr objectAtIndex:resIndex];
                    originWidth = resInfo.size.width;
                    originHeight = resInfo.size.height;
                } else {
                    BTResInfo *resInfo = imageInfo.originResInfo;
                    originWidth = resInfo.size.width;
                    originHeight = resInfo.size.height;
                }
                
                CGFloat adjustHeight = originHeight * width/originWidth;
                
                if (adjustHeight > SCREEN_HEIGHT) {
                    adjustHeight = SCREEN_HEIGHT;
                }
                
                height += adjustHeight;
            }
            
//            for (NSDictionary *imgDic in post.imgURLs) {
//                long originWidth = [(NSNumber*)[imgDic objectForKey:@"width"] longValue];
//                long originHeight = [(NSNumber*)[imgDic objectForKey:@"height"] longValue];
//
//                long adjustHeight = originHeight * width/originWidth;
//
//                if (adjustHeight > SCREEN_HEIGHT) {
//                    adjustHeight = SCREEN_HEIGHT;
//                }
//
//                height += adjustHeight;
//
//            }
            
            return CGSizeMake(width, height);
        }
            break;
        case DBText:
        {
            //now use 100 width to show, text height hardcode now to 150;
            return CGSizeMake(width, 150);
        }
            break;
        case DBVideo:{
            CGFloat originWidth = post.videoInfo.resolutionInfo[0].size.width;
            CGFloat originHeight = post.videoInfo.resolutionInfo[0].size.height;
            
            CGFloat height = originHeight * width/originWidth;
            
            return CGSizeMake(width, height);
        }
            break;
        default:
            break;
    }
    
    return CGSizeMake(0, 0);
    
//    NSArray *imgDics = [self.dashboardImgArr objectAtIndex:indexPath.item];
//
//    //now use 100 width to show, then the height should sum all the photos' height
//    long width = 100;
//    long height = 0;
//
//    for (NSDictionary *imgDic in imgDics) {
//        long originWidth = [(NSNumber*)[imgDic objectForKey:@"width"] longValue];
//        long originHeight = [(NSNumber*)[imgDic objectForKey:@"height"] longValue];
//
//        long adjustHeight = originHeight * width/originWidth;
//
//        if (adjustHeight > SCREEN_HEIGHT) {
//            adjustHeight = SCREEN_HEIGHT;
//        }
//
//        height += adjustHeight;
//
//    }
//
//    return CGSizeMake(width, height);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
