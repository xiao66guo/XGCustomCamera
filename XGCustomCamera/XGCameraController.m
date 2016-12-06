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
    AVCapturePhotoOutput   *_imageOutPut;
    // 取景视图
    AVCaptureVideoPreviewLayer  *_previewLayer;
    // 预览视图
    UIView                      *_previewView;
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
#pragma mark - 开始拍摄
-(void)startCapture{
    [_captureSession startRunning];
}
#pragma mark - 停止拍摄
-(void)stopCapture{
    [_captureSession stopRunning];
}
#pragma mark - 设置拍摄的会话内容
-(void)setupCaptureSession{
    // 摄像头的切换
    AVCaptureDevice *device = [self captureChangeDevice];
    
    // 输入设备
    _inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    
    // 输出图像
    _imageOutPut = [AVCapturePhotoOutput new];
    // 拍摄会话
    _captureSession = [AVCaptureSession new];
    
    // 将输入和输出添加到拍摄会话
    if (![_captureSession canAddInput:_inputDevice]) {
        NSLog(@"无法添加输入设备");
        return;
    }
    if (![_captureSession canAddOutput:_imageOutPut]) {
        NSLog(@"无法添加输出设备");
        return;
    }
    
    [_captureSession addInput:_inputDevice];
    [_captureSession addOutput:_imageOutPut];
    
    // 设置预览图层
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    // 指定预览图层的大小
    _previewLayer.frame = _previewView.frame;
    
    // 添加图层到预览视图
    [_previewView.layer addSublayer:_previewLayer];
    
    // 设置取景框的拉伸效果
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // 开始拍摄
    [self startCapture];
}
#pragma mark - 切换摄像头(如果_inputDevice没有值，默认返回后置摄像头）
-(AVCaptureDevice *)captureChangeDevice{
    // 获得当前输入设备的摄像头的位置
    AVCaptureDevicePosition position = _inputDevice.device.position;
    
    position = (position != AVCaptureDevicePositionBack) ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    // 设备（摄像头<视频/照片>,麦克风<音频>）,返回摄像头的数组
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //     取出后置摄像头
    AVCaptureDevice *device;
    for (AVCaptureDevice *obj in deviceArray) {
        if (obj.position == position) {
            device = obj;
            break;
        }
    }
    return device;
}
#pragma mark - 镜头切换按钮的实现方法
-(void)switchCapture{
    
    AVCaptureDevice *device = [self captureChangeDevice];
    // 创建输入设备
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    // 停止之前的输入设备
    [self stopCapture];
    
    // 删除之前的输入设备(如果要添加输入设备，需要将之前的输入设备删除，否则后面的输入设备将添加不进来)
    [_captureSession removeInput:_inputDevice];
    // 判断设备是否能被切换
    if ([_captureSession canAddInput:input]) {
        _inputDevice = input;
    }
    // 添加到会话
    [_captureSession addInput:_inputDevice];
    // 重新开启会话
    [self startCapture];
}

#pragma mark - 布局相机底部的按钮
-(void)layoutCameraBottomWithBtn{
    // 预览视图
    UIView *previewView = [UIView new];
    previewView.backgroundColor = [UIColor whiteColor];
    previewView.frame = CGRectMake(0, 0, ScreenW, ScreenH * 0.83);
    [self.view addSubview:previewView];
    _previewView = previewView;
    
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
    [camChangeBtn addTarget:self action:@selector(switchCapture) forControlEvents:UIControlEventTouchUpInside];
    
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
