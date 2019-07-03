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
#import <UIButton+WebCache.h>

#import "BTURLCacheProtocol.h"
#import "BTWebview.h"
#import "APIAccessHelper.h"
#import "BTPostGallaryViewController.h"
//#import "BTRootViewController.h"
#import "BTPostListViewController.h"

@interface BTPostDetailViewController () <UIScrollViewDelegate, WKNavigationDelegate, WKScriptMessageHandler>

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
@property (nonatomic, strong) UIButton *avatarBtn;
@property (nonatomic, strong) UIButton *blogNameBtn;
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
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    
    [userContentController addScriptMessageHandler:self name:@"ClickImage"];
//    [userContentController addScriptMessageHandler:self name:@"Camera"];
    configuration.userContentController = userContentController;
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
//    preferences.minimumFontSize = 40.0;
    configuration.preferences = preferences;
    
    
    [BTWebview registerScheme:@"http"];
    [BTWebview registerScheme:@"https"];
    
    BTWebview *webview = [[BTWebview alloc] initWithFrame:CGRectZero configuration:configuration];
    webview.navigationDelegate = self;
    
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    
    NSRange quoteRange = [post.contentBody rangeOfString:@"<blockquote>"];
    
    NSString *bodyString = nil;
    if (quoteRange.location != NSNotFound) {
         bodyString = [post.contentBody substringFromIndex:[post.contentBody rangeOfString:@"<blockquote>"].location];
    }else{
        bodyString = post.contentBody;
    }
    
    NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"htmlHeader" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    
    NSRange bodyRange = [htmlString rangeOfString:@"<body>"];
    if (bodyRange.location != NSNotFound) {
        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:htmlString];
        [mutableString insertString:bodyString atIndex:bodyRange.location + bodyRange.length];
        htmlString = [mutableString copy];
    }else{
        
        htmlString = [htmlString stringByAppendingString:bodyString];
    }
    
    
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
//        NSURL *placeholderURL = nil;
        UIImage *placeholderImage = nil;
        BTResInfo *resInfo = nil;
        
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
        
        if (imageInfo.originResInfo.resUrl) {
            resInfo = imageInfo.originResInfo;
            imgURL = resInfo.resUrl;
            
        }else{
            resInfo = [imageInfo.imageResArr objectAtIndex:0];
            imgURL = resInfo.resUrl;
            
            // it should be a bug for tumblr, for gif the max size photo of gif just have one frame, but the last 3 is ok
            NSInteger index = imageInfo.imageResArr.count - 3;
            if ([imgURL.pathExtension.lowercaseString isEqualToString:@"gif"] && index >= 0) {
                
                resInfo = [imageInfo.imageResArr objectAtIndex:index];
                imgURL = resInfo.resUrl;
            }
        }
        
        CGFloat imgHeight = SCREEN_WIDTH/resInfo.size.width * resInfo.size.height;
        
        [imgPositions addObject:@(y)];
        
        CGRect frame = CGRectMake(0 , y , SCREEN_WIDTH, imgHeight);
        
        FLAnimatedImageView *imgView = [[FLAnimatedImageView alloc] initWithFrame:frame];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.userInteractionEnabled = YES;
        imgView.tag = i;
        [imgView sd_setImageWithURL:imgURL placeholderImage:placeholderImage];
//        [imgView sd_setImageWithURL:imgURL placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL){
//            [imgView startAnimating];
//        }];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] init];
        [tapGes addTarget:self action:@selector(tapImage:)];
        [imgView addGestureRecognizer:tapGes];
        
        y += imgHeight;
        
        [self.scrollView addSubview:imgView];
        
    }
    
    [self.imagePositionsArr addObject:imgPositions];
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, y + CONTROL_BAR_HEIGHT);
    
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
        [self setupAvatar:post];
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
    
//    js = @"function imageClick(index){window.webkit.messageHandlers.ClickImage.postMessage({index:index});}function addClictEvent(){var imgs = document.getElementsByTagName(\"img\");for(var i = 0; i < imgs.length; i++){}}addClictEvent()";
//    js = @"function addClictEvent1(){var imgs = document.getElementsByTagName(\"img\");for(var i = 0; i < imgs.length; i++){imgs.onClick = function(){window.webkit.messageHandlers.ClickImage.postMessage({index:i});}}};addClictEvent1()";
//    [webView evaluateJavaScript:js completionHandler:^(id value, NSError *error){
//        if (error) {
//            NSLog(@"js error:%@",error);
//        }
//        
//        NSLog(@"value:%@",value);
//    }];
}

#pragma mark WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //JS call OC method
    //message.boby is the parameter from JS
    NSLog(@"body:%@",message.body);
    
    if ([message.name isEqualToString:@"ClickImage"]) {
//        [self ShareWithInformation:message.body];
        if (![message.body isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSNumber *index = [message.body objectForKey:@"index"];
        
        [self tapImage:index];
    }
}

#pragma mark Control Bar Logic
- (void)initControlBar
{
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    
    //    CGFloat viewHeight = 60;// * ADJUST_VIEW_RADIO;
    
    BTWeakSelf(weakSelf);
    UIView *view = [[UIView alloc] init];
    [self.view addSubview:view];
    self.controlView = view;
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakSelf.view);
        //        make.height.mas_equalTo(viewHeight + WINDOW_SAFE_AREA_INSETS.bottom);
        make.height.mas_equalTo(CONTROL_BAR_HEIGHT);
    }];
    
    //Backgtound
    UIImageView *backgroundView = [[UIImageView alloc] init];
    backgroundView.image = [[UIImage imageNamed:@"bg_control_down"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [self.controlView addSubview:backgroundView];
    
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.bottom.right.top.equalTo(weakSelf.controlView);
    }];
    
    //Control Button
    
    //Download
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn setImage:[UIImage imageNamed:@"download-1"] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:downloadBtn];
    
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).with.offset(-20);
        make.top.equalTo(view).with.offset(20);
        make.height.width.mas_equalTo(30);
    }];
    
    //Forward
    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [forwardBtn setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(forward:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:forwardBtn];
    
    [forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(downloadBtn.mas_left).with.offset(-10);
        make.top.equalTo(view).with.offset(20);
        make.height.width.mas_equalTo(30);
    }];
    
    //Like
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeBtn setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [likeBtn addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:likeBtn];
    
    [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(forwardBtn.mas_left).with.offset(-10);
        make.top.equalTo(view).with.offset(20);
        make.height.width.mas_equalTo(30);
    }];
    
    //Link
    UIButton *linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [linkBtn setImage:[UIImage imageNamed:@"link"] forState:UIControlStateNormal];
    [linkBtn addTarget:self action:@selector(link:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:linkBtn];
    
    [linkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(likeBtn.mas_left).with.offset(-10);
        make.top.equalTo(view).with.offset(20);
        make.height.width.mas_equalTo(30);
    }];
    
    //Title & Avatar
    [self setupAvatar:post];
    
}

- (void)setupAvatar:(BTPost*)post
{
    BTWeakSelf(weakSelf);
    if (!self.avatarBtn && self.controlView) {
        self.avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.controlView addSubview:self.avatarBtn];
        [self.avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.controlView).with.offset(20);
            make.top.equalTo(weakSelf.controlView).with.offset(20);
            make.height.width.mas_equalTo(30);
        }];
        
        self.blogNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.blogNameBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.blogNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.controlView addSubview:self.blogNameBtn];
        [self.blogNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.avatarBtn.mas_right).with.offset(5);
            make.top.equalTo(weakSelf.controlView).with.offset(20);
            make.height.mas_equalTo(30);
            make.width.mas_lessThanOrEqualTo(150);
        }];
    }
    
#warning todo set image placeholder
    [self.avatarBtn sd_setImageWithURL:[NSURL URLWithString:post.blogInfo.avatarPath] forState:UIControlStateNormal];
    [self.avatarBtn.layer setValue:post forKey:@"post"];
    
    
    [self.blogNameBtn setTitle:post.blogInfo.name forState:UIControlStateNormal];
    
    
    
}

- (void)avatarClick:(UIButton*)btn
{
    BTPost *post = [self.avatarBtn.layer valueForKey:@"post"];
    //    BTRootViewController *vc = [[BTRootViewController alloc] initWithBlog:post.blogInfo WithDataType:Type_BlogPost];
    BTPostListViewController *vc = [[BTPostListViewController alloc] initWithBlog:post.blogInfo WithDataType:Type_BlogPost];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)download:(id)sender
{
    
}

- (IBAction)forward:(id)sender
{
    NSLog(@"forward button add");
    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    [[APIAccessHelper shareApiAccessHelper] forwardPost:post];
}

- (IBAction)like:(id)sender
{
    
}

- (IBAction)link:(id)sender
{
    
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

