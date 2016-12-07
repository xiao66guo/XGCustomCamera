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
    // 预览视图
    UIView                      *_previewView;
    // 水印图片
    UIImageView                 *_waterPicture;
    // 水印文字
    UILabel                     *_waterLable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    // 布局相机底部的按钮
    [self layoutCameraBottomWithBtn];
    
    // 添加水印图片
    [self addWaterMarkPictureAndText];
    
    // 设置拍摄会话
    [self setupCaptureSession];
}

/******************************自定义相机的相关方法******************************/
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
    _imageOutPut = [AVCaptureStillImageOutput new];
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
    for (AVCaptureDevice *sub in deviceArray) {
        if (sub.position == position) {
            device = sub;
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

#pragma mark - 设置拍照按钮的执行方法（拍照和保存）
-(void)captureWithPicture{
    // AVCaptureConnection : 表示图像和摄像头的连接
    AVCaptureConnection *capCon = _imageOutPut.connections.firstObject;
    if (capCon == nil) {
        NSLog(@"无法连接到摄像头");
        return;
    }
    // 拍摄照片(imageDataSampleBuffer:图像数据采样缓冲区)
    [_imageOutPut captureStillImageAsynchronouslyFromConnection:capCon completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        // 判断图像缓冲区是否有数据
        if (imageDataSampleBuffer == nil) {
            NSLog(@"图像缓冲区中没有数据");
            return ;
        }
        // 从图像采样缓冲区生成照片的数据
        NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        // 生成图像
        UIImage *image = [UIImage imageWithData:data];
        
        // 将图像不在预览图层中的内容裁掉
        // 预览视图的大小
        CGRect rect = _previewView.bounds;
        // 重新计算才剪掉的大小
        CGFloat offset = (self.view.height - rect.size.height) * 0.5;
        // 通过图像上下文来裁剪图像的真实的大小
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        // 绘制图像
        [image drawInRect:CGRectInset(rect, 0, -offset)];
        // 绘制水印图像
        [_waterPicture.image drawInRect:_waterPicture.frame];
        // 绘制水印文字
        [_waterLable.attributedText drawInRect:_waterLable.frame];
        // 从图像上下文中获取绘制的结果
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        // 关闭图像上下文
        UIGraphicsEndImageContext();
        
        // 保存图像
        UIImageWriteToSavedPhotosAlbum(resultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }];
}

#pragma mark - 保存照片后的回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *msg = (error == nil) ? @"照片保存成功" : @"照片保存失败";
    NSLog(@"------%@",msg);
}

#pragma mark - 布局相机底部的按钮
-(void)layoutCameraBottomWithBtn{
    // 预览视图
    UIView *previewView = [UIView new];
    previewView.backgroundColor = [UIColor whiteColor];
    previewView.frame = CGRectMake(0, 0, ScreenW, ScreenH * 0.8);
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
    [patPic addTarget:self action:@selector(captureWithPicture) forControlEvents:UIControlEventTouchUpInside];
    
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
/******************************自定义相机的相关方法******************************/

#pragma mark -为照片添加水印图片
-(void)addWaterMarkPictureAndText{
    UIImageView *waterPicture = [UIImageView new];
    waterPicture.image = [UIImage imageNamed:@"water"];
    waterPicture.contentMode = 0;
    waterPicture.frame = CGRectMake(0, CGRectGetMaxY(_previewView.frame) - 100, ScreenW, 80);
    [self.view addSubview:waterPicture];
    _waterPicture = waterPicture;
    
    UILabel *waterLable = [UILabel new];
    waterLable.text = @"xiao66guo";
    waterLable.textColor = [UIColor magentaColor];
    waterLable.font = [UIFont boldSystemFontOfSize:25];
    [waterLable sizeToFit];
    CGFloat waterLabW = waterLable.size.width;
    CGFloat waterLabH = waterLable.size.height;
    waterLable.frame = CGRectMake((ScreenW - waterLabW) *0.5, waterPicture.y + 20, waterLabW, waterLabH);
    [self.view addSubview:waterLable];
    _waterLable = waterLable;
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
