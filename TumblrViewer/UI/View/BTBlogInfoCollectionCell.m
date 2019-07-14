//
//  BTBlogInfoCollectionCell.m
//  TumblrViewer
//
//  Created by Daniel on 2019/7/14.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTBlogInfoCollectionCell.h"

#define cell_width 60

@interface BTBlogInfoCollectionCell()

@property (nonatomic ,strong) UIView *iconContainView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation BTBlogInfoCollectionCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    BTWeakSelf(weakSelf);
    UIView *layoutView = [[UIView alloc] init];
    
    UIView *iconContainView = [[UIView alloc] init];
    self.iconContainView = iconContainView;
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    self.label = label;
    
    [layoutView addSubview:iconContainView];
    [layoutView addSubview:label];
    
    [self.contentView addSubview:layoutView];
    
    [layoutView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.center.equalTo(weakSelf);
        maker.width.height.mas_equalTo(cell_width);
    }];
    
    [iconContainView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.left.right.equalTo(layoutView);
        maker.width.equalTo(iconContainView.mas_height);
    }];
    
    iconContainView.layer.cornerRadius = cell_width / 2;
    iconContainView.clipsToBounds = YES;
    
    [label mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.left.right.equalTo(layoutView);
        maker.top.equalTo(iconContainView.mas_bottom);
    }];
}

- (void)setName:(NSString *)name
{
    _name = name;
    
    self.label.text = name;
}

- (void)setImageView:(UIImageView *)imageView
{
    _imageView = imageView;
    
    if (self.iconContainView.subviews.count > 0) {
        [self.iconContainView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    BTWeakSelf(weakSelf);
    
    [self.iconContainView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *maker){
        maker.top.left.bottom.right.equalTo(weakSelf.iconContainView);
    }];
}

+ (CGSize)cellSize
{
    return CGSizeMake(cell_width, cell_width + 20);
}

@end
