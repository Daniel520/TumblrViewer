//
//  BTMainTabViewController.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/27.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTMainTabViewController.h"

@interface BTMainTabViewController ()

@end

@implementation BTMainTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //创建tabBarController
    UIViewController *vcA = [[UIViewController alloc]init];
    UIViewController *vcB = [[UIViewController alloc]init];
    UIViewController *vcC = [[UIViewController alloc]init];
    UIViewController *vcD = [[UIViewController alloc]init];
    UIViewController *vcE = [[UIViewController alloc]init];
    UIViewController *vcF = [[UIViewController alloc]init];
    UIViewController *vcG = [[UIViewController alloc]init];
    
    
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:vcA];
    
    //添加控制器
    self.viewControllers = @[nav1,vcB,vcC,vcD,vcE,vcF,vcG];
    
    
    //设置tabBarButton
    nav1.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"首页" image:[UIImage imageNamed:@"home_normal"] selectedImage:[UIImage imageNamed:@"home_highlight"]];
    vcB.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"导览" image:[[UIImage imageNamed:@"topics_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"topics_highlight"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    vcC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"资讯" image:[UIImage imageNamed:@"service_normal"] selectedImage:[UIImage imageNamed:@"service_highlight"]];
    vcD.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"资讯" image:[UIImage imageNamed:@"service_normal"] selectedImage:[UIImage imageNamed:@"service_highlight"]];
    vcE.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"资讯" image:[UIImage imageNamed:@"service_normal"] selectedImage:[UIImage imageNamed:@"service_highlight"]];
    vcF.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"资讯" image:[UIImage imageNamed:@"service_normal"] selectedImage:[UIImage imageNamed:@"service_highlight"]];
    vcG.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"资讯" image:[UIImage imageNamed:@"service_normal"] selectedImage:[UIImage imageNamed:@"service_highlight"]];
    
    vcB.tabBarItem.imageInsets = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    vcC.tabBarItem.badgeValue = @"2";
    vcC.tabBarItem.badgeColor = [UIColor redColor];
    
    self.tabBar.tintColor = [UIColor orangeColor];
    
    self.tabBar.backgroundColor = [UIColor redColor];
    self.tabBar.backgroundImage = [[UIImage alloc]init];
    
    self.selectedIndex = 0;
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
