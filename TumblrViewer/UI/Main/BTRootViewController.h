//
//  BTRootViewController.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/28.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTBaseViewController.h"
#import "PostsDataModel.h"

#define CELL_IDENTIFIER @"blogInfoCell"

NS_ASSUME_NONNULL_BEGIN

@interface BTRootViewController : BTBaseViewController

//- (void)loadData:(BOOL)isLoadMore;
//- (instancetype)initWithBlog:(BTBlogInfo*)blog WithDataType:(PostsType)type;

- (instancetype)initWithBlog:(BTBlogInfo*)blog;

@end

NS_ASSUME_NONNULL_END
