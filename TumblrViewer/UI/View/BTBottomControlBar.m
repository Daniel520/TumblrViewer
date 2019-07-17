//
//  BTBottomControlBar.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/7/17.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTBottomControlBar.h"
#import "BTPost.h"
//#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>
#import "BTPostListViewController.h"
#import "APIAccessHelper.h"

@interface BTBottomControlBar()

@property (nonatomic, strong) UIButton *avatarBtn;
@property (nonatomic, strong) UIButton *blogNameBtn;
@property (nonatomic, strong) UINavigationController *navVC;
@end

@implementation BTBottomControlBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (BTBottomControlBar*)getControlBar:(UIView*)containView withPost:(BTPost*)post navigationController:(UINavigationController*)navVC
{
//    BTWeakSelf(weakSelf);
    BTBottomControlBar *controlBar = [[BTBottomControlBar alloc] init];
    //setup post & Title & Avatar at the same time
    controlBar.post = post;
    controlBar.navVC = navVC;
    [containView addSubview:controlBar];
    
    
    [controlBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(containView);
        //        make.height.mas_equalTo(viewHeight + WINDOW_SAFE_AREA_INSETS.bottom);
        make.height.mas_equalTo(CONTROL_BAR_HEIGHT);
    }];
    
    //Backgtound
    UIImageView *backgroundView = [[UIImageView alloc] init];
    backgroundView.image = [[UIImage imageNamed:@"bg_control_down"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [controlBar addSubview:backgroundView];
    
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.bottom.right.top.equalTo(controlBar);
    }];
    
    //Control Button
    
    //Download
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn setImage:[UIImage imageNamed:@"download-1"] forState:UIControlStateNormal];
    [downloadBtn addTarget:controlBar action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
    [controlBar addSubview:downloadBtn];
    
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(controlBar).with.offset(-20);
        make.top.equalTo(controlBar).with.offset(20);
        make.height.width.mas_equalTo(30);
    }];
    
    //Forward
    UIButton *forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [forwardBtn setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
    [forwardBtn addTarget:controlBar action:@selector(forward:) forControlEvents:UIControlEventTouchUpInside];
    [controlBar addSubview:forwardBtn];
    
    [forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(downloadBtn.mas_left).with.offset(-10);
        make.top.equalTo(controlBar).with.offset(20);
        make.height.width.mas_equalTo(30);
    }];
    
    //Like
    UIButton *likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeBtn setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [likeBtn addTarget:controlBar action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
    [controlBar addSubview:likeBtn];
    
    [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(forwardBtn.mas_left).with.offset(-10);
        make.top.equalTo(controlBar).with.offset(20);
        make.height.width.mas_equalTo(30);
    }];
    
    //Link
    UIButton *linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [linkBtn setImage:[UIImage imageNamed:@"link"] forState:UIControlStateNormal];
    [linkBtn addTarget:controlBar action:@selector(link:) forControlEvents:UIControlEventTouchUpInside];
    [controlBar addSubview:linkBtn];
    
    [linkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(likeBtn.mas_left).with.offset(-10);
        make.top.equalTo(controlBar).with.offset(20);
        make.height.width.mas_equalTo(30);
    }];
    
//    [controlBar setupAvatar:post];
    
    return controlBar;
    
}

- (void)setPost:(BTPost *)post
{
    _post = post;
    
    [self setupAvatar:post];
    
}

- (void)setupAvatar:(BTPost*)post
{
    BTWeakSelf(weakSelf);
    if (!self.avatarBtn) {
        self.avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.avatarBtn];
        [self.avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf).with.offset(20);
            make.top.equalTo(weakSelf).with.offset(20);
            make.height.width.mas_equalTo(30);
        }];
        
        self.blogNameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.blogNameBtn addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.blogNameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:self.blogNameBtn];
        [self.blogNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.avatarBtn.mas_right).with.offset(5);
            make.top.equalTo(weakSelf).with.offset(20);
            make.height.mas_equalTo(30);
            make.width.mas_lessThanOrEqualTo(150);
        }];
    }
    
//#warning todo set image placeholder
    [self.avatarBtn sd_setImageWithURL:[NSURL URLWithString:post.blogInfo.avatarPath] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar.png"]];
//    [self.avatarBtn sd_setImageWithURL:[NSURL URLWithString:post.blogInfo.avatarPath] forState:UIControlStateNormal];
    [self.avatarBtn.layer setValue:post forKey:@"post"];
    
    
    [self.blogNameBtn setTitle:post.blogInfo.name forState:UIControlStateNormal];
}

- (void)avatarClick:(UIButton*)btn
{
    BTPost *post = [self.avatarBtn.layer valueForKey:@"post"];
    //    BTRootViewController *vc = [[BTRootViewController alloc] initWithBlog:post.blogInfo WithDataType:Type_BlogPost];
    BTPostListViewController *vc = [[BTPostListViewController alloc] initWithBlog:post.blogInfo WithDataType:Type_BlogPost];
    [self.navVC pushViewController:vc animated:YES];
}

- (IBAction)download:(id)sender
{
    
}

- (IBAction)forward:(id)sender
{
    NSLog(@"forward button add");
    //    BTPost *post = [self.postDataModel.posts objectAtIndex:self.currentIndexPath.section];
    [[APIAccessHelper shareApiAccessHelper] forwardPost:self.post];
}

- (IBAction)like:(id)sender
{
    
}

- (IBAction)link:(id)sender
{
    
}

@end
