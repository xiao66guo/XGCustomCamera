//
//  XGCameraController.m
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/6.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGCameraController.h"
#import <AVFoundation/AVFoundation.h>
@interface XGCameraController ()

@end

@implementation XGCameraController{
    // 拍摄会话
    AVCaptureSession            *_captureSession;
    // 输入设备 - 摄像头
    AVCaptureDeviceInput        *_inputDevice;
    // 图像输出
    AVCaptureStillImageOutput   *_imageOutPut;
    // 取景视图
    AVCaptureVideoPreviewLayer  *_previewLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // 布局相机底部的按钮
    [self layoutCameraBottomWithBtn];
    
    // 设置拍摄会话
    [self setupCaptureSession];
}
#pragma mark - 相机的拍摄方法
#pragma mark - 设置拍摄的会话内容
-(void)setupCaptureSession{
    // 设备（摄像头<视频/照片>,麦克风<音频>）,返回摄像头的数组
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
//     取出后置摄像头
    AVCaptureDevice *device;
    for (AVCaptureDevice *obj in deviceArray) {
        if (obj.position == AVCaptureDevicePositionBack) {
            device = obj;
            break;
        }
    }
    _inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
}

#pragma mark - 布局相机底部的按钮
-(void)layoutCameraBottomWithBtn{
    UIView *topView = [UIView new];
    topView.backgroundColor = [UIColor whiteColor];
    topView.frame = CGRectMake(0, 0, ScreenW, ScreenH * 0.85);
    [self.view addSubview:topView];
    
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
    [closeBtn addTarget:self action:@selector(dissWithCameraVC) forControlEvents:UIControlEventTouchUpInside];
    
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

#pragma mark - 关闭相机界面
-(void)dissWithCameraVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}
@end
