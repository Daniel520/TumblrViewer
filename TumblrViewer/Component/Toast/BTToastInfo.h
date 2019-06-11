//
//  BTToastInfo.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/10.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AlertType)
{
    AlertTypeInfo = 0,
    AlertTypeSuccess,
    AlertTypeAlert
};

typedef NS_ENUM(NSUInteger, BTToastState)
{
    BTToastStateWaiting,
    BTToastStateEntering,
    BTToastStateShowing,
    BTToastStateExiting,
    BTToastStateCompleted
};

@interface BTToastInfo : NSObject

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) NSString *text;

@property (atomic,assign) BTToastState state;

@property (nonatomic, assign) AlertType type;

/**
 *  toast显示出来的时间，用这个控制一个toast至少显示一段时间
 */
@property (nonatomic,assign) NSTimeInterval showedTime;

@end
