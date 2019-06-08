//
//  BTPostGallaryViewController.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/5/11.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTPostGallaryViewController.h"
#import <UIImageView+WebCache.h>
#import <UIImage+GIF.h>
#import <FLAnimatedImageView.h>
#import <FLAnimatedImageView+WebCache.h>
#import <WebKit/WebKit.h>

#import "BTURLCacheProtocol.h"
#import "BTWebview.h"

@interface BTPostGallaryViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) BTPost *post;
@property (nonatomic, strong) PostsDataModel *postDataModel;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imageViewsArr;

@end

@implementation BTPostGallaryViewController

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
    self.view.backgroundColor = [UIColor blackColor];
//    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupScrollView];
//    [self setupImageViews];
    [self setupContentView];
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
    [NSURLProtocol registerClass:[BTURLCacheProtocol class]];
    
    [BTWebview registerScheme:@"http"];
    [BTWebview registerScheme:@"https"];
    
    BTWebview *webview = [[BTWebview alloc] initWithFrame:self.view.bounds];
    
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    
    NSString *bodyString = [post.contentBody substringFromIndex:[post.contentBody rangeOfString:@"<blockquote>"].location];
    
    
    NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"htmlHeader" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
//    NSString *htmlString = @"<meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no,minimal-ui\"><meta name=\"apple-mobile-web-app-capable\" content=\"yes\"/>";
    htmlString = [htmlString stringByAppendingString:bodyString];
    
    [webview loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    [self.view addSubview:webview];
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
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    NSMutableArray *imageViewArr = [NSMutableArray new];
    
    for (int i = 0; i < post.imageInfos.count; i++) {
        CGRect frame = CGRectMake(i * CGRectGetWidth(self.scrollView.bounds), self.scrollView.bounds.origin.y, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
        FLAnimatedImageView *imgView = [[FLAnimatedImageView alloc] initWithFrame:frame];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.scrollView addSubview:imgView];
        
        [imageViewArr addObject:imgView];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.subviews.count * CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
    self.imageViewsArr = imageViewArr;

    
    [self loadImageAtIndexPath:self.currentIndexPath withImageViewArr:imageViewArr];
    
    NSIndexPath *preIndexPath = [NSIndexPath indexPathForItem:self.currentIndexPath.item - 1 inSection:self.currentIndexPath.section];
    [self loadImageAtIndexPath:preIndexPath withImageViewArr:imageViewArr];
    
    NSIndexPath *afterIndexPath = [NSIndexPath indexPathForItem:self.currentIndexPath.item + 1 inSection:self.currentIndexPath.section];
    [self loadImageAtIndexPath:afterIndexPath withImageViewArr:imageViewArr];
    
    [self scrollToPageIndex:self.currentIndexPath.item];
}

- (void)loadImageAtIndexPath:(NSIndexPath*)indexPath withImageViewArr:(NSArray*)imageViewArr
{
    if (indexPath.item < 0 || indexPath.item >= imageViewArr.count) {
        return;
    }
    
    BTPost *post = [self.postDataModel.posts objectAtIndex:indexPath.section];
    BTImageInfo *imageInfo = [post.imageInfos objectAtIndex:indexPath.item];
    
    NSURL *imgURL = nil;
    if (imageInfo.originResInfo.resUrl) {
        BTResInfo *resInfo = imageInfo.originResInfo;
        imgURL = resInfo.resUrl;
    }else{
        BTResInfo *resInfo = [imageInfo.imageResArr objectAtIndex:0];
        imgURL = resInfo.resUrl;
    }
    
    FLAnimatedImageView *imgView = [imageViewArr objectAtIndex:indexPath.item];
    
    [imgView sd_setImageWithURL:imgURL];
}

- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    
    [self.view addSubview:self.scrollView];
}

- (void)scrollToPageIndex:(NSInteger)index
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGPoint position = CGPointMake(index * pageWidth, 0);
    [self.scrollView setContentOffset:position animated:YES];
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
    NSInteger index = (scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width;
    NSLog(@"%ld",(long)index);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:self.currentIndexPath.section];
    
    if (index != self.currentIndexPath.item) {
        self.currentIndexPath = [NSIndexPath indexPathForItem:index inSection:self.currentIndexPath.section];
        BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
        self.title = post.title;
    }
    
    
    [self loadImageAtIndexPath:indexPath withImageViewArr:self.imageViewsArr];
//    _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", index + 1, self.imageCount];
    //预加载 前3张 后3张
//    NSInteger left = index - 3;
//    NSInteger right = index + 3;
//    left = left>0?left : 0;
//    right = right>self.imageCount?self.imageCount:right;
    
//    for (NSInteger i = left; i < right; i++) {
//        [self setupImageOfImageViewForIndex:i];
//    }
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
