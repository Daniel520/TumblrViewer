//
//  BTVideoPlayViewController.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/5/25.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTVideoPlayViewController.h"
#import <AVKit/AVKit.h>

@interface BTVideoPlayViewController ()

@property (nonatomic, strong) BTPost *post;
@property (nonatomic, strong) AVPlayerViewController *playerController;

@end

@implementation BTVideoPlayViewController

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
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[self.post.videoInfo.resolutionInfo lastObject].resUrl];
    
    self.playerController = [[AVPlayerViewController alloc] init];
    self.playerController.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    self.playerController.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerController.showsPlaybackControls = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.playerController.view.frame = self.view.bounds;
    [self addChildViewController:self.playerController];
    [self.view addSubview:self.playerController.view];
    //    [self addObserverForPlayer];
    [self.playerController.player play];
    
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
