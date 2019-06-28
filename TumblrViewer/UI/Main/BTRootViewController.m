//
//  BTRootViewController.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/28.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTRootViewController.h"
#import "BTPostListViewController.h"
#import "BTPost.h"

#import <UIButton+WebCache.h>

#import "XWSLeftView.h"
#import "APIAccessHelper.h"
#import "LoginViewController.h"


@interface BTRootViewController () <XWSLeftViewDelegate>
//<UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout,BTPostContentActionDelegate, UIScrollViewDelegate>

//@property (nonatomic, strong) UICollectionView *mainCollectionView;
//@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
//@property (nonatomic, strong) PostsDataModel *postDataModel;
//@property (nonatomic, assign) NSInteger dataFailCount;
//@property (nonatomic, assign) PostsType type;
@property (nonatomic, strong) BTBlogInfo *blogInfo;
@property (strong, nonatomic) XWSLeftView *leftMenuView;

@end

@implementation BTRootViewController

- (instancetype)initWithBlog:(BTBlogInfo*)blog
{
    self = [super init];
    if (self) {
        if (blog) {
            self.title = blog.name;
        }else{
            self.title = NSLocalizedString(@"dashboard", nil);
        }
        
        self.blogInfo = blog;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BTPostListViewController *vc = [[BTPostListViewController alloc] initWithBlog:self.blogInfo WithDataType:Type_Dashboard];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    
    [self setUpLeftMenuView];
}

- (void)setUpLeftMenuView{
    
    //setup navigation left button
    UIButton *profileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [profileBtn sd_setImageWithURL:[NSURL URLWithString:self.blogInfo.avatarPath] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar.png"]];
    
    [profileBtn.widthAnchor constraintEqualToConstant:35].active = YES;
    [profileBtn.heightAnchor constraintEqualToConstant:35].active = YES;
    [profileBtn addTarget:self action:@selector(showLeftMenuView:) forControlEvents:UIControlEventTouchUpInside];
//    profileBtn.layer.cornerRadius = 35/2;
//    profileBtn.layer.masksToBounds = YES;
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:profileBtn];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"account"] = self.blogInfo.name;
    dic[@"icon"] = self.blogInfo.avatarPath;
    
    if (!self.leftMenuView) {
        self.leftMenuView = [[XWSLeftView alloc] initWithFrame:CGRectZero withUserInfo:dic];
        [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor clearColor];
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.leftMenuView];
        self.leftMenuView.delegate = self;
        self.leftMenuView.hidden = YES;
        [self.leftMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.top.mas_equalTo(0);
            make.left.mas_equalTo(-SCREEN_WIDTH);
            make.width.mas_equalTo(SCREEN_WIDTH);
        }];
    }
}

- (IBAction)showLeftMenuView:(id)sender {
    self.leftMenuView.hidden = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [self.leftMenuView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
        }];
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
    
    //设置颜色渐变动画
    [self.leftMenuView startCoverViewOpacityWithAlpha:0.5 withDuration:0.35];
    
}

- (void)hideLeftMenuView{
    [self.leftMenuView cancelCoverViewOpacity];
    [UIView animateWithDuration:0.35 animations:^{
        [self.leftMenuView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(-SCREEN_WIDTH);
        }];
        
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
        
    }completion:^(BOOL finished) {
        self.leftMenuView.hidden = YES;
    }];
}

#pragma mark - XWSLeftViewDelegate
- (void)touchLeftView:(XWSLeftView *)leftView byType:(XWSTouchItem)type{
    
    [self hideLeftMenuView];
    
    UIViewController *vc = nil;
    
    switch (type) {
        case XWSTouchItemUserInfo:
        {
            
        }
            break;
        case XWSTouchItemDashboard:
        {
            
        }
            break;
        case XWSTouchItemLike:
        {
            
        }
            break;
        case XWSTouchItemFollows:
        {
            
        }
            break;
        case XWSTouchItemDownload:
        {
            
        }
            break;
        case XWSTouchItemSetupAPI:
        {
            
        }
            break;
        case XWSTouchItemLogout:
        {
            [[APIAccessHelper shareApiAccessHelper] logout];
            [self.navigationController popViewControllerAnimated:NO];
            LoginViewController *loginVC = [LoginViewController new];
            [self.navigationController pushViewController:loginVC animated:NO];
        }
            break;
            
        default:
            break;
    }
    
    if (vc == nil) {
        return;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

//- (instancetype)initWithBlog:(BTBlogInfo*)blog WithDataType:(PostsType)type
//{
//    self = [super init];
//    if (self) {
//        
//        if (blog) {
//            self.title = blog.name;
//        }else{
//            self.title = @"Dashboard";
//        }
//        self.blogInfo = blog;
//        self.type = type;
//    }
//    return self;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//    if (self.navigationController.viewControllers.count <= 2 && [self isEqual:self.navigationController.topViewController]) {
//        [self.navigationItem setHidesBackButton:TRUE animated:NO];
//    }
//    
//    self.view.backgroundColor = [UIColor blackColor];
////    self.title = @"Dashboard";
//    self.dataFailCount = 0;
//    self.postDataModel = [PostsDataModel new];
//    [self loadData:NO];
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    [self initDashboardCollectView];
//    
//}
//
////- (void)showLoading
////{
////    if (!self.loadingView) {
////        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
////        self.loadingView = loadingView;
////    }
////
////    self.loadingView.center = self.view.center;
////    self.loadingView.color = UIColor.grayColor;
////    [self.view addSubview:self.loadingView];
////    [self.loadingView startAnimating];
////}
////
////- (void)hideLoading
////{
////    [self.loadingView stopAnimating];
////    [self.loadingView removeFromSuperview];
////}
//
//- (void)loadData:(BOOL)isLoadMore
//{
//    BTWeakSelf(weakSelf);
//    
//    if (!isLoadMore) {
//        [self showLoading];
//    }
//    
//    switch (self.type) {
//        case Type_Dashboard:{
//            [self.postDataModel loadData:isLoadMore callback:^(NSArray<BTPost*> *posts, NSError * error){
//                
//                if (error) {
//                    weakSelf.dataFailCount++;
//                    NSLog(@"error info:%@",error);
//                }
//                
//                weakSelf.dataFailCount = 0;
//                [weakSelf hideLoading];
//                
//                [weakSelf updateDashboard];
//            }];
//            
//        }
//            break;
//        case Type_BlogPost:{
//            
//            [self.postDataModel loadDataFromBlog:self.blogInfo.blogId loadMore:isLoadMore callback:^(NSArray<BTPost*> *posts, NSError * error){
//                
//                if (error) {
//                    weakSelf.dataFailCount++;
//                    NSLog(@"error info:%@",error);
//                }
//                
//                weakSelf.dataFailCount = 0;
//                [weakSelf hideLoading];
//                
//                [weakSelf updateDashboard];
//            }];
//        }
//            break;
//        default:
//            break;
//    }
//    
//    
//}
//
//- (void)updateDashboard
//{
//    
//    [self.mainCollectionView reloadData];
//    [self collectionStopRefreshData];
//}
//
//- (void)collectionStopRefreshData
//{
//    self.mainCollectionView.mj_header.endRefreshingCompletionBlock = ^{
//        NSLog(@"header end refresh");
//    };
//    [self.mainCollectionView.mj_header endRefreshing];
//    
//    self.mainCollectionView.mj_footer.endRefreshingCompletionBlock = ^{
//        NSLog(@"footer end refresh");
//    };
//    
//    [self.mainCollectionView.mj_footer endRefreshing];
//}
//
//- (void)initDashboardCollectView
//{
//    if(!self.mainCollectionView){
//        BTWeakSelf(weakSelf);
//        BTCollectionViewWaterfallLayout *layout = [[BTCollectionViewWaterfallLayout alloc] init];
//        
//        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//        layout.headerHeight = 0;
//        layout.footerHeight = 0;
//        layout.minimumColumnSpacing = 5;
//        layout.minimumInteritemSpacing = 2;
//        
//        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
//            layout.columnCount = 4;
//        }else{
//            layout.columnCount = 5;
//        }
//    
//        //    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
//        layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst;
//        
//        self.mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20) collectionViewLayout:layout];
//        self.mainCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        self.mainCollectionView.dataSource = self;
//        self.mainCollectionView.delegate = self;
//        self.mainCollectionView.backgroundColor = [UIColor whiteColor];
//        [self.mainCollectionView registerClass:[BTDashboardCollectionCell class]
//                    forCellWithReuseIdentifier:CELL_IDENTIFIER];
//        [self.view addSubview:self.mainCollectionView];
//        //    [_collectionView registerClass:[CHTCollectionViewWaterfallHeader class]
//        //        forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
//        //               withReuseIdentifier:HEADER_IDENTIFIER];
//        //    [_collectionView registerClass:[CHTCollectionViewWaterfallFooter class]
//        //        forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
//        //               withReuseIdentifier:FOOTER_IDENTIFIER];
//        
//        self.mainCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            [weakSelf loadData:NO];
//        }];
//        
//        self.mainCollectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//            [weakSelf loadData:YES];
//        }];
//    }
//    
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    BTCollectionViewWaterfallLayout *layout =
//    (BTCollectionViewWaterfallLayout *)self.mainCollectionView.collectionViewLayout;
////    [self.mainCollectionView reloadData];
//    layout.columnCount = size.width > size.height ? 5 : 4;
////    [self.mainCollectionView reloadData];
////    layout.columnCount = 4;
//}
//
//#pragma mark - UICollectionViewDataSource
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return self.postDataModel.posts.count;
//}
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return 1;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    BTDashboardCollectionCell *cell =
//    (BTDashboardCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
//                                                                                forIndexPath:indexPath];
//    BTPost *post = [self.postDataModel.posts objectAtIndex:indexPath.item];
//    cell.delegate = self;
//    [cell setPost:post];
//    
//    
//    return cell;
//}
//
////- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
////{
////    BTPost *post = [self.postDataModel.posts objectAtIndex:indexPath.item];
////
////    switch (post.type) {
////        case DBVideo:
////        {
////            BTVideoPlayViewController *vc = [[BTVideoPlayViewController alloc] initWithPost:post];
////            //                BTPostGallaryViewController *vc = [[BTPostGallaryViewController alloc] initWithPost:post];
////            [self.navigationController pushViewController:vc animated:YES];
////        }
////            break;
////        case DBPhoto:{
////
////            break;
////        }
////        default:
////            break;
////    }
////}
//
//#pragma mark - CHTCollectionViewDelegateWaterfallLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    BTPost *post = [self.postDataModel.posts objectAtIndex:indexPath.item];
//    
//    //now use 100 width to show, then the height should sum all the photos/text/video's height
//    long width = 100;
//    
//    switch (post.type) {
//        case BTPhoto:
//        case BTPhotoText:
//        {
//           
//            CGFloat height = 0;
//            
//            NSInteger resIndex = 0;
//            
//            CGFloat originWidth = 0, originHeight = 0;
//            
//            for (BTImageInfo *imageInfo in post.imageInfos) {
//                if (imageInfo.imageResArr && imageInfo.imageResArr.count > 0) {
//                    resIndex = imageInfo.imageResArr.count - 2;
//                    //get the last - 1 res for list view to display
//                    BTResInfo *resInfo = [imageInfo.imageResArr objectAtIndex:resIndex];
//                    originWidth = resInfo.size.width;
//                    originHeight = resInfo.size.height;
//                } else {
//                    BTResInfo *resInfo = imageInfo.originResInfo;
//                    originWidth = resInfo.size.width;
//                    originHeight = resInfo.size.height;
//                }
//                
//                CGFloat adjustHeight = originHeight * width/originWidth;
//                
//                if (adjustHeight > SCREEN_HEIGHT) {
//                    adjustHeight = SCREEN_HEIGHT;
//                }
//                
//                height += adjustHeight;
//            }
//            
////            for (NSDictionary *imgDic in post.imgURLs) {
////                long originWidth = [(NSNumber*)[imgDic objectForKey:@"width"] longValue];
////                long originHeight = [(NSNumber*)[imgDic objectForKey:@"height"] longValue];
////
////                long adjustHeight = originHeight * width/originWidth;
////
////                if (adjustHeight > SCREEN_HEIGHT) {
////                    adjustHeight = SCREEN_HEIGHT;
////                }
////
////                height += adjustHeight;
////
////            }
//            
//            return CGSizeMake(width, height);
//        }
//            break;
//        case BTText:
//        {
//            NSDictionary *attrs = @{NSFontAttributeName :[UIFont systemFontOfSize:12]};
//            CGSize maxSize = CGSizeMake(width, MAXFLOAT);
//            
//            NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
//            
//            // 计算文字占据的宽高
//            CGSize size = [post.text boundingRectWithSize:maxSize options:options attributes:attrs context:nil].size;
//            
//            //the max height is 150
//            if (size.height > 150) {
//                size.height = 150;
//            } else {
//                size.height += 40;
//            }
//            
//            return size;
////            //now use 100 width to show, text height hardcode now to 150;
////            return CGSizeMake(width, 150);
//        }
//            break;
//        case BTVideo:{
//            CGFloat originWidth = post.videoInfo.resolutionInfo[0].size.width;
//            CGFloat originHeight = post.videoInfo.resolutionInfo[0].size.height;
//            
//            CGFloat height = originHeight * width/originWidth;
//            
//            return CGSizeMake(width, height);
//        }
//            break;
//        default:
//            break;
//    }
//    
//    return CGSizeMake(0, 0);
//}
//
//#pragma mark BTPostContentActionDelegate
//
//- (void)tapInCell:(BTDashboardCollectionCell *)cell withIndex:(NSInteger)index
//{
//    NSIndexPath *indexPath = [self.mainCollectionView indexPathForCell:cell];
//    BTPost *post = [self.postDataModel.posts objectAtIndex:indexPath.item];
//    
//    switch (post.type) {
//        case BTVideo:
//        {
//            BTVideoPlayViewController *vc = [[BTVideoPlayViewController alloc] initWithPost:post];
//            //                BTPostGallaryViewController *vc = [[BTPostGallaryViewController alloc] initWithPost:post];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
//        case BTPhoto:
//        case BTPhotoText:
//        case BTText:
//        {
//#warning todo complete the photo browser logic
//            //indexPath.item is for the image index of this post, section is for the post's index of this dashboard data.
//            NSIndexPath *photoIndexPath = [NSIndexPath indexPathForItem:index inSection:indexPath.item];
//            BTPostDetailViewController *vc = [[BTPostDetailViewController alloc] initWithPostsDataCenter:[self.postDataModel copy] atIndexPath:photoIndexPath];
//            [self.navigationController pushViewController:vc animated:YES];
//            break;
//        }
//        default:
//            break;
//    }
//}
//
//- (void)tapAvatarWithPost:(BTPost *)post
//{
//    NSLog(@"tap post avatar:%@",post);
//}
//
//#pragma mark UIScrollViewDelegate
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    BTWeakSelf(weakSelf);
//    BTCollectionViewWaterfallLayout *layout =
//    (BTCollectionViewWaterfallLayout *)self.mainCollectionView.collectionViewLayout;
//    
//    
//    CGFloat yOffset = [layout getShortestOffsetWithCount:self.postDataModel.posts.count inSection:0];
//    
//    //if data fail more than 3, then stop auto load more data. if need more data, user can do it manaully
//    if (scrollView.contentOffset.y > yOffset/3 && !self.postDataModel.isLoadingPosts && self.dataFailCount < 3) {
//        //            self performSelector:<#(nonnull SEL)#> withObject:<#(nullable id)#> afterDelay:<#(NSTimeInterval)#> inModes:<#(nonnull NSArray<NSRunLoopMode> *)#>
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf loadData:YES];
//        });
//        
//    }
//    
//    
////}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
