//
//  BTPostDetailViewController.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/10.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTPostDetailViewController.h"
#import <UIImageView+WebCache.h>
#import <UIImage+GIF.h>
#import <FLAnimatedImageView.h>
#import <FLAnimatedImageView+WebCache.h>
#import <WebKit/WebKit.h>

#import "BTURLCacheProtocol.h"
#import "BTWebview.h"
#import "APIAccessHelper.h"
#import "BTPostGallaryViewController.h"

@interface BTPostDetailViewController () <UIScrollViewDelegate, WKNavigationDelegate>

@property (nonatomic, strong) BTPost *post;
@property (nonatomic, strong) PostsDataModel *postDataModel;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) UIScrollView *scrollView;
//@property (nonatomic, strong) NSMutableArray *imageViewsArr;

/**
  Two-dimensional array. the first dimensional for post, the second for post images position
 */
@property (nonatomic, strong) NSMutableArray *imagePositionsArr;
@property (nonatomic, strong) UIView *controlView;
//@property (nonatomic, strong) BTWebview *webview;

@end

@implementation BTPostDetailViewController

- (instancetype)initWithPostsDataCenter:(PostsDataModel *)dataModel atIndexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    if (self) {
        self.postDataModel = dataModel;
        self.currentIndexPath = indexPath;
    }
    return self;
}

- (instancetype)initWithPost:(BTPost*)post
{
    self = [super init];
    if (self) {
        self.post = post;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    //    self.navigationController.navigationBar.hidden = YES;
    
//    self.imagePositionsArr = [[NSMutableArray alloc] initWithCapacity:self.postDataModel.posts.count];
    self.imagePositionsArr = [NSMutableArray new];
    
    [self setupScrollView];
    //    [self setupImageViews];
    [self setupContentView];
    [self initControlBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)initControlBar
{
    CGFloat viewHeight = 40;// * ADJUST_VIEW_RADIO;
    
    BTWeakSelf(weakSelf);
    UIView *view = [[UIView alloc] init];
    [self.view addSubview:view];
    self.controlView = view;
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakSelf.view);
        make.height.mas_equalTo(viewHeight + WINDOW_SAFE_AREA_INSETS.bottom);
    }];
    
    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [forwardBtn setTitle:@"forward" forState:UIControlStateNormal];
    [forwardBtn setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(forward:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:forwardBtn];
    
    [forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).with.offset(-20);
        make.height.width.mas_equalTo(30);
    }];
}

- (IBAction)forward:(id)sender
{
    NSLog(@"forward button add");
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    [[APIAccessHelper shareApiAccessHelper] forwardPost:post];
}

- (void)setupContentView
{
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    self.title = post.title;
    
    switch (post.type) {
        case BTPhoto:
        {
            [self setupImageViews];
            break;
        }
        case BTPhotoText:
        case BTText:
        {
            [self setupWebview];
            break;
        }
        default:
            break;
    }
}

- (void)setupWebview
{
    BTWeakSelf(weakSelf);
    [NSURLProtocol registerClass:[BTURLCacheProtocol class]];
    
    [BTWebview registerScheme:@"http"];
    [BTWebview registerScheme:@"https"];
    
    BTWebview *webview = [[BTWebview alloc] init];
    webview.navigationDelegate = self;
    
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    
    NSRange quoteRange = [post.contentBody rangeOfString:@"<blockquote>"];
    
    NSString *bodyString = nil;
    if (quoteRange.location != NSNotFound) {
         bodyString = [post.contentBody substringFromIndex:[post.contentBody rangeOfString:@"<blockquote>"].location];
    }else{
        bodyString = post.contentBody;
    }
    
    
    NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"htmlHeader" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    htmlString = [htmlString stringByAppendingString:bodyString];
    
    [webview loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    
    [self.view addSubview:webview];
    
    [webview mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.bottom.right.equalTo(weakSelf.view);
    }];
}

//- (void)setupControlView
//{
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    backBtn.frame = CGRectMake(10, 30, 50, 40);
//    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
//
//    [self.view addSubview:backBtn];
//}
//
//- (void)backClick
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)setupImageViews
{
    
#warning todo load horizontal post list, now just load one post vertical image list
    [self setupPostImageList];
}

- (void)setupPostImageList
{
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    
    NSMutableArray *imgPositions = [NSMutableArray new];
    
    NSInteger y = 0;
    for (int i = 0; i < post.imageInfos.count; i++) {
        
        BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
        BTImageInfo *imageInfo = [post.imageInfos objectAtIndex:i];
        
        NSURL *imgURL = nil;
        BTResInfo *resInfo = nil;
        if (imageInfo.originResInfo.resUrl) {
            resInfo = imageInfo.originResInfo;
            imgURL = resInfo.resUrl;
        }else{
            resInfo = [imageInfo.imageResArr objectAtIndex:0];
            imgURL = resInfo.resUrl;
        }
        
        CGFloat imgHeight = SCREEN_WIDTH/resInfo.size.width * resInfo.size.height;
        
        [imgPositions addObject:@(y)];
        
        CGRect frame = CGRectMake(0 , y , SCREEN_WIDTH, imgHeight);
        
        FLAnimatedImageView *imgView = [[FLAnimatedImageView alloc] initWithFrame:frame];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.userInteractionEnabled = YES;
        imgView.tag = i;
        [imgView sd_setImageWithURL:imgURL];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes addTarget:self action:@selector(tapImage:)];
        [imgView addGestureRecognizer:tapGes];
        
        y += imgHeight;
        
        [self.scrollView addSubview:imgView];
        
    }
    
    [self.imagePositionsArr addObject:imgPositions];
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, y);
    
    [self scrollToPageIndex:self.currentIndexPath.item];
}

- (void)tapImage:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        NSInteger item = [(UITapGestureRecognizer*)sender view].tag;
        
        NSIndexPath *photoIndexPath = [NSIndexPath indexPathForItem:item inSection:self.currentIndexPath.section];
        BTPostGallaryViewController *vc = [[BTPostGallaryViewController alloc] initWithPostsDataCenter:self.postDataModel atIndexPath:photoIndexPath];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if([sender isKindOfClass:[NSNumber class]]){
        NSInteger item = [(NSNumber*)sender integerValue];
        
        NSIndexPath *photoIndexPath = [NSIndexPath indexPathForItem:item inSection:self.currentIndexPath.section];
        BTPostGallaryViewController *vc = [[BTPostGallaryViewController alloc] initWithPostsDataCenter:self.postDataModel atIndexPath:photoIndexPath];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//- (void)loadImageAtIndexPath:(NSIndexPath*)indexPath withImageViewArr:(NSArray*)imageViewArr
//{
//    if (indexPath.item < 0 || indexPath.item >= imageViewArr.count) {
//        return;
//    }
//
//    BTPost *post = [self.postDataModel.posts objectAtIndex:indexPath.section];
//    BTImageInfo *imageInfo = [post.imageInfos objectAtIndex:indexPath.item];
//
//    NSURL *imgURL = nil;
//    if (imageInfo.originResInfo.resUrl) {
//        BTResInfo *resInfo = imageInfo.originResInfo;
//        imgURL = resInfo.resUrl;
//    }else{
//        BTResInfo *resInfo = [imageInfo.imageResArr objectAtIndex:0];
//        imgURL = resInfo.resUrl;
//    }
//
//    FLAnimatedImageView *imgView = [imageViewArr objectAtIndex:indexPath.item];
//
//    [imgView sd_setImageWithURL:imgURL];
//}

- (void)setupScrollView
{
    BTWeakSelf(weakSelf);
//    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView = [[UIScrollView alloc] init];
    //    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.delegate = self;
//        if (@available(iOS 11.0, *)) {
//            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        } else {
//            // Fallback on earlier versions
//        }
    
    [self.view addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.left.bottom.right.equalTo(weakSelf.view);
    }];
}

- (void)scrollToPageIndex:(NSInteger)index
{
//    CGFloat pageWidth = self.scrollView.frame.size.width;
//    CGPoint position = CGPointMake(index * pageWidth, 0);
//    [self.scrollView setContentOffset:position animated:YES];
    
    NSNumber *yNum = self.imagePositionsArr[0][index];
    CGPoint position = CGPointMake(0, yNum.doubleValue);
    [self.scrollView setContentOffset:position animated:NO];
}

- (void)dealloc
{
    [NSURLProtocol unregisterClass:[BTURLCacheProtocol class]];
    [BTWebview unregisterScheme:@"http"];
    [BTWebview unregisterScheme:@"https"];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSInteger index = (scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width;
    //    NSLog(@"%ld",(long)index);
    //
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:self.currentIndexPath.section];
    //
    //    if (index != self.currentIndexPath.item) {
    //        self.currentIndexPath = [NSIndexPath indexPathForItem:index inSection:self.currentIndexPath.section];
    //        BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    //        self.title = post.title;
    //    }
    //
    //    [self loadImageAtIndexPath:indexPath withImageViewArr:self.imageViewsArr];
    
    
    NSInteger section = (scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width;
    NSLog(@"%ld",(long)section);
    
    if (section != self.currentIndexPath.section) {
        
        BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
        self.title = post.title;
        
#warning todo calculate current item and section to set currentIndexPath
//        NSInteger *item = 0;
//        
//        self.currentIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        
    }
    
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSString *jsFormat = @"var offset = document.getElementsByTagName(\"img\")[%ld].offsetTop;document.getElementsByTagName(\"body\")[0].scrollTop = offset;";
    NSString *js = [NSString stringWithFormat:jsFormat,self.currentIndexPath.item];
    
    [webView evaluateJavaScript:js completionHandler:^(id value, NSError *error){
        if (error) {
            NSLog(@"js error:%@",error);
        }
        
        NSLog(@"value:%@",value);
    }];
}

//- (void)addObserverForPlayer
//{
//    [self addObserver:self.playerController.player.currentItem forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self.playerController.player.currentItem forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//}
//
//- (void)removeObserverForPlayer
//{
//    [self removeObserver:self.playerController forKeyPath:@"status"];
//    [self removeObserver:self.playerController forKeyPath:@"loadedTimeRanges"];
//}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [self removeObserverForPlayer];
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"status"]) {
//        if ([(AVPlayerItem*)object status] == AVPlayerStatusReadyToPlay) {
//            [self.playerController.player play];
//        }
//    }
//}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

