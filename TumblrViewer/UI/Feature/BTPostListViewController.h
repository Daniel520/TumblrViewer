//
//  BTPostListViewController.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/17.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTBaseViewController.h"
#import "PostsDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTPostListViewController : BTBaseViewController

- (void)loadData:(BOOL)isLoadMore;
- (instancetype)initWithBlog:(BTBlogInfo*)blog WithDataType:(PostsType)type;

@end

NS_ASSUME_NONNULL_END
