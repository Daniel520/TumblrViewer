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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupScrollView];
    [self setupImageViews];
//    FLAnimatedImageView *imgView = [[FLAnimatedImageView alloc] initWithFrame:self.view.bounds];
//    imgView.contentMode = UIViewContentModeScaleAspectFit;
//
//    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
//
//    BTImageInfo *imageInfo = [post.imageInfos objectAtIndex:self.currentIndexPath.item];
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
//    [imgView sd_setImageWithURL:imgURL];
    
//    [self.view addSubview:imgView];
}

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
    self.scrollView.contentSize = CGSizeMake(self.scrollView.subviews.count * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
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
    
    [self.view addSubview:self.scrollView];
}

- (void)scrollToPageIndex:(NSInteger)index
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGPoint position = CGPointMake(index * pageWidth, 0);
    [self.scrollView setContentOffset:position animated:YES];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = (scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width;
    NSLog(@"%ld",(long)index);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:self.currentIndexPath.section];
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
