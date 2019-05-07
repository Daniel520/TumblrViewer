//
//  BTDashboardCollectionCell.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/31.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTImageInfo.h"
#import "BTPost.h"

#define CELL_IDENTIFIER @"DashboardCell"

NS_ASSUME_NONNULL_BEGIN

@interface BTDashboardCollectionCell : UICollectionViewCell

@property (nonatomic, strong) BTPost *post;
//@property (nonatomic, strong) NSArray *imgDicArr;

//- (instancetype)initWithImageInfo:(BTImageInfo*)imageInfo;
//
//- (instancetype)initWithImageInfos:(NSArray *)imageInfoArr;
//
//- (instancetype)initWithImageURLs:(NSArray*)imgeURLs;

@end

NS_ASSUME_NONNULL_END
