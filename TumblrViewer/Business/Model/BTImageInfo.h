//
//  BTImageInfo.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/31.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTImageResInfo : NSObject

@property (nonatomic, strong) NSURL *resUrl;

@property (nonatomic, assign) CGSize size;

@end

@interface BTImageInfo : NSObject

@property (nonatomic, strong) BTImageResInfo *originResInfo;

@property (nonatomic, strong) NSArray<BTImageResInfo*> *imageResArr;

//@property (nonatomic) CGSize currentSzie;

//@property (nonatomic, strong) NSString *imageMD5;

@end

NS_ASSUME_NONNULL_END
