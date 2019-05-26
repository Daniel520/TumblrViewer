//
//  BTPostGallaryViewController.h
//  TumblrViewer
//
//  Created by Danielyu on 2019/5/11.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostsDataCenter.h"
#import "BTPost.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTPostGallaryViewController : UIViewController

- (instancetype)initWithPost:(BTPost*)post;
- (instancetype)initWithPostsDataCenter:(PostsDataCenter*)postDataCenter atIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
