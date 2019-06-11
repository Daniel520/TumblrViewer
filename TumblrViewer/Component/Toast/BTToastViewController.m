//
//  BTToastViewController.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/10.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTToastViewController.h"
#import "BTToastViewControllerContainerView.h"

@interface BTToastViewController ()

@end

@implementation BTToastViewController

- (void)loadView
{
    self.view = [[BTToastViewControllerContainerView alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
