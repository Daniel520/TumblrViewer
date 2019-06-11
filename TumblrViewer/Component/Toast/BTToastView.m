//
//  BTToastView.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/10.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTToastView.h"

@implementation BTToastView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        
        self.imageView = [[UIImageView alloc] init];
        [self.imageView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:self.imageView];
        
        self.textLabel = [[UILabel alloc] init];
        [self.textLabel setTextColor:[UIColor whiteColor]];
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
        self.textLabel.numberOfLines = 0;
        [self.textLabel setFont:[UIFont systemFontOfSize:14.0]];
//        [self.textLabel setFont:[UIFont fontWithName:DEFAULT_FONT_NAME size:size]];
        [self addSubview:self.textLabel];
    }
    
    return self;
}

-(void)setToastInfo:(BTToastInfo *)toastInfo
{
    _toastInfo = toastInfo;
    
    self.imageView.image = toastInfo.image;
    
    self.textLabel.text = toastInfo.text;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat statusBarHeight = iOS11SafeAreaInsets().top;
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait)
    {
        statusBarHeight = 0;
    }
    
    CGFloat contentHeight = self.frame.size.height - statusBarHeight;
    
    self.imageView.hidden = NO;
    
    [self.imageView setFrame:CGRectMake(15, (contentHeight-20)/2.0 + statusBarHeight, 20, 20)];
    [self.textLabel setFrame:CGRectMake(45, statusBarHeight, self.frame.size.width - 55, contentHeight)];
    
    
    if (!self.toastInfo.image)
    {
        self.imageView.hidden = YES;
        [self.textLabel setFrame:CGRectMake(10, self.textLabel.frame.origin.y, self.frame.size.width - 20, contentHeight)];
    }
}

@end
