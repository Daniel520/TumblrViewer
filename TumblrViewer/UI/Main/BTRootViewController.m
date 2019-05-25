//
//  BTRootViewController.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/28.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTRootViewController.h"
#import "BTDashboardCollectionCell.h"
#import "BTPost.h"
#import "BTPostGallaryViewController.h"
#import "BTVideoPlayViewController.h"

#import "PostsDataCenter.h"
#import <MJRefresh.h>

#import <CHTCollectionViewWaterfallLayout.h>
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>



@interface BTRootViewController () <UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) PostsDataCenter *postDataCenter;

@end

@implementation BTRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:TRUE animated:NO];
//    self.view.backgroundColor = [UIColor grayColor];
//    self.currentOffset = 0;
    self.title = @"Dashboard";
    self.postDataCenter = [PostsDataCenter new];
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
    
    if (!isLoadMore) {
        [self showLoading];
    }
    
    [self.postDataCenter loadData:isLoadMore withType:Type_Dashboard callback:^(NSArray<BTPost*> *posts, NSError * error){

        if (error) {
            NSLog(@"error info:%@",error);
        }
        
        [weakSelf hideLoading];
        
        [weakSelf updateDashboard];
    }];
}

- (void)updateDashboard
{
    
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
    return self.postDataCenter.posts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BTDashboardCollectionCell *cell =
    (BTDashboardCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                forIndexPath:indexPath];
    BTPost *post = [self.postDataCenter.posts objectAtIndex:indexPath.item];
    [cell setPost:post];
    
//    cell.imgDicArr = [self.dashboardImgArr objectAtIndex:indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BTPost *post = [self.postDataCenter.posts objectAtIndex:indexPath.item];
    
    switch (post.type) {
        case DBVideo:
            {
                BTVideoPlayViewController *vc = [[BTVideoPlayViewController alloc] initWithPost:post];
//                BTPostGallaryViewController *vc = [[BTPostGallaryViewController alloc] initWithPost:post];
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
    
    BTPost *post = [self.postDataCenter.posts objectAtIndex:indexPath.item];
    
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
