//
//  UIColor+Tools.m
//  绘制图表
//
//  Created by 小果 on 16-8-5.
//  Copyright (c) 2016年 itcast. All rights reserved.
//

#import "UIColor+Tools.h"

@implementation UIColor (Tools)
    
+ (instancetype)xg_randomColor {
    return [UIColor xg_colorWithRed:arc4random_uniform(256) green:arc4random_uniform(256) blue:arc4random_uniform(256)];
}

+ (instancetype)xg_colorWithHex:(uint32_t)hex {
    
    uint8_t r = (hex & 0xff0000) >> 16;
    uint8_t g = (hex & 0x00ff00) >> 8;
    uint8_t b = hex & 0x0000ff;
    
    return [self xg_colorWithRed:r green:g blue:b];
}
    
    
+ (instancetype)xg_colorWithRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue {
    return [UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0];
}


@end
