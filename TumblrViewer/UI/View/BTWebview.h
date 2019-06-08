//
//  BTWebview.h
//  TumblrViewer
//
//  Created by Danielyu on 2019/6/8.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTWebview : WKWebView

+ (void)registerScheme:(NSString *)scheme;
+ (void)unregisterScheme:(NSString *)scheme;

@end

NS_ASSUME_NONNULL_END
