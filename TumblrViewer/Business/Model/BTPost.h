//
//  BTPost.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/5/7.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//post common
//#define INFO_URL @"url"

#define BT_TYPE @"type"
#define TYPE_TEXT @"text"
#define TYPE_PHOTO @"photo"
#define TYPE_VIDEO @"video"

////video
//#define VIDEO_POSTER @"poster"
//#define FILE_TYPE @"type"
//
////image
//#define IMAGE_HEIGHT @"height"
//#define IMAGE_WIDTH @"width"
//#define ALT_SIZES @"alt_sizes"
//#define ORI_SIZES @"original_size"

typedef enum
{
    DBPhoto = 0,
    DBText,
    DBVideo
} Dashboad_Type;

NS_ASSUME_NONNULL_BEGIN

@interface BTResInfo : NSObject

@property (nonatomic, strong) NSURL *resUrl;

@property (nonatomic, assign) CGSize size;

@end

@interface BTImageInfo : NSObject

@property (nonatomic, strong) BTResInfo *originResInfo;

@property (nonatomic, strong) NSArray<BTResInfo*> *imageResArr;

//@property (nonatomic) CGSize currentSzie;

//@property (nonatomic, strong) NSString *imageMD5;

@end

@interface BTVideoInfo : NSObject

@property (nonatomic, strong) NSArray<BTResInfo*> *resolutionInfo;
@property (nonatomic, strong) NSString *fileType;
@property (nonatomic, strong) NSURL *posterURL;
@property (nonatomic, strong) NSURL *originVideoURL;
//@property (nonatomic, assign) NSTimeInterval duration;

@end


@interface BTPost : NSObject

@property (nonatomic, assign) Dashboad_Type type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) BTImageInfo *imageInfo;
@property (nonatomic, strong) BTVideoInfo *videoInfo;

//test
@property (nonatomic, strong) NSArray *imgURLs;
@property (nonatomic, strong) NSArray *videoURLs;

//HTML body source
@property (nonatomic, strong) NSString *contentBody;

#warning todo implement translate logic
+ (BTPost*)translatePostDic:(NSDictionary*)postDic;

@end

NS_ASSUME_NONNULL_END
