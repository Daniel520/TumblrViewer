//
//  BTWebview.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/6/8.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTWebview.h"
#import "NSData+Base64.h"



FOUNDATION_STATIC_INLINE Class ContextControllerClass() {
    static Class cls;
    if (!cls) {
        NSString *str = [NSString stringWithBase64EncodedString:@"YnJvd3NpbmdDb250ZXh0Q29udHJvbGxlcg=="];
//        cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
        cls = [[[WKWebView new] valueForKey:str] class];
    }
    return cls;
}

FOUNDATION_STATIC_INLINE SEL RegisterSchemeSelector() {
    NSString *str = [NSString stringWithBase64EncodedString:@"cmVnaXN0ZXJTY2hlbWVGb3JDdXN0b21Qcm90b2NvbDo="];
//    return NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    return NSSelectorFromString(str);
}

FOUNDATION_STATIC_INLINE SEL UnregisterSchemeSelector() {
//    return NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
    NSString *str = [NSString stringWithBase64EncodedString:@"dW5yZWdpc3RlclNjaGVtZUZvckN1c3RvbVByb3RvY29sOg=="];
    //    return NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    return NSSelectorFromString(str);
}

@implementation BTWebview

+ (void)registerScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    SEL sel = RegisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
        // 放弃编辑器警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}

+ (void)unregisterScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    SEL sel = UnregisterSchemeSelector();
    if ([(id)cls respondsToSelector:sel]) {
        // 放弃编辑器警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
