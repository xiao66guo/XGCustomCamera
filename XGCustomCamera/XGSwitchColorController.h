//
//  XGSwitchColorController.h
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/8.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGBaseController.h"

@interface XGSwitchColorController : XGBaseController
@property (nonatomic, copy) void (^xg_BgColor)(UIColor *fontColor);
@end
