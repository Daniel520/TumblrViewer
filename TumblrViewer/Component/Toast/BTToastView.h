//
//  BTToastView.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/10.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTToastInfo.h"

@interface BTToastView : UIView

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *textLabel;

@property (nonatomic,strong) BTToastInfo *toastInfo;

@end
