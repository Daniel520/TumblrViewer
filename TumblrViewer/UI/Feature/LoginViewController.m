//
//  LoginViewController.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/27.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "LoginViewController.h"
#import "APIAccessHelper.h"
#import "BTRootViewController.h"

@interface LoginViewController ()

@property (nonatomic, strong) UIButton *authButton;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *setKeyBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpAuthenticateButton];
}

- (void)initView{
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
}

- (void)setUpAuthenticateButton {
    
    CGFloat btnWidth = 280 * ADJUST_VIEW_RADIO;
    CGFloat btnHeight = 40 * ADJUST_VIEW_RADIO;
    
    //Login Button
    //login button shadow
    CALayer *loginBtnShadowlayer = [CALayer layer];
    
    loginBtnShadowlayer.frame = CGRectMake(SCREEN_WIDTH/2 - btnWidth/2, SCREEN_HEIGHT - 124 - btnHeight, btnWidth, btnHeight);
    
    loginBtnShadowlayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    
    loginBtnShadowlayer.shadowOffset = CGSizeMake(3, 3);
    
    loginBtnShadowlayer.shadowOpacity = 0.7;
    
    loginBtnShadowlayer.cornerRadius = 10;
    
    [self.view.layer addSublayer:loginBtnShadowlayer];
    
    //button
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn.frame = CGRectMake(SCREEN_WIDTH/2 - btnWidth/2, SCREEN_HEIGHT - 124 - btnHeight, btnWidth, btnHeight);
    self.loginBtn.backgroundColor = [UIColor whiteColor];
    self.loginBtn.layer.cornerRadius = 5;
    
    [self.loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginBtn addTarget:self action:@selector(authenticate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginBtn];
    
    //Set API KEY
    //button shadow
    CALayer *shadowlayer = [CALayer layer];
    
    shadowlayer.frame = CGRectMake(SCREEN_WIDTH/2 - btnWidth/2, SCREEN_HEIGHT - 60 - btnHeight, btnWidth, btnHeight);
    
    shadowlayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    
    shadowlayer.shadowOffset = CGSizeMake(3, 3);
    
    shadowlayer.shadowOpacity = 0.7;
    
    shadowlayer.cornerRadius = 10;
    
    [self.view.layer addSublayer:shadowlayer];
    
    
    self.setKeyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.setKeyBtn.frame = CGRectMake(SCREEN_WIDTH/2 - btnWidth/2, SCREEN_HEIGHT - 60 - btnHeight, btnWidth, btnHeight);
    self.setKeyBtn.backgroundColor = [UIColor whiteColor];
    self.setKeyBtn.layer.cornerRadius = 5;
    
    [self.setKeyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.setKeyBtn setTitle:@"Set Your API Key" forState:UIControlStateNormal];
    [self.setKeyBtn addTarget:self action:@selector(gotoSetKey) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.setKeyBtn];
}

- (IBAction)gotoSetKey
{
    
}

- (IBAction)authenticate
{
    BTWeakSelf(weakSelf);
    [[APIAccessHelper shareApiAccessHelper] authenticate:^(NSError *error){
        if (error) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Login Fail" message:@"Login fail,you may check your network and try again" preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            
            [actionSheet addAction:action1];
            
            //相当于之前的[actionSheet show];
            [weakSelf presentViewController:actionSheet animated:YES completion:nil];
        }else{
            
            weakSelf.authButton.hidden = YES;
            
            [weakSelf enterMainPage];
        }
        
    }];
}

- (void)enterMainPage
{
    BTRootViewController *rootVC = [BTRootViewController new];
    [self.navigationController pushViewController:rootVC animated:NO];
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
