//
//  BTCollectionViewWaterfallLayout.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/15.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "CHTCollectionViewWaterfallLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface BTCollectionViewWaterfallLayout : CHTCollectionViewWaterfallLayout

- (CGFloat)getShortestOffsetWithCount:(NSUInteger)currentCount inSection:(NSUInteger)section;

@end

NS_ASSUME_NONNULL_END
