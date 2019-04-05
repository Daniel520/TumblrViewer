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

@interface BTImageInfo : NSObject

@property (nonatomic, strong) NSURL *imageUrl;

@property (nonatomic, strong) NSArray *imageSizeArr;

@property (nonatomic) CGSize currentSzie;

@property (nonatomic, strong) NSString *imageMD5;

@end

NS_ASSUME_NONNULL_END
