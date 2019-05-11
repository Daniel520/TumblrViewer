//
//  BTDashboardCollectionCell.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/31.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTDashboardCollectionCell.h"
#import <UIImageView+WebCache.h>
#import <UIImage+GIF.h>
#import <FLAnimatedImageView.h>
#import <FLAnimatedImageView+WebCache.h>

@interface BTDashboardCollectionCell()

//@property (nonatomic,strong) NSArray *cats;

@end

@implementation BTDashboardCollectionCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.contentView.backgroundColor = [UIColor lightGrayColor];
//        self.contentView.layer.cornerRadius = 5;
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

- (void)setPost:(BTPost *)post
{
    if (self.contentView.subviews.count > 0) {
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (post.type == DBPhoto) {
        [self setImgDicArr:post.imgURLs];
    }else if (post.type == DBText) {
        [self setContentText:post.text];
    }else if (post.type == DBVideo) {
        [self setVideoInfo:post.videoInfo];
    }
}

- (void)setVideoInfo:(BTVideoInfo*)videoInfo{
    
    FLAnimatedImageView *imgView = [[FLAnimatedImageView alloc]init];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    
    NSURL *imgURL = videoInfo.posterURL;
    CGFloat width = videoInfo.resolutionInfo[0].size.width;
    CGFloat height = videoInfo.resolutionInfo[0].size.height;
    
    long viewHeight = height * CGRectGetWidth(self.contentView.frame) / width ;
    
    if (viewHeight > SCREEN_HEIGHT) {
        viewHeight = SCREEN_HEIGHT;
    }
    
    imgView.backgroundColor = [UIColor lightGrayColor];
    
    [imgView sd_setImageWithURL:imgURL];
    [imgView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), viewHeight)];
    
    [self.contentView addSubview:imgView];
    
//    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImageView *playImgView = [[UIImageView alloc] init];
    [playImgView setImage:[UIImage imageNamed:@"video_play"]];
//    [playBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    playImgView.frame = CGRectMake(0, 0, playImgView.image.size.width, playImgView.image.size.height);
    playImgView.center = imgView.center;
    
    [self.contentView addSubview:playImgView];
    
}

- (void)setContentText:(NSString*)text{
    
    UILabel *content = [[UILabel alloc] initWithFrame:self.bounds];
    content.text = text;
    content.numberOfLines = 0;
//    content.clipsToBounds = YES;
    [self.contentView addSubview:content];
}

- (void)setImgDicArr:(NSArray *)imgDicArr
{
    
//    BTWeakSelf(weakSelf);
    long y = 0;
    for (int i = 0; i < imgDicArr.count; i++) {
        NSDictionary *imageDic = [imgDicArr objectAtIndex:i];
        
//        UIImageView *imgView = [[UIImageView alloc] init];
//        imgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        FLAnimatedImageView *imgView = [[FLAnimatedImageView alloc]init];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
//        imgView.clipsToBounds = YES;
//        imgView.layer.masksToBounds = YES;
        
        NSString *imgURL = [imageDic objectForKey:@"url"];
        NSNumber *width = [imageDic objectForKey:@"width"];
        NSNumber *height = [imageDic objectForKey:@"height"];
        
        long viewHeight = [height longValue] * CGRectGetWidth(self.contentView.frame) / [width longValue] ;
    
        if (viewHeight > SCREEN_HEIGHT) {
            viewHeight = SCREEN_HEIGHT;
        }
        
        imgView.backgroundColor = [UIColor lightGrayColor];
//        imgView.backgroundColor = [UIColor colorWithRed:0.3 green:i/imgDicArr.count blue:0.5 alpha:1];
        
//        if (![[NSURL URLWithString:imgURL].lastPathComponent.lowercaseString isEqualToString:@"gif"]) {
//            [imgView sd_setImageWithURL:[NSURL URLWithString:imgURL]];
//        }else{
//
//        }
        
        [imgView sd_setImageWithURL:[NSURL URLWithString:imgURL]];
        [imgView setFrame:CGRectMake(0, y, CGRectGetWidth(self.contentView.frame), viewHeight)];
        
        y += viewHeight;
        
        [self.contentView addSubview:imgView];
    }
}


@end
