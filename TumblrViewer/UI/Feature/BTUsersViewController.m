//
//  BTUsersViewController.m
//  TumblrViewer
//
//  Created by Daniel on 2019/7/14.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTUsersViewController.h"
#import "UserDateCenter.h"
#import "BTBlogInfoCollectionCell.h"
#import "BTPostListViewController.h"

#import <MJRefresh.h>
#import <UIImageView+WebCache.h>

//#define CELL_IDENTIFIER @"blogInfoCell"

@interface BTUsersViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) UserDateCenter *userDataCenter;

@end

@implementation BTUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"follows", nil);
    
    [self initView];
    
    [self loadAllUser];
}

- (void)initView
{
    if(!self.mainCollectionView){
        BTWeakSelf(weakSelf);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
       
        self.mainCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        self.mainCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.mainCollectionView.dataSource = self;
        self.mainCollectionView.delegate = self;
        self.mainCollectionView.backgroundColor = [UIColor whiteColor];
        [self.mainCollectionView registerClass:[BTBlogInfoCollectionCell class]
                    forCellWithReuseIdentifier:BLOG_CELL_IDENTIFIER];
        [self.view addSubview:self.mainCollectionView];
        //    [_collectionView registerClass:[CHTCollectionViewWaterfallHeader class]
        //        forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
        //               withReuseIdentifier:HEADER_IDENTIFIER];
        //    [_collectionView registerClass:[CHTCollectionViewWaterfallFooter class]
        //        forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
        //               withReuseIdentifier:FOOTER_IDENTIFIER];
        
        [self.mainCollectionView mas_makeConstraints:^(MASConstraintMaker *maker){
            maker.top.left.bottom.right.equalTo(weakSelf.view);
        }];
        
        self.mainCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf loadData:NO];
        }];
        
        self.mainCollectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf loadData:YES];
        }];
    }
}

- (void)loadAllUser
{
    BTWeakSelf(weakSelf);
    
    self.userDataCenter = [UserDateCenter new];
    
    [self loadData:NO];
    
    //auto load all the user data.
//    dispatch_queue_t loadQueue = dispatch_queue_create("load_blog_queue", nil);
//    dispatch_async(loadQueue, ^{
//        while (![weakSelf.userDataCenter isNoMoreData])
//        {
//            if (weakSelf.userDataCenter.isLoading) {
//                [NSThread sleepForTimeInterval:1];
//            }
//            [weakSelf loadData:YES];
//
//        }
//
//    });
}

- (void)loadData:(BOOL)isLoadMore
{
    BTWeakSelf(weakSelf);
    
    if (!isLoadMore) {
        [self showLoading];
    }
    
    if (![self.mainCollectionView.mj_header isRefreshing] && !isLoadMore) {
        [self.mainCollectionView.mj_header beginRefreshing];
    }else if (![self.mainCollectionView.mj_footer isRefreshing] && isLoadMore) {
        [self.mainCollectionView.mj_footer beginRefreshing];
    }
    
    UserDataCallback dataCallback = ^(NSArray<BTBlogInfo*> *posts, NSError * error, DataStatus status){
        if (error) {
            NSLog(@"error info:%@",error);
        }
        
        if (status == Data_Status_End) {
            //load all data
            [weakSelf collectionStopRefreshData];
//            self.mainCollectionView.mj_footer.state = MJRefreshStateNoMoreData;
            [self.mainCollectionView.mj_footer endRefreshingWithNoMoreData];
            weakSelf.mainCollectionView.mj_footer.hidden = YES;
        }
        
        if (!isLoadMore || Data_Status_End) {
            [weakSelf hideLoading];
            
            [weakSelf updateUserData];
        }
    };
    
    [self.userDataCenter loadData:isLoadMore callback:dataCallback];
}

- (void)updateUserData
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

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.userDataCenter.users.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BTBlogInfoCollectionCell *cell =
    (BTBlogInfoCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:BLOG_CELL_IDENTIFIER
                                                                      forIndexPath:indexPath];
    BTBlogInfo *blogInfo = [self.userDataCenter.users objectAtIndex:indexPath.item];
    cell.name = blogInfo.name;
    
    UIImageView *avatarView = [[UIImageView alloc] init];
    avatarView.contentMode = UIViewContentModeScaleAspectFill;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:blogInfo.avatarPath]];
    cell.imageView = avatarView;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return [BTBlogInfoCollectionCell cellSize];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BTBlogInfo *blogInfo = [self.userDataCenter.users objectAtIndex:indexPath.item];
    
    BTPostListViewController *vc = [[BTPostListViewController alloc] initWithBlog:blogInfo WithDataType:Type_BlogPost];
    [self.navigationController pushViewController:vc animated:YES];
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
