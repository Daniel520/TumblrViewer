//
//  BTUtils.m
//  TumblrViewer
//
//  Created by jingda yu on 2019/3/29.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTUtils.h"

@implementation BTUtils

+ (BOOL)isStringEmpty:(NSString*)str
{
    if (!str || [str length] == 0 || [str isEqualToString:@""]) {
        return YES;
    }

    return NO;
}

@end
