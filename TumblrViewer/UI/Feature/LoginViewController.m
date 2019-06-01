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
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setUpAuthenticateButton];
    [self setupMainIcon];
}

- (void)setupMainIcon
{
    BTWeakSelf(weakSelf);
    UIView *containView = [[UIView alloc] init];
    [self.view addSubview:containView];

    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.loginBtn.mas_top).mas_offset(-30);
    }];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"icon1024"];
    
    [containView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.lessThanOrEqualTo(containView.mas_width).mas_offset(-40);
        make.height.lessThanOrEqualTo(containView);
//        make.bottom.lessThanOrEqualTo(self.loginBtn.mas_top).mas_offset(-30);
//        make.top.equalTo(weakSelf.view.mas_top).mas_offset(30);
        
        make.width.equalTo(imageView.mas_height);
        make.center.equalTo(containView);
    }];
}

- (void)initView{
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
}

- (void)setUpAuthenticateButton {
    
    BTWeakSelf(weakSelf);
//    CGFloat btnWidth = 280 * ADJUST_VIEW_RADIO;
    CGFloat btnHeight = 40;// * ADJUST_VIEW_RADIO;
    
    CGFloat btnPadding = 20 * ADJUST_VIEW_RADIO;
    
    //Set API KEY Button
    
    self.setKeyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.setKeyBtn.frame = CGRectMake(SCREEN_WIDTH/2 - btnWidth/2, SCREEN_HEIGHT - 60 - btnHeight, btnWidth, btnHeight);
    self.setKeyBtn.backgroundColor = [UIColor whiteColor];
    self.setKeyBtn.layer.cornerRadius = 5;
    
    [self.setKeyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.setKeyBtn setTitle:@"Set Your API Key" forState:UIControlStateNormal];
    [self.setKeyBtn addTarget:self action:@selector(gotoSetKey) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.setKeyBtn];
    
    self.setKeyBtn.layer.shadowOffset = CGSizeMake(3, 3);
    
    self.setKeyBtn.layer.shadowOpacity = 0.7;
    
    self.setKeyBtn.layer.cornerRadius = 10;
    
    [self.setKeyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view).with.offset(-40);
        make.left.right.equalTo(weakSelf.view).insets(UIEdgeInsetsMake(0, btnPadding, 0, btnPadding));
        make.height.mas_equalTo(btnHeight);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
    }];

    
    //Login Button

    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.loginBtn.frame = CGRectMake(SCREEN_WIDTH/2 - btnWidth/2, SCREEN_HEIGHT - 124 - btnHeight, btnWidth, btnHeight);
    self.loginBtn.backgroundColor = [UIColor whiteColor];
    self.loginBtn.layer.cornerRadius = 5;
    self.loginBtn.layer.shadowOffset = CGSizeMake(3, 3);
    self.loginBtn.layer.shadowOpacity = 0.7;
    self.loginBtn.layer.cornerRadius = 10;
    
    [self.loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.loginBtn setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginBtn addTarget:self action:@selector(authenticate) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.loginBtn];
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.setKeyBtn.mas_top).with.offset(-20);
//        make.width.mas_equalTo(weakSelf.setKeyBtn.mas_width);
        make.left.equalTo(weakSelf.setKeyBtn.mas_left);
        make.right.equalTo(weakSelf.setKeyBtn.mas_right);
        make.height.mas_equalTo(weakSelf.setKeyBtn.mas_height);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
    }];
}

- (IBAction)gotoSetKey
{
    
}

- (IBAction)authenticate
{
    BTWeakSelf(weakSelf);
    [self showLoading];
    
    [[APIAccessHelper shareApiAccessHelper] authenticate:^(NSError *error){
        [self hideLoading];
        if (error) {
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Login Fail" message:@"Login fail,you may check your network and try again" preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            
            [actionSheet addAction:action1];
            
            //For iPad need below code
            UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
            
            if (popover) {
                
                popover.sourceView = weakSelf.loginBtn;
                popover.sourceRect = weakSelf.loginBtn.bounds;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            
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
    self.navigationController.navigationBar.hidden = NO;
    
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
