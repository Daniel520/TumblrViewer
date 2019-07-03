//
//  XWSLeftView.m
//  ElecSafely
//
//  Created by TigerNong on 2018/3/23.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import "XWSLeftView.h"
#import <FLAnimatedImageView.h>
#import <FLAnimatedImageView+WebCache.h>
#define marginLeft 32.0f
#define TableViewMarginRightWidth 120.0f
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define UIColorRGB(rgb) ([[UIColor alloc] initWithRed:(((rgb >> 16) & 0xff) / 255.0f) green:(((rgb >> 8) & 0xff) / 255.0f) blue:(((rgb) & 0xff) / 255.0f) alpha:1.0f])
#define LeftViewTextColor RGBA(170, 170, 170, 1)
#define NavColor UIColorRGB(0x191b27)
#define leftLeftBackColor NavColor
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width


@interface XWSLeftView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) FLAnimatedImageView *icon;
@property (nonatomic, strong) UILabel *accountLabel;

@end

@implementation XWSLeftView

- (instancetype)initWithFrame:(CGRect)frame withUserInfo:(NSDictionary *)userInfo{
    if (self = [super initWithFrame:frame]) {
        [self setUpUI];
        [self initDataWithUserInfo:userInfo];
        
    }
    return self;
}
#pragma mark -  设置界面
- (void)setUpUI{
    self.backgroundColor = [UIColor clearColor];
    [self coverView];
    [self tableView];
}

#pragma mark - 初始化信息
- (void)initDataWithUserInfo:(NSDictionary *)info{
    self.accountLabel.text = info[@"account"];
    NSString *iconUrl = info[@"icon"];
    if (iconUrl) {
        if ([iconUrl containsString:@"http"] || [iconUrl containsString:@"https"]) {
            [self.icon sd_setImageWithURL:[NSURL URLWithString:iconUrl]];
        }else{
            self.icon.image = [UIImage imageNamed:iconUrl];
        }
    }else{
        self.icon.image = [UIImage imageNamed:@"logo_icon"];
    }
}

#pragma mark - 内部方法

- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_coverView];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0;

        [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tableView.mas_right);
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(TableViewMarginRightWidth + ScreenWidth);
        }];
        
        _coverView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCover:)];
        [_coverView addGestureRecognizer:tap];
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCover:)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;
        [_coverView addGestureRecognizer:swipe];
        
    }
    return _coverView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 66.0f;
        _tableView.bounces = NO;
       
        _tableView.backgroundColor = leftLeftBackColor;
        [self addSubview:_tableView];
        _tableView.frame = CGRectMake(0, 0, ScreenWidth - TableViewMarginRightWidth, ScreenHeight);

        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 187)];
        [self setUpHeadView:headView];
        headView.userInteractionEnabled = YES;
        _tableView.tableHeaderView = headView;

        UITapGestureRecognizer *icoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapIcon:)];
        [headView addGestureRecognizer:icoTap];
    }
    return _tableView;
}

- (void)setUpHeadView:(UIView *)supView{
    //头像
    self.icon = [[FLAnimatedImageView alloc] initWithFrame:CGRectZero];
    self.icon.userInteractionEnabled = YES;
    
    [supView addSubview:self.icon];
    /*在这里使用masonry控制，会爆出约束冲突，但是不影响使用，所以就不管了*/
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(70);
        make.left.mas_equalTo(32);
        make.width.height.mas_equalTo(69);
    }];
    self.icon.image = [UIImage imageNamed:@"logo_icon"];
    
    //账号
    self.accountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [supView addSubview:self.accountLabel];
    self.accountLabel.textColor = LeftViewTextColor;
    self.accountLabel.font = [UIFont systemFontOfSize:18];
    self.accountLabel.text = @"test";
    
    /*在这里使用masonry控制，会爆出约束冲突，但是不影响使用，所以就不管了*/
    [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.icon.mas_centerY);
        make.left.equalTo(self.icon.mas_right).mas_equalTo(27);
        make.right.mas_equalTo(-10);
        make.height.mas_equalTo(30);
    }];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XWSLeftViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"XWSLeftViewCell"];
        
        //设置图片
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        headImageView.tag = indexPath.row + 100;
        [cell.contentView addSubview:headImageView];
        [headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(32);
            make.centerY.mas_equalTo(cell.mas_centerY);
            make.width.height.mas_equalTo(29);
        }];
        
        //设置标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [cell.contentView addSubview:titleLabel];
        titleLabel.tag = indexPath.row + 200;
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textColor = LeftViewTextColor;
        /*在这里使用masonry控制，会爆出约束冲突，但是不影响使用，所以就不管了*/
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(headImageView.mas_centerY);
            make.left.mas_equalTo(headImageView.mas_right).mas_equalTo(21);
        }];

        cell.backgroundColor = leftLeftBackColor;
    }
    
    UIImageView *iconImageView = (UIImageView *)[cell.contentView viewWithTag:indexPath.row + 100];
    
    UILabel *titleLab = (UILabel *)[cell.contentView viewWithTag:indexPath.row + 200];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
            iconImageView.image = [UIImage imageNamed:@"heart"];
            titleLab.text = NSLocalizedString(@"like", nil);
            break;
        case 1:
            iconImageView.image = [UIImage imageNamed:@"star"];
            titleLab.text = NSLocalizedString(@"follows", nil);
            break;
        case 2:
            iconImageView.image = [UIImage imageNamed:@"download"];
            titleLab.text = NSLocalizedString(@"download", nil);
            break;
        case 3:
            iconImageView.image = [UIImage imageNamed:@"settings-1"];
            titleLab.text = NSLocalizedString(@"setup_API", nil);
            break;
        case 4:
            iconImageView.image = [UIImage imageNamed:@"logout"];
            titleLab.text = NSLocalizedString(@"logout", nil);
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.delegate respondsToSelector:@selector(touchLeftView:byType:)]) {
        [self.delegate touchLeftView:self byType:indexPath.item + 1];
    }
}

#pragma mark - 手势操作
//点击蒙版
- (void)clickCover:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(touchLeftView:byType:)]) {
        [self.delegate touchLeftView:self byType:XWSTouchItemCoverView];
    }
}
//向左滑动蒙版
- (void)swipeCover:(UISwipeGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(touchLeftView:byType:)]) {
        [self.delegate touchLeftView:self byType:XWSTouchItemCoverView];
    }
}

//点击头像或者账号
- (void)tapIcon:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(touchLeftView:byType:)]) {
        [self.delegate touchLeftView:self byType:XWSTouchItemUserInfo];
    }
}

#pragma mark - 动画
- (void)startCoverViewOpacityWithAlpha:(CGFloat)alpha withDuration:(CGFloat)duration{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:alpha];
    opacityAnimation.duration = duration;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeForwards;
    [_coverView.layer addAnimation:opacityAnimation forKey:@"opacity"];
    _coverView.alpha = alpha;
}

- (void)cancelCoverViewOpacity{
    [_coverView.layer removeAllAnimations];
    _coverView.alpha = 0;
}

@end
