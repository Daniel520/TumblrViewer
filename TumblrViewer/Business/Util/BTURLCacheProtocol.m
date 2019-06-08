//
//  BTURLCacheProtocol.m
//  TumblrViewer
//
//  Created by Danielyu on 2019/6/8.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import "BTURLCacheProtocol.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import <SDWebImage/NSData+ImageContentType.h>

static NSString * const hasInitKey = @"BTURLCacheProtocol";

@interface BTURLCacheProtocol ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableData *responseData;
//iOS 7 以前使用NSURLConnection
@property (nonatomic, nonnull, strong) NSURLSessionDataTask *task;

@end

@implementation BTURLCacheProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ( [request.URL.scheme isEqualToString:@"http"]
        || [request.URL.scheme isEqualToString:@"https"] )
    {
        //只处理http/https请求的图片
        if ([self IsImageUrl:request.URL.path]
            && ![NSURLProtocol propertyForKey:hasInitKey inRequest:request])
        {
            return YES;
        }
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
    //这边可用干你想干的事情。。更改地址，提取里面的请求内容，或者设置里面的请求头。。
}

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //做下标记，防止递归调用
    [NSURLProtocol setProperty:@YES forKey:hasInitKey inRequest:mutableReqeust];
    
    //查看本地是否已经缓存了图片
    NSData *data = [self GetSDWebImageCacheFromUrl:self.request.URL];
    
    if (data)
    {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL
                                                            MIMEType:[BTURLCacheProtocol contentTypeForImageData:data]
                                               expectedContentLength:data.length
                                                    textEncodingName:nil];
        [self.client URLProtocol:self
              didReceiveResponse:response
              cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else
    {
//        self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        self.task = [session dataTaskWithRequest:self.request];
        [self.task resume];
    }
}

- (void)stopLoading
{
//    [self.connection cancel];
    if (self.task != nil) {
        [self.task  cancel];
    }
}
/**
 If it's a image url

 @param urlStr <#strUrl description#>
 @return <#return value description#>
 */
+ (BOOL)IsImageUrl:(NSString*)urlStr
{
    if ([urlStr hasSuffix:@".png"] || [urlStr hasSuffix:@".jpg"] || [urlStr hasSuffix:@".jpeg"] || [urlStr hasSuffix:@".gif"])
    {
        return YES;
    }
    
    return NO;
}

- (NSData *)GetSDWebImageCacheFromUrl:(NSURL *)imageUrl
{
    NSData *data = nil;
    
    //利用SDWebImage寻找本地图片
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    data = [[SDImageCache sharedImageCache] performSelector:NSSelectorFromString(@"diskImageDataBySearchingAllPathsForKey:") withObject:key];
#pragma clang diagnostic pop
    
    return data;
}

#pragma mark NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    self.responseData = [[NSMutableData alloc] init];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSData *transData = data;
//    if ([dataTask.currentRequest.URL.absoluteString hasSuffix:@"webp"]) {
//        NSLog(@"webp---%@---替换它",dataTask.currentRequest.URL);
//        //采用 SDWebImage 的转换方法
//        transData = [self webpData:data];
//    }
    [self.responseData appendData:transData];
    [[self client] URLProtocol:self didLoadData:data];
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    }else {
        UIImage *cacheImage = [UIImage sd_imageWithData:self.responseData];
        //用SDWebImage将图片缓存
        [[SDImageCache sharedImageCache] storeImage:cacheImage forKey:[[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL] toDisk:YES completion:^{
            //do something
        }];
        [self.client URLProtocolDidFinishLoading:self];
    }
}
@end
