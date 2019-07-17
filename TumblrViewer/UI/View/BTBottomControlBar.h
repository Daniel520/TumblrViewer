//
//  BTBottomControlBar.h
//  TumblrViewer
//
//  Created by Danielyu on 2019/7/17.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTPost;

NS_ASSUME_NONNULL_BEGIN

@interface BTBottomControlBar : UIView

@property (nonatomic, strong) BTPost *post;
+ (BTBottomControlBar*)getControlBar:(UIView*)containView withPost:(BTPost*)post navigationController:(UINavigationController*)navVC;


@end

NS_ASSUME_NONNULL_END
