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
        
    }
    return self;
}


- (void)setPost:(BTPost *)post
{
    if (self.contentView.subviews.count > 0) {
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (post.type == BTPhoto || post.type == BTPhotoText) {
//        [self setImgDicArr:post.imgURLs];
        [self setImageArr:post.imageInfos];
    }else if (post.type == BTText) {
        [self setContentText:post.text];
    }else if (post.type == BTVideo) {
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
    playImgView.tag = 0;
    playImgView.center = imgView.center;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [imgView addGestureRecognizer:tapGesture];
    imgView.userInteractionEnabled = YES;
    
    [self.contentView addSubview:playImgView];
    
}

- (void)setContentText:(NSString*)text{
    
    UILabel *content = [[UILabel alloc] initWithFrame:self.bounds];
    content.text = text;
    content.numberOfLines = 0;
    content.tag = 0;
    content.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [content addGestureRecognizer:tapGesture];

    [self.contentView addSubview:content];
}

- (void)setImageArr:(NSArray*)imageArr
{
//    BTWeakSelf(weakSelf);
    long y = 0;
    for (int i = 0; i < imageArr.count; i++) {
        
        BTImageInfo *imageInfo = [imageArr objectAtIndex:i];
        FLAnimatedImageView *imgView = [[FLAnimatedImageView alloc]init];
        imgView.tag = i;
//        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        
        NSURL *imgURL = nil;
        CGFloat width = 0 , height = 0;
        
        NSInteger resIndex = -1;
        
        if (imageInfo.imageResArr && imageInfo.imageResArr.count > 0) {
            resIndex = imageInfo.imageResArr.count - 2;
            //get the last - 1 res for list view to display
            BTResInfo *resInfo = [imageInfo.imageResArr objectAtIndex:resIndex];
            imgURL = resInfo.resUrl;
            width = resInfo.size.width;
            height = resInfo.size.height;
        } else {
            BTResInfo *resInfo = imageInfo.originResInfo;
            imgURL = resInfo.resUrl;
            width = resInfo.size.width;
            height = resInfo.size.height;
        }
        
        CGFloat viewWidth = CGRectGetWidth(self.contentView.frame);
        CGFloat viewHeight = height * viewWidth / width;
        
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
        
        
//        [imgView sd_setImageWithURL:imgURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL){
//
//        }];
#warning todo extend sdwebimage to support change url after retry
//        [imgView sd_setImageWithURL:imgURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL){
//            CGFloat imageRate = image.size.height / image.size.width;
//            CGFloat imageViewRate = viewHeight / viewWidth;
//
//            if (fabs(imageRate - imageViewRate) > 0.03) {
//                [imgView setFrame:CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y, viewWidth, viewHeight)];
//
//                imgView.contentMode = UIViewContentModeScaleAspectFit;
//            }
//
//        }];
        [imgView sd_setImageWithURL:imgURL];
        [imgView setFrame:CGRectMake(0, y, CGRectGetWidth(self.contentView.frame), viewHeight)];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        [imgView addGestureRecognizer:tapGesture];
        imgView.userInteractionEnabled = YES;
        
        y += viewHeight;
        
        [self.contentView addSubview:imgView];
        
        
//        if (y > SCREEN_HEIGHT) {
//        //To enhance user experience, forbide the cell height less than screen height
//            break;
//        }
    }
}

- (void)tapClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tapInCell:withIndex:)]) {
        UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer*)sender;
        NSInteger index = tapGesture.view.tag;
        [self.delegate tapInCell:self withIndex:index];
    }
}

//- (void)setImgDicArr:(NSArray *)imgDicArr
//{
//    
////    BTWeakSelf(weakSelf);
//    long y = 0;
//    for (int i = 0; i < imgDicArr.count; i++) {
//        NSDictionary *imageDic = [imgDicArr objectAtIndex:i];
//        FLAnimatedImageView *imgView = [[FLAnimatedImageView alloc]init];
//        imgView.contentMode = UIViewContentModeScaleAspectFill;
//        
//        NSString *imgURL = [imageDic objectForKey:@"url"];
//        NSNumber *width = [imageDic objectForKey:@"width"];
//        NSNumber *height = [imageDic objectForKey:@"height"];
//        
//        long viewHeight = [height longValue] * CGRectGetWidth(self.contentView.frame) / [width longValue] ;
//    
//        if (viewHeight > SCREEN_HEIGHT) {
//            viewHeight = SCREEN_HEIGHT;
//        }
//        
//        imgView.backgroundColor = [UIColor lightGrayColor];
////        imgView.backgroundColor = [UIColor colorWithRed:0.3 green:i/imgDicArr.count blue:0.5 alpha:1];
//        
////        if (![[NSURL URLWithString:imgURL].lastPathComponent.lowercaseString isEqualToString:@"gif"]) {
////            [imgView sd_setImageWithURL:[NSURL URLWithString:imgURL]];
////        }else{
////
////        }
//        
//        [imgView sd_setImageWithURL:[NSURL URLWithString:imgURL]];
//        [imgView setFrame:CGRectMake(0, y, CGRectGetWidth(self.contentView.frame), viewHeight)];
//        
//        y += viewHeight;
//        
//        [self.contentView addSubview:imgView];
//    }
//}


@end
