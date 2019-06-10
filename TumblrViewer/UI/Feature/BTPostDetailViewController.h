//
//  BTPostDetailViewController.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/10.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostsDataModel.h"
#import "BTPost.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTPostDetailViewController : UIViewController

- (instancetype)initWithPost:(BTPost*)post;
- (instancetype)initWithPostsDataCenter:(PostsDataModel*)dataModel atIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
