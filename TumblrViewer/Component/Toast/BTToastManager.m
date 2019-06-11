//
//  BTToastManager.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/10.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTToastManager.h"
#import "BTToastWindow.h"
#import "BTToastViewController.h"

//最少显示多少秒，再显示下一个toast
#define SHOW_TOAST_MIN_SEC 1

//toast正常 出现|消失 动画的时间
#define TOAST_IN_OUT_ANIMATION_TIME 0.45

//toast快速消失的动画时间，例如用户向上推，关闭toast
#define TOAST_FAST_OUT_ANIMATION_TIME 0.2

#define TOAST_HEIGHT (iOS11SafeAreaInsets().top + 44)

@interface BTToastManager ()
{
    CGFloat     windowWidth;
}

@property (nonatomic,strong) NSMutableArray *waitingToastQueue;
@property (nonatomic,strong) NSMutableArray *showingToastQueue;

@property (nonatomic,strong) BTToastWindow *toastWindow;

@end

@implementation BTToastManager

+(instancetype)sharedToastManager
{
    static BTToastManager *_sharedObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedObj = [[BTToastManager alloc] init];
    });
    
    return _sharedObj;
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        self.waitingToastQueue = [NSMutableArray array];
        self.showingToastQueue = [NSMutableArray array];
        
        self.toastWindow = [[BTToastWindow alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.toastWindow.windowLevel = UIWindowLevelStatusBar - 3;
        self.toastWindow.backgroundColor = [UIColor clearColor];
        self.toastWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateViewOrientation:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  将一个 toastInfo 对象加入显示队列中
 */
-(void)addToast:(BTToastInfo*)toast
{
    //对toast的所有操作，都丢到主线程来保证线程安全
    dispatch_async(dispatch_get_main_queue(), ^{
        
        toast.state = BTToastStateWaiting;
        
        [self.waitingToastQueue addObject:toast];
        
        [self tryShowToast];
    });
}

/**
 *  尝试显示下一个toast
 */
-(void)tryShowToast
{
    if (!self.showingToastQueue.lastObject || [self isToastShowedEnoughAndCanShowNext:self.showingToastQueue.lastObject])
    {
        [self showToast];
    }
}

/**
 *  从等待队列中取出一个toast来显示
 */
-(void)showToast
{
    BTToastInfo *toast = self.waitingToastQueue.firstObject;
    if (toast)
    {
        CGFloat width = SCREEN_WIDTH;
        if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait)
        {
            width = SCREEN_HEIGHT;
        }
        
        CGFloat toastX;
        CGFloat toastY;
        CGFloat toastW;
        CGFloat toaseH;
        
        CGFloat animotionDuration = TOAST_IN_OUT_ANIMATION_TIME;
        
        CGFloat duration;
        CGFloat delayTime = 0;
        
        toastX = 0;
        toastY = 0;
        toastW = width;
        toaseH = TOAST_HEIGHT;
        duration = 3.0;
        
        BTToastView *toastView = [[BTToastView alloc] initWithFrame:CGRectMake(toastX, -(toastY + toaseH), toastW, toaseH)];
        toastView.toastInfo = toast;
        
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureFrom:)];
        [toastView addGestureRecognizer:gestureRecognizer];
        
        [self.toastWindow addSubview:toastView];
        self.toastWindow.hidden = NO;
        
        [self updateViewOrientation:nil];
        
        [self.showingToastQueue addObject:toast];
        [self.waitingToastQueue removeObject:toast];
        
        toast.state = BTToastStateEntering;
        
        [UIView animateWithDuration:animotionDuration delay:delayTime options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            [toastView setFrame:CGRectMake(toastX, toastY, toastW, toaseH)];
            
        } completion:^(BOOL finished) {
            
            toast.state = BTToastStateShowing;
            toast.showedTime = [[NSDate date] timeIntervalSince1970];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SHOW_TOAST_MIN_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self tryShowToast];
            });
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if (toast && toast.state == BTToastStateShowing)
                {
                    toast.state = BTToastStateExiting;
                    [UIView animateWithDuration:animotionDuration delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                        
                        [toastView setFrame:CGRectMake(toastX, -(toaseH + toastY), toastW, toaseH)];
                        
                    } completion:^(BOOL finished1) {
                        
                        toast.state = BTToastStateCompleted;
                        [self.showingToastQueue removeObject:toast];
                        [toastView removeFromSuperview];
                        
                        if(self.showingToastQueue.count == 0)
                        {
                            self.toastWindow.hidden = YES;
                        }
                    }];
                }
            });
        }];
    }
}

/**
 *  判断入参的toast，是否已经显示了足够长时间，是否可以显示下一个toast
 */
-(BOOL)isToastShowedEnoughAndCanShowNext:(BTToastInfo*)toast
{
    //目前的条件是：toast至少显示 1s，再显示下一个
    if ((toast.state == BTToastStateShowing || toast.state == BTToastStateExiting || toast.state == BTToastStateCompleted) && [[NSDate date] timeIntervalSince1970] - toast.showedTime >= SHOW_TOAST_MIN_SEC)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


/**
 Toast向上滑动消失

 @param recognizer 滑动手势
 */
-(void)handlePanGestureFrom:(UIPanGestureRecognizer*)recognizer
{
    if ([recognizer velocityInView:recognizer.view].y < -200)
    {
        for (UIView *view in self.toastWindow.subviews)
        {
            if ([view isKindOfClass:[BTToastView class]])
            {
                BTToastView *toastView = (BTToastView *)view;
                if (toastView.toastInfo.state == BTToastStateShowing)
                {
                    toastView.toastInfo.state = BTToastStateExiting;
                    for (UIGestureRecognizer *gesture in toastView.gestureRecognizers)
                    {
                        [toastView removeGestureRecognizer:gesture];
                    }
                    
                    [UIView animateWithDuration:TOAST_FAST_OUT_ANIMATION_TIME delay:0 options:UIViewAnimationCurveEaseOut animations:^{
                        
                        [toastView setFrame:CGRectMake(toastView.frame.origin.x, -(toastView.frame.origin.y + toastView.frame.size.height), toastView.frame.size.width, toastView.frame.size.height)];
                    } completion:^(BOOL finished1) {
                        
                        toastView.toastInfo.state = BTToastStateCompleted;
                        [self.showingToastQueue removeObject:toastView.toastInfo];
                        [toastView removeFromSuperview];
                        
                        if(self.showingToastQueue.count == 0)
                        {
                            self.toastWindow.hidden = YES;
                        }
                    }];
                }
            }
        }
    }
}

/**
 *  旋转视图,修改toastView的frame
 */
- (void)updateViewOrientation:(NSNotification*)notification;
{
    UIInterfaceOrientation orientationTo = [UIApplication sharedApplication].statusBarOrientation;
    
    if (orientationTo == UIInterfaceOrientationPortrait)
    {
        self.toastWindow.transform = CGAffineTransformMakeRotation(0);
        self.toastWindow.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    else if(orientationTo == UIInterfaceOrientationLandscapeRight)
    {
        self.toastWindow.transform = CGAffineTransformMakeRotation(M_PI/2.0);
        self.toastWindow.bounds = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
    }
    else if(orientationTo == UIInterfaceOrientationLandscapeLeft)
    {
        self.toastWindow.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
        self.toastWindow.bounds = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
    }
    
    for (UIView *view in self.toastWindow.subviews)
    {
        if ([view isKindOfClass:[BTToastView class]])
        {
            BTToastView *toastView = (BTToastView *)view;
            
            CGFloat width = SCREEN_WIDTH;
            if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait)
            {
                width = SCREEN_HEIGHT;
            }
            
            
            [toastView setFrame:CGRectMake(0, toastView.frame.origin.y, width, toastView.frame.size.height)];
            
        }
    }
}

#pragma mark - convenience function
/**
 *  显示一个带有图片和文字的toast
 */
+(BTToastInfo*)showToastWithImage:(UIImage*)image text:(NSString*)text
{
    BTToastInfo *toast = [[BTToastInfo alloc] init];
    toast.image = image;
    toast.text = text;
    [[BTToastManager sharedToastManager] addToast:toast];
    
    return toast;
}


/**
 *  显示一个带有图片和文字的toast
 */
+(BTToastInfo*)showToastWithImage:(UIImage*)image text:(NSString*)text type:(AlertType)type
{
    BTToastInfo *toast = [[BTToastInfo alloc] init];
    toast.image = image;
    toast.text = text;
    toast.type = type;
    [[BTToastManager sharedToastManager] addToast:toast];
    
    return toast;
}


/**
 *  显示一个只有文字的toast
 */
+(BTToastInfo*)showToastWithText:(NSString*)text
{
    return [self showToastWithImage:nil text:text];
}

@end
