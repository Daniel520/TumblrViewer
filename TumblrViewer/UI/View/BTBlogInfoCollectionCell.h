//
//  BTBlogInfoCollectionCell.h
//  TumblrViewer
//
//  Created by Daniel on 2019/7/14.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define BLOG_CELL_IDENTIFIER @"blogInfoCell"

@interface BTBlogInfoCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *name;

+ (CGSize)cellSize;

@end

NS_ASSUME_NONNULL_END
