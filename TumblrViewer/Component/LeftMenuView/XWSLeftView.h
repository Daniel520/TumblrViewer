//
//  XWSLeftView.h
//  ElecSafely
//
//  Created by TigerNong on 2018/3/23.
//  Copyright © 2018年 Tianfu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Masonry.h"

typedef NS_ENUM(NSInteger, XWSTouchItem) {
    XWSTouchItemUserInfo = 0,
    XWSTouchItemDashboard,
    XWSTouchItemLike,
    XWSTouchItemFollows,
    XWSTouchItemDownload,
    XWSTouchItemSetupAPI,
    XWSTouchItemLogout,
    XWSTouchItemCoverView
};


@class XWSLeftView;

@protocol XWSLeftViewDelegate <NSObject>
- (void)touchLeftView:(XWSLeftView *)leftView byType:(XWSTouchItem)type;
@end

@interface XWSLeftView : UIView
@property (nonatomic, weak) id<XWSLeftViewDelegate> delegate;
/**数据显示列表**/
@property (nonatomic, strong) UITableView *tableView;
/**蒙板**/
@property (nonatomic, strong) UIView *coverView;

/*初始化并传入数据 UserInfo里面含有两个数据----acount 和 icon*/
- (instancetype)initWithFrame:(CGRect)frame withUserInfo:(NSDictionary *)userInfo;
/*开启蒙版透明度动画*/
/**
    设置alpha值
    动画是时间 duration
 **/
- (void)startCoverViewOpacityWithAlpha:(CGFloat)alpha withDuration:(CGFloat)duration;
/*取消门板透明度动画*/
- (void)cancelCoverViewOpacity;
@end
