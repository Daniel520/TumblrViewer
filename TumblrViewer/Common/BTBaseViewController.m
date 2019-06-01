//
//  BTBaseViewController.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/1.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTBaseViewController.h"

@interface BTBaseViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation BTBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)showLoading
{
    if (!self.loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loadingView = loadingView;
    }
    
    self.loadingView.center = self.view.center;
    self.loadingView.color = UIColor.grayColor;
    [self.view addSubview:self.loadingView];
    [self.loadingView startAnimating];
}

- (void)hideLoading
{
    [self.loadingView stopAnimating];
    [self.loadingView removeFromSuperview];
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
