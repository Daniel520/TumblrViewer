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
#import "HTMLParser.h"
#import <MJRefresh.h>

#import <CHTCollectionViewWaterfallLayout.h>
//#import "LJJWaterFlowLayout.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>

@interface BTRootViewController () <UICollectionViewDataSource,CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic,strong) UICollectionView *mainCollectionView;
//@property (nonatomic,strong) NSDictionary *dashboardDic;
@property (nonatomic,strong) NSArray *dashboardImgArr;

//test
@property (nonatomic,strong) UIButton *authButton;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UIImageView *testImageView;

@end

@implementation BTRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadData:NO];
//    [self testLoadImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    if ([[APIAccessHelper shareApiAccessHelper] isNeedLogin]) {
//        [self setUpAuthenticateButton];
//        return;
//    }
}

//- (IBAction)authenticate
//{
//    BTWeakSelf(weakSelf);
//    [[APIAccessHelper shareApiAccessHelper] authenticate:^(NSError *error){
//        if (error) {
//            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Login Fail" message:@"Login fail,you may check your network and try again" preferredStyle:UIAlertControllerStyleActionSheet];
//
//            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
//
//            [actionSheet addAction:action1];
//
//            //相当于之前的[actionSheet show];
//            [weakSelf presentViewController:actionSheet animated:YES completion:nil];
//        }else{
//
//            weakSelf.authButton.hidden = YES;
//
//            [weakSelf loadData];
//        }
//
//    }];
//}

//- (void)testLoadImage
//{
//    NSURL *url = [NSURL URLWithString:@"https://66.media.tumblr.com/a600361897ce9f5140620de9ed225e3f/tumblr_ov9nr4tXKh1ut081ko1_640.jpg"];
//    self.testImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 320, 480)];
//    self.testImageView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
//    [self.view addSubview:self.testImageView];
//    [self.testImageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
//        if (error) {
//            NSLog(@"load error:%@",error);
//        }else{
//            NSLog(@"load success:%@",imageURL);
//        }
//
//    }];
//}

- (void)loadData:(BOOL)isLoadMore
{
    BTWeakSelf(weakSelf);
    
    //test
//    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 100, SCREEN_WIDTH-40, SCREEN_HEIGHT - 150)];
//    [self.view addSubview:self.textView];
    //test
    
    TMAPIClient *apiClient = [[APIAccessHelper shareApiAccessHelper] generateApiClient];
    
    NSURLSessionTask *task = nil;
    
    NSInteger offset = 0;
    
    if (isLoadMore) {
        
        offset = self.dashboardImgArr.count;
    } else {
        // clear data to refresh
        self.dashboardImgArr = [NSArray new];
    }
    
    task = [apiClient dashboardRequest:@{@"limit":@20,@"offset":@(offset)} callback:^( id _Nullable response, NSError * _Nullable error){

        if (error) {
            NSLog(@"error info:%@",error);
        }
//        NSLog(@"%@",response);
//        weakSelf.textView.text = [response description];

//        weakSelf.dashboardDic = response;
        //to get the img data and set to self.dashboardImgArr
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
    NSArray *posts = [response objectForKey:@"posts"];
    
    NSMutableArray *postsURLs = [NSMutableArray new];
    
    for (NSDictionary *postDic in posts) {
        NSString *type = [postDic objectForKey:@"type"];
        if ([type isEqualToString:@"text"]) {
            NSString *body = [postDic objectForKey:@"body"];
            NSArray *imgURLs = [self getImageURLsFromPostBody:body];
            [postsURLs addObject:imgURLs];
        } else if ([type isEqualToString:@"photo"]) {
            
            NSArray *postImages = [postDic objectForKey:@"photos"];
            
            NSArray *imgURLs = [self getImageURLsFromPhotos:postImages];
            
            [postsURLs addObject:imgURLs];
        }
    }
    
    self.dashboardImgArr = [self.dashboardImgArr arrayByAddingObjectsFromArray:postsURLs];
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
    
    return [imgURLs copy];
}

- (NSArray*)getImageURLsFromPostBody:(NSString*)body
{
    NSError *error = nil;
    NSMutableArray *imgURLs = [NSMutableArray new];
    
    HTMLParser *parser = [[HTMLParser alloc] initWithString:body error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *imgNodes = [bodyNode findChildTags:@"img"];
    
    if (imgNodes.count > 0) {
        
        for (HTMLNode *imgNode in imgNodes) {
//            NSString *imgURL = [imgNode getAttributeNamed:@"src"];
//            long imgHeight  = [[imgNode getAttributeNamed:@"data-orig-height"] longLongValue];
//            long imgWidth   = [[imgNode getAttributeNamed:@"data-orig-width"] longLongValue];
//
//            NSDictionary *imgDic = @{@"url":imgURL,@"width":[NSNumber numberWithLong:imgWidth],@"height":[NSNumber numberWithLong:imgHeight]};
            
            NSDictionary *imgDic = [self translateImgDicByHTMLNode:imgNode];
            [imgURLs addObject:imgDic];
        }
        
    } else if (imgNodes.count == 0) {
        
        NSArray *imageNodes = [bodyNode findChildTags:@"image"];
        
        for (HTMLNode *imgNode in imageNodes) {
//            NSString *imgURL = [imgNode getAttributeNamed:@"src"];
//            long imgHeight  = [[imgNode getAttributeNamed:@"data-orig-height"] longLongValue];
//            long imgWidth   = [[imgNode getAttributeNamed:@"data-orig-width"] longLongValue];
//
//            NSDictionary *imgDic = @{@"url":imgURL,@"width":[NSNumber numberWithLong:imgWidth],@"height":[NSNumber numberWithLong:imgHeight]};

            NSDictionary *imgDic = [self translateImgDicByHTMLNode:imgNode];
            [imgURLs addObject:imgDic];
        }
        
    }
    
    return [imgURLs copy];
}

- (NSDictionary *)translateImgDicByHTMLNode:(HTMLNode*)htmlNode
{
    NSString *imgURL = [htmlNode getAttributeNamed:@"src"];
    long imgHeight  = [[htmlNode getAttributeNamed:@"data-orig-height"] longLongValue];
    long imgWidth   = [[htmlNode getAttributeNamed:@"data-orig-width"] longLongValue];
    
    //translate the size to 100 to show in dashboard
    imgHeight = 100 * imgHeight/imgWidth;
    imgWidth = 100;
    
    NSDictionary *imgDic = @{@"url":imgURL,@"width":[NSNumber numberWithLong:imgWidth],@"height":[NSNumber numberWithLong:imgHeight]};
    return imgDic;
}
    

- (void)updateDashboard
{
    if (!self.mainCollectionView) {
        [self initDashboardCollectView];
    }
    
    
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
    layout.itemRenderDirection = CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
    
    self.mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20) collectionViewLayout:layout];
    self.mainCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mainCollectionView.dataSource = self;
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.backgroundColor = [UIColor whiteColor];
//    [self.mainCollectionView registerClass:[BTDashboardCollectionCell class]
//            forCellWithReuseIdentifier:CELL_IDENTIFIER];
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
#warning todo
    return self.dashboardImgArr.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    BTDashboardCollectionCell *cell =
//    (BTDashboardCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
//                                                                                forIndexPath:indexPath];

    [self.mainCollectionView registerClass:[BTDashboardCollectionCell class]
                forCellWithReuseIdentifier:[NSString stringWithFormat:@"cell-%ld-%ld",(long)indexPath.section,(long)indexPath.item]];

    BTDashboardCollectionCell *cell =
    (BTDashboardCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"cell-%ld-%ld",(long)indexPath.section,(long)indexPath.item]
                                                                           forIndexPath:indexPath];
#warning todo
    cell.imgDicArr = [self.dashboardImgArr objectAtIndex:indexPath.item];
    return cell;
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
#warning todo
    NSArray *imgDics = [self.dashboardImgArr objectAtIndex:indexPath.item];
    
   
    
    //now use 100 width to show, then the height should sum all the photos' height
    long width = 100;
    long height = 0;
    
    for (NSDictionary *imgDic in imgDics) {
        long originWidth = [(NSNumber*)[imgDic objectForKey:@"width"] longValue];
        long originHeight = [(NSNumber*)[imgDic objectForKey:@"height"] longValue];
        
        long adjustHeight = originHeight * width/originWidth;
        
        if (adjustHeight > SCREEN_HEIGHT) {
            adjustHeight = SCREEN_HEIGHT;
        }
        
        height += adjustHeight;
        
    }
    
    return CGSizeMake(width, height);
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
