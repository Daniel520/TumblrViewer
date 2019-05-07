//
//  BTPost.h
//  TumblrViewer
//
//  Created by jingda yu on 2019/5/7.
//  Copyright © 2019 jingda yu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    DBPhoto = 0,
    DBText,
    DBVideo
} Dashboad_Type;

NS_ASSUME_NONNULL_BEGIN

@interface BTPost : NSObject

@property (nonatomic, assign) Dashboad_Type type;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *imgURLs;
@property (nonatomic, strong) NSArray *videoURLs;

//HTML body source
@property (nonatomic, strong) NSString *contentBody;

@end

NS_ASSUME_NONNULL_END
