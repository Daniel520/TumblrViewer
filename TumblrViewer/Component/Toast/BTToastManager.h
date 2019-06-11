//
//  BTToastManager.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/10.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTToastInfo.h"
#import "BTToastView.h"

@interface BTToastManager : NSObject

+(instancetype)sharedToastManager;

/**
 *  显示一个带有图片和文字的toast
 */
+(BTToastInfo*)showToastWithImage:(UIImage*)image text:(NSString*)text;

/**
 *  显示一个只有文字的toast
 */
+(BTToastInfo*)showToastWithText:(NSString*)text;

/**
 *  将一个 toastInfo 对象加入显示队列中
 */
-(void)addToast:(BTToastInfo*)toast;


+(BTToastInfo*)showToastWithImage:(UIImage*)image text:(NSString*)text type:(AlertType)type;

@end
