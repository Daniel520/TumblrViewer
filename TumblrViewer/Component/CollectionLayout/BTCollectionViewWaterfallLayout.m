//
//  BTCollectionViewWaterfallLayout.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/15.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTCollectionViewWaterfallLayout.h"
@interface BTCollectionViewWaterfallLayout()

- (NSUInteger)nextColumnIndexForItem:(NSInteger)item inSection:(NSInteger)section;

@end;

@implementation BTCollectionViewWaterfallLayout

//- (NSUInteger)nextColumnIndexForItem:(NSInteger)item inSection:(NSInteger)section;

- (CGFloat)getShortestOffsetWithCount:(NSUInteger)currentCount inSection:(NSUInteger)section;
{
    if ([self respondsToSelector:@selector(nextColumnIndexForItem:inSection:)]) {
        
        NSMutableArray *columnHeights = [super performSelector:@selector(columnHeights)];

        if (columnHeights && columnHeights.count > 0) {
            NSUInteger columnIndex = [self nextColumnIndexForItem:currentCount inSection:0];
            
            CGFloat yOffset = [columnHeights[section][columnIndex] floatValue];
            
            return yOffset;
        }
        
    }
    return 0;
}

@end
