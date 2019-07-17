//
//  BTPostGallaryViewController.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/5/11.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTPostGallaryViewController.h"
#import "BTPostListViewController.h"

#import <UIImageView+WebCache.h>
#import <UIImage+GIF.h>
#import <FLAnimatedImageView.h>
#import <FLAnimatedImageView+WebCache.h>
#import <UIButton+WebCache.h>
#import <WebKit/WebKit.h>

#import "BTURLCacheProtocol.h"
#import "BTWebview.h"
#import "APIAccessHelper.h"
#import "BTBottomControlBar.h"

@interface BTPostGallaryViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) BTPost *post;
@property (nonatomic, strong) PostsDataModel *postDataModel;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imageViewsArr;
@property (nonatomic, strong) UIView *controlBar;

//@property (nonatomic, strong) UIButton *avatarBtn;
//@property (nonatomic, strong) UIButton *blogNameBtn;

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
    [self initControlBar];
}

//- (void)initControlBar
//{
//    CGFloat viewHeight = 40;// * ADJUST_VIEW_RADIO;
//    
//    BTWeakSelf(weakSelf);
//    UIView *view = [[UIView alloc] init];
//    [self.view addSubview:view];
//    self.controlView = view;
//    
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(weakSelf.view);
//        make.height.mas_equalTo(viewHeight + WINDOW_SAFE_AREA_INSETS.bottom);
//    }];
//    
//    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
////    [forwardBtn setTitle:@"forward" forState:UIControlStateNormal];
//    [forwardBtn setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
//    [forwardBtn addTarget:self action:@selector(forward:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:forwardBtn];
//    
//    [forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(view).with.offset(-20);
//        make.height.width.mas_equalTo(30);
//    }];
//}
//
//- (IBAction)forward:(id)sender
//{
//    NSLog(@"forward button add");
//    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
//    [[APIAccessHelper shareApiAccessHelper] forwardPost:post];
//}

- (void)setupContentView
{
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    self.title = post.title;
    [self setupImageViews];
    
//    switch (post.type) {
//        case BTPhoto:
//            {
//                [self setupImageViews];
//                break;
//            }
//        case BTPhotoText:
//        case BTText:
//        {
//            [self setupWebview];
//            break;
//        }
//        default:
//            break;
//    }
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
    NSRange bodyRange = [htmlString rangeOfString:@"<body>"];
    if (bodyRange.location != NSNotFound) {
        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:htmlString];
        [mutableString insertString:bodyString atIndex:bodyRange.location + bodyRange.length];
        htmlString = [mutableString copy];
    }else{
        
        //    NSString *htmlString = @"<meta name=\"viewport\" content=\"width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no,minimal-ui\"><meta name=\"apple-mobile-web-app-capable\" content=\"yes\"/>";
        htmlString = [htmlString stringByAppendingString:bodyString];
    }
    
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
    
    UIImage *placeholderImage = nil;
    if (imageInfo.imageResArr.count > 0) {
        NSInteger placeholderIndex = imageInfo.imageResArr.count - 2;
        if (placeholderIndex > 0) {
            NSURL *placeholderURL = [imageInfo.imageResArr objectAtIndex:placeholderIndex].resUrl;
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            NSString* key = [manager cacheKeyForURL:placeholderURL];
            SDImageCache* cache = [SDImageCache sharedImageCache];
            placeholderImage = [cache imageFromDiskCacheForKey:key];
        }
    }
    
    BTResInfo *resInfo;
    if (imageInfo.originResInfo.resUrl) {
        resInfo = imageInfo.originResInfo;
        imgURL = resInfo.resUrl;
        
    }else{
        resInfo = [imageInfo.imageResArr objectAtIndex:0];
        imgURL = resInfo.resUrl;
        
        // it should be a bug for tumblr, for gif the max size photo of gif just have one frame, but the last 3 is ok
        NSInteger index = imageInfo.imageResArr.count - 2;
        if ([imgURL.pathExtension.lowercaseString isEqualToString:@"gif"] && index >= 0) {
            
            resInfo = [imageInfo.imageResArr objectAtIndex:index];
            imgURL = resInfo.resUrl;
        }
    }
    
    FLAnimatedImageView *imgView = [imageViewArr objectAtIndex:indexPath.item];
    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
//    doubleTap.numberOfTapsRequired = 2;
//    [imgView addGestureRecognizer:doubleTap];
    
    [imgView sd_setImageWithURL:imgURL placeholderImage:placeholderImage];
}

//- (void)didDoubleTap:(UITapGestureRecognizer *)tap {
//    CGPoint point = [tap locationInView:tap.view];
//    if (!CGRectContainsPoint(tap.view.bounds, point)) {
//        return;
//    }
//    [self.scrollView handleDoubleTap:point];
//}

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

- (void)initControlBar
{
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    BTBottomControlBar *controlBar = [BTBottomControlBar getControlBar:self.view withPost:post navigationController:self.navigationController];
    self.controlBar = controlBar;
}

//#pragma mark Control Bar Logic
//
//- (void)initControlBar
//{
//    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
//
//    //    CGFloat viewHeight = 60;// * ADJUST_VIEW_RADIO;
//
//    BTWeakSelf(weakSelf);
//    UIView *view = [[UIView alloc] init];
//    [self.view addSubview:view];
//    self.controlView = view;
//
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(weakSelf.view);
//        //        make.height.mas_equalTo(viewHeight + WINDOW_SAFE_AREA_INSETS.bottom);
//        make.height.mas_equalTo(CONTROL_BAR_HEIGHT);
//    }];
//
//    //Backgtound
//    UIImageView *backgroundView = [[UIImageView alloc] init];
//    backgroundView.image = [[UIImage imageNamed:@"bg_control_down"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
//    [self.controlView addSubview:backgroundView];
//
//    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.bottom.right.top.equalTo(weakSelf.controlView);
//    }];
//
//    //Control Button
//
//    //Download
//    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [downloadBtn setImage:[UIImage imageNamed:@"download-1"] forState:UIControlStateNormal];
//    [downloadBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:downloadBtn];
//
//    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(view).with.offset(-20);
//        make.top.equalTo(view).with.offset(20);
//        make.height.width.mas_equalTo(30);
//    }];
//
//    //Forward
//    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [forwardBtn setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
//    [forwardBtn addTarget:self action:@selector(forward:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:forwardBtn];
//
//    [forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(downloadBtn.mas_left).with.offset(-10);
//        make.top.equalTo(view).with.offset(20);
//        make.height.width.mas_equalTo(30);
//    }];
//
//    //Like
//    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [likeBtn setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
//    [likeBtn addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:likeBtn];
//
//    [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(forwardBtn.mas_left).with.offset(-10);
//        make.top.equalTo(view).with.offset(20);
//        make.height.width.mas_equalTo(30);
//    }];
//
//    //Link
//    UIButton *linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [linkBtn setImage:[UIImage imageNamed:@"link"] forState:UIControlStateNormal];
//    [linkBtn addTarget:self action:@selector(link:) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:linkBtn];
//
//    [linkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(likeBtn.mas_left).with.offset(-10);
//        make.top.equalTo(view).with.offset(20);
//        make.height.width.mas_equalTo(30);
//    }];
//
//    //Title & Avatar
//    [self setupAvatar:post];
//
//}
//
//- (void)setupAvatar:(BTPost*)post
//{
//    BTWeakSelf(weakSelf);
//    if (!self.avatarBtn && self.controlView) {
//        self.avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.avatarBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
//
//        [self.controlView addSubview:self.avatarBtn];
//        [self.avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(weakSelf.controlView).with.offset(20);
//            make.top.equalTo(weakSelf.controlView).with.offset(20);
//            make.height.width.mas_equalTo(30);
//        }];
//
//        self.blogNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.blogNameBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.blogNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [self.controlView addSubview:self.blogNameBtn];
//        [self.blogNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(weakSelf.avatarBtn.mas_right).with.offset(5);
//            make.top.equalTo(weakSelf.controlView).with.offset(20);
//            make.height.mas_equalTo(30);
//            make.width.mas_lessThanOrEqualTo(150);
//        }];
//    }
//
//#warning todo set image placeholder
//    [self.avatarBtn sd_setImageWithURL:[NSURL URLWithString:post.blogInfo.avatarPath] forState:UIControlStateNormal];
//    [self.avatarBtn.layer setValue:post forKey:@"post"];
//
//
//    [self.blogNameBtn setTitle:post.blogInfo.name forState:UIControlStateNormal];
//
//
//
//}
//
//- (void)avatarClick:(UIButton*)btn
//{
//    BTPost *post = [self.avatarBtn.layer valueForKey:@"post"];
//    //    BTRootViewController *vc = [[BTRootViewController alloc] initWithBlog:post.blogInfo WithDataType:Type_BlogPost];
//    BTPostListViewController *vc = [[BTPostListViewController alloc] initWithBlog:post.blogInfo WithDataType:Type_BlogPost];
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (IBAction)download:(id)sender
//{
//
//}
//
//- (IBAction)forward:(id)sender
//{
//    NSLog(@"forward button add");
//    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
//    [[APIAccessHelper shareApiAccessHelper] forwardPost:post];
//}
//
//- (IBAction)like:(id)sender
//{
//
//}
//
//- (IBAction)link:(id)sender
//{
//
//}

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
