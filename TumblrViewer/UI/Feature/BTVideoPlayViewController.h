//
//  BTVideoPlayViewController.h
//  TumblrViewer
//
//  Created by Danielyu on 2019/5/25.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTPost.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTVideoPlayViewController : UIViewController

- (instancetype)initWithPost:(BTPost*)post;

@end

NS_ASSUME_NONNULL_END
