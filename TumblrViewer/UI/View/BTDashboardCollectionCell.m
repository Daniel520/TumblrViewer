//
//  BTDashboardCollectionCell.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/31.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTDashboardCollectionCell.h"
#import <UIImageView+WebCache.h>

@interface BTDashboardCollectionCell()

@property (nonatomic,strong) NSArray *cats;

@end

@implementation BTDashboardCollectionCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.contentView.backgroundColor = [UIColor lightGrayColor];
//        self.cats = @[@"cat1.jpg", @"cat2.jpg", @"cat3.jpg", @"cat4.jpg"];
    }
    return self;
}


//- (instancetype)initWithImageInfo:(BTImageInfo *)imageInfo
//{
//    return  [self initWithImageInfos:@[imageInfo]];
//}
//
//- (instancetype)initWithImageInfos:(NSArray *)imageInfoArr
//{
//    if (self = [super init]) {
//
//    }
//
//    return self;
//}
//
//- (instancetype)initWithImageURLs:(NSArray*)imgeURLs
//{
//    if (self = [super init]) {
//
//    }
//
//    return self;
//}

- (void)setImgDicArr:(NSArray *)imgDicArr
{
    if (self.contentView.subviews.count > 0) {
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    BTWeakSelf(weakSelf);
    long y = 0;
//    for (NSDictionary *imageDic in imgDicArr) {
    for (int i = 0; i < imgDicArr.count; i++) {
        NSDictionary *imageDic = [imgDicArr objectAtIndex:i];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        
        NSString *imgURL = [imageDic objectForKey:@"url"];
        NSNumber *width = [imageDic objectForKey:@"width"];
        NSNumber *height = [imageDic objectForKey:@"height"];
        
        long viewHeight = [height longValue] * CGRectGetWidth(self.contentView.frame) / [width longValue] ;
    
        if (viewHeight > SCREEN_HEIGHT) {
            viewHeight = SCREEN_HEIGHT;
        }
        
        imgView.backgroundColor = [UIColor lightGrayColor];
//        imgView.backgroundColor = [UIColor colorWithRed:i/255.0 green:(255-i)%255/255.0 blue:((255-i+1))%255/255.0 alpha:1];
        
#warning todo sdwebimage使用有问题
        [imgView sd_setImageWithURL:[NSURL URLWithString:imgURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

            [imgView setFrame:CGRectMake(0, y, CGRectGetWidth(weakSelf.contentView.frame), viewHeight)];

        }];

        [imgView setFrame:CGRectMake(0, y, CGRectGetWidth(self.contentView.frame), viewHeight)];
        
        y += [height longValue];
        
        [self.contentView addSubview:imgView];
    }
}


@end
