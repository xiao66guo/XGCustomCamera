//
//  XGSwitchFontSizeController.h
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/9.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGBaseController.h"

@interface XGSwitchFontSizeController : XGBaseController
@property (nonatomic, copy) void (^xg_FontSize)(NSInteger fontSize);
@end
