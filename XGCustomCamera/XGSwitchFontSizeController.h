//
//  XGSwitchFontSizeController.h
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/9.
//  Copyright © 2016年 小果. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XGSwitchFontSizeController : UIViewController
@property (nonatomic, copy) void (^fontSize)(NSInteger fontSize);
@end
