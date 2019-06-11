//
//  BTToastViewControllerContainerView.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/6/10.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTToastViewControllerContainerView.h"

@implementation BTToastViewControllerContainerView

/**
 *  将点击传递到后面去，自己本身不处理点击
 */
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01)
    {
        return nil;
    }
    
    if ([self pointInside:point withEvent:event])
    {
        for (UIView *subview in [self subviews])
        {
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            
            if (hitTestView)
            {
                return hitTestView;
            }
        }
        
        //        return self;
    }
    
    return nil;
}

@end
