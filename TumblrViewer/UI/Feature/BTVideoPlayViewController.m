//
//  BTVideoPlayViewController.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/5/25.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTVideoPlayViewController.h"
#import <AVKit/AVKit.h>
#import <UIButton+WebCache.h>

#import "APIAccessHelper.h"
//#import "BTVideoPlayerView.h"
#import "BTPostListViewController.h"
#import "BTBottomControlBar.h"

@interface BTVideoPlayViewController ()

@property (nonatomic, strong) BTPost *post;
@property (nonatomic, strong) AVPlayerViewController *playerController;
//@property (nonatomic, strong) BTVideoPlayerView *player;
//@property (nonatomic, strong) UIView *videoControlView;

//Control Bar
@property (nonatomic, strong) BTBottomControlBar *controlBar;
//@property (nonatomic, strong) UIButton *avatarBtn;
//@property (nonatomic, strong) UIButton *blogNameBtn;
@end

@implementation BTVideoPlayViewController

- (instancetype)initWithPost:(BTPost*)post
{
    self = [super init];
    if (self) {
        self.title = post.title;
        self.post = post;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    BTWeakSelf(weakSelf);
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[self.post.videoInfo.resolutionInfo lastObject].resUrl];

    self.playerController = [[AVPlayerViewController alloc] init];
    self.playerController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    self.playerController.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerController.showsPlaybackControls = YES;
    
//    self.playerController.view.frame = self.view.bounds;
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
    
    [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.left.bottom.right.equalTo(weakSelf.view);
    }];
    //    [self addObserverForPlayer];
    [self.playerController.player play];
    
    [self.playerController.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerController.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    [self.playerController.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerController.player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerController.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerController.player.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.playerController.contentOverlayView;
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.controlBar) {
        [self performSelector:@selector(updatePlaybackControlbarInView) withObject:nil afterDelay:0.2];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.playerController.player pause];
}

- (void)updatePlaybackControlbarInView
{
    NSArray *views = [self.playerController.view subviews];
    UIView *avplayerView = views[0];
    views = [avplayerView subviews];
#warning todo, mix the class name avoid apple review risk
    for (UIView *view in views) {
        if ([view isKindOfClass:NSClassFromString(@"AVPlaybackControlsView")]) {
            NSLog(@"find playbackcontrolview");
            
            if ([UIDevice currentDevice].systemVersion.floatValue < 12) {
                for (UIView *subview in [view subviews]) {
                    if ([subview isKindOfClass:NSClassFromString(@"AVView")] &&
                        ![subview isKindOfClass:NSClassFromString(@"AVBackdropView")]) {
                        NSLog(@"find AVView %@",[subview class]);
                        
                        [subview mas_updateConstraints:^(MASConstraintMaker *maker){
                            maker.bottom.equalTo(view.mas_bottom).offset(-CONTROL_BAR_HEIGHT);
                            
                        }];
                    }
                }
            } else {
                NSArray *views = [view subviews];
                UIView *touchIngoringView =views[0];
                
                views = [touchIngoringView subviews];
                
                for (UIView *view in views) {
                    if ([view isKindOfClass:NSClassFromString(@"AVView")] && ![view isKindOfClass:NSClassFromString(@"AVBackdropView")]) {
                        NSLog(@"find AVView");
                        
                        [view mas_updateConstraints:^(MASConstraintMaker *maker){
                            maker.bottom.equalTo(touchIngoringView.mas_bottom).offset(-CONTROL_BAR_HEIGHT);
                            
                        }];
                    }
                }
            }
            
            
//            [self initControlBar:self.view];
            [self initControlBar];
            
        }
    }
    
    
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatePlaybackControlbarInView) object:nil];
    
    if (self.playerController.player)
    {
        [self.playerController.player removeObserver:self forKeyPath:@"rate"];
        [self.playerController.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.playerController.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.playerController.player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
        [self.playerController.player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.playerController.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self.playerController.player.currentItem) {
        if([keyPath isEqualToString:@"status"]){
            switch ([[change objectForKey:@"new"] intValue] ) {
                case AVPlayerStatusUnknown:
                    NSLog(@"AVPlayerStatusUnknown");
                    break;
                    
                case AVPlayerStatusReadyToPlay:
                    
                    
                    NSLog(@"AVPlayerStatusReadyToPlay");
                    
                    break;
                    
                case AVPlayerStatusFailed:
                    NSLog(@"AVPlayerStatusFailed");
                    break;
                    
                default:
                    break;
            }
        }else if( [keyPath isEqualToString:@"loadedTimeRanges"]){
            
           
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
            NSLog(@"playbackBufferEmpty");
            
            
        }
    } else if(object == self.playerController.player && [keyPath isEqualToString:@"rate"]){
        //After BTVideoPlayBackStateReadyToPlay status to set video status to BTVideoPlaybackStatePlaying
        
        NSLog(@"rate : %f",self.playerController.player.rate);
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:nil];
    }
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    BTWeakSelf(weakSelf);
//
//    self.player = [[BTVideoPlayerView alloc] init];
//    [self.view addSubview:self.player];
//
//    [self.player mas_makeConstraints:^(MASConstraintMaker *maker){
//        maker.left.right.bottom.top.equalTo(weakSelf.view);
//    }];
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//
//    self.videoControlView = [self.player controlView];
//    [self initControlBar:self.videoControlView];
//
//    [self.player playVideoByURL:[self.post.videoInfo.resolutionInfo lastObject].resUrl];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//
//    [self.player pause];
//}
//
//- (void)dealloc
//{
//    [self.player stop];
//}


#pragma mark Control Bar Logic
- (void)initControlBar
{
    BTBottomControlBar *controlBar = [BTBottomControlBar getControlBar:self.view withPost:self.post navigationController:self.navigationController];
    self.controlBar = controlBar;
}
//- (void)initControlBar:(UIView*)containView;
//{
////    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
//    BTPost *post = self.post;
//    //    CGFloat viewHeight = 60;// * ADJUST_VIEW_RADIO;
//
//    BTWeakSelf(weakSelf);
//    UIView *view = [[UIView alloc] init];
//    [containView addSubview:view];
//    self.controlBar = view;
//
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.equalTo(containView);
//        //        make.height.mas_equalTo(viewHeight + WINDOW_SAFE_AREA_INSETS.bottom);
//        make.height.mas_equalTo(CONTROL_BAR_HEIGHT);
//    }];
//
//    //Backgtound
//    UIImageView *backgroundView = [[UIImageView alloc] init];
//    backgroundView.image = [[UIImage imageNamed:@"bg_control_down"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
//    [self.controlBar addSubview:backgroundView];
//
//    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make){
//        make.left.bottom.right.top.equalTo(weakSelf.controlBar);
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
//    if (!self.avatarBtn && self.controlBar) {
//        self.avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.avatarBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
//
//        [self.controlBar addSubview:self.avatarBtn];
//        [self.avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(weakSelf.controlBar).with.offset(20);
//            make.top.equalTo(weakSelf.controlBar).with.offset(20);
//            make.height.width.mas_equalTo(30);
//        }];
//
//        self.blogNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.blogNameBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.blogNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [self.controlBar addSubview:self.blogNameBtn];
//        [self.blogNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(weakSelf.avatarBtn.mas_right).with.offset(5);
//            make.top.equalTo(weakSelf.controlBar).with.offset(20);
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
////    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
//    [[APIAccessHelper shareApiAccessHelper] forwardPost:self.post];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
