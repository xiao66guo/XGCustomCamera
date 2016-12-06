//
//  XGCameraController.m
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/6.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGCameraController.h"

@interface XGCameraController ()

@end

@implementation XGCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // 布局相机底部的按钮
    [self layoutCameraBottomWithBtn];
}

#pragma mark - 布局相机底部的按钮
-(void)layoutCameraBottomWithBtn{
    // 拍照按钮
    UIButton *patPic = [UIButton new];
    [patPic setTitle:@"✓" forState:UIControlStateNormal];
    patPic.titleLabel.font = [UIFont boldSystemFontOfSize:40];
    UIImage *patPicImage = [UIImage imageNamed:@"camera_pat"];
    [patPic setBackgroundImage:patPicImage forState:UIControlStateNormal];
    CGFloat patPicW = patPicImage.size.width;
    CGFloat patPicH = patPicImage.size.height;
    patPic.frame = CGRectMake((ScreenW - patPicW)* 0.5, ScreenH - patPicH - 20, patPicW, patPicH);
    [self.view addSubview:patPic];
    
    // 关闭按钮
    UIButton *closeBtn = [UIButton new];
    UIImage *closeImage = [UIImage imageNamed:@"camera_close"];
    [closeBtn setImage:closeImage forState:UIControlStateNormal];
    CGFloat closeBtnW = closeImage.size.width;
    CGFloat closeBtnH = closeImage.size.height;
    CGFloat closeDetal = (patPicH - closeBtnH)* 0.5;
    closeBtn.frame = CGRectMake(16, patPic.y + closeDetal, closeBtnW, closeBtnH);
    [self.view addSubview:closeBtn];
    
    // 镜头旋转按钮
    UIButton *camChangeBtn = [UIButton new];
    UIImage *camChangeImage = [UIImage imageNamed:@"camera_change"];
    CGFloat camChangeW = camChangeImage.size.width;
    CGFloat camChangeH = camChangeImage.size.height;
    [camChangeBtn setImage:camChangeImage forState:UIControlStateNormal];
    camChangeBtn.frame = CGRectMake(ScreenW - 16 - camChangeW, closeBtn.y, camChangeW, camChangeH);
    [self.view addSubview:camChangeBtn];
    
    // 分享按钮
    UIButton *shareBtn = [UIButton new];
    UIImage *shareImage = [UIImage imageNamed:@"pic_share"];
    [shareBtn setImage:shareImage forState:UIControlStateNormal];
    shareBtn.frame = camChangeBtn.frame;
    shareBtn.hidden = YES;
    [self.view addSubview:shareBtn];

    
    
}

#pragma mark - 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}
@end
