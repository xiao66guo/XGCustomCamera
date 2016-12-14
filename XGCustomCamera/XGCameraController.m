//
//  XGCameraController.m
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/6.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import "XGSwitchColorController.h"
#import "XGSwitchFontSizeController.h"
#define XGSavePictureAnimationDuration 0.8
#define XGCameraSubViewMargin 8
@interface XGCameraController ()<UIPopoverPresentationControllerDelegate>
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
    // 保存照片提示文字
    UILabel                     *_saveTipLable;
    // 拍照按钮
    UIButton                    *_patPicBtn;
    // 分享和尽头旋转按钮
    UIButton                    *_rotateShare;
    // 拍照完成的照片
    UIImage                     *_captureDonePicture;
    // 签名按钮
    UIButton                    *_signatureBtn;
    // 字体颜色选择按钮
    UIButton                    *_fontColorBtn;
    // 字体大小选择按钮
    UIButton                    *_fontSizeBtn;
    // 记录颜色选择
    UIColor                     *_popSwitchFontColor;
    // 记录字体选择的大小
    NSInteger                   textSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    
    // 布局相机底部的按钮
    [self xg_layoutCameraBottomWithBtn];
    
    // 添加水印图片
    [self xg_addWaterMarkPictureAndText];
    
    // 添加照片保存后的提示文字
    [self xg_addSavePictureTipMessage];
    
    // 设置拍摄会话
    [self xg_setupCaptureSession];
}

/******************************自定义相机及相关控件的响应方法******************************/
#pragma mark - 开始拍摄
-(void)xg_startCapture{
    [_captureSession startRunning];
}

#pragma mark - 停止拍摄
-(void)xg_stopCapture{
    [_captureSession stopRunning];
}

#pragma mark - 设置拍摄的会话内容
-(void)xg_setupCaptureSession{
    
    AVCaptureDevice *device = [self xg_captureChangeDevice];
    
    _inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    
    _imageOutPut = AVCaptureStillImageOutput.new;
    _captureSession = AVCaptureSession.new;
    
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
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    _previewLayer.frame = _previewView.frame;
    
    [_previewView.layer addSublayer:_previewLayer];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self xg_startCapture];
}

#pragma mark - 切换摄像头(如果_inputDevice没有值，默认返回后置摄像头）
-(AVCaptureDevice *)xg_captureChangeDevice{
    AVCaptureDevicePosition position = _inputDevice.device.position;
    
    position = (position != AVCaptureDevicePositionBack) ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
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
-(void)xg_switchCapture{
    if (!_captureSession.isRunning) {
        [self xg_setupSharePicture];
        return;
    }
    
    AVCaptureDevice *device = [self xg_captureChangeDevice];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    [self xg_stopCapture];
    
    [_captureSession removeInput:_inputDevice];
    if ([_captureSession canAddInput:input]) {
        _inputDevice = input;
    }
    [_captureSession addInput:_inputDevice];
    [self xg_startCapture];
}

#pragma mark - 分享照片的方法
-(void)xg_setupSharePicture{
    if (nil == _captureDonePicture) {
        return;
    }
    //1、创建分享图片的数组
    NSArray *imageArray = @[_captureDonePicture];
   
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"分享内容"
                                         images:imageArray
                                            url:[NSURL URLWithString:@"http://www.code4app.com/home.php?mod=space&uid=826368"]
                                          title:@"分享标题"
                                           type:SSDKContentTypeAuto];
    //2、分享（可以弹出我们的分享菜单和编辑界面）
    [ShareSDK showShareActionSheet:nil
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                    
                   switch (state) {
                       case SSDKResponseStateSuccess:
                       {
                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                               message:nil
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil];
                           [alertView show];
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                           message:[NSString stringWithFormat:@"%@",error]
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil, nil];
                           [alert show];
                           break;
                       }
                       default:
                           break;
                   }
               }
     ];
}

#pragma mark - 设置拍照按钮的执行方法（拍照和保存）
-(void)xg_captureWithPicture{

    [self xg_patPicBtnWithAnimation];
    AVCaptureConnection *capCon = _imageOutPut.connections.firstObject;
    if (capCon == nil) {
        NSLog(@"无法连接到摄像头");
        return;
    }
    [_imageOutPut captureStillImageAsynchronouslyFromConnection:capCon completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            NSLog(@"图像缓冲区中没有图像");
            return ;
        }
        NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        
        UIImage *image = [UIImage imageWithData:data];
        CGRect rect = _previewView.bounds;
        CGFloat offset = (self.view.height - rect.size.height) * 0.5;
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        [image drawInRect:CGRectInset(rect, 0, -offset)];
        [_waterPicture.image drawInRect:_waterPicture.frame];
        if (textSize != 0 || _popSwitchFontColor != nil) {
            NSMutableAttributedString *waterText = [[NSMutableAttributedString alloc] initWithString:_waterLable.text];
            NSRange range = NSMakeRange(0, waterText.length);
            if (textSize != 0) {
                [waterText addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:textSize]} range:range];
            }
            if (_popSwitchFontColor != nil) {
                [waterText addAttributes:@{NSForegroundColorAttributeName:_popSwitchFontColor} range:range];
            }
            [waterText drawInRect:_waterLable.frame];
        }else{
            [_waterLable.attributedText drawInRect:_waterLable.frame];
        }
        
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageWriteToSavedPhotosAlbum(resultImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }];

}

#pragma mark - 拍照按钮动画方法
-(void)xg_patPicBtnWithAnimation{
    BOOL emptyTitle = (_patPicBtn.currentTitle == nil);
    NSString *title = emptyTitle ? @"✓" : nil;
    [_patPicBtn setTitle:title forState:UIControlStateNormal];
    
    [UIView transitionWithView:_patPicBtn duration:XGSavePictureAnimationDuration options:UIViewAnimationOptionTransitionFlipFromRight animations:nil completion:^(BOOL finished) {
        if (nil == title) {
            [self xg_startCapture];
        }
    }];
    
    NSString *roShareIcon = emptyTitle ? @"pic_share" : @"camera_change";
    [_rotateShare setImage:[UIImage imageNamed:roShareIcon] forState:UIControlStateNormal];
    NSString *pressImage = [NSString stringWithFormat:@"%@_pressed",roShareIcon];
    [_rotateShare setImage:[UIImage imageNamed:pressImage] forState:UIControlStateHighlighted];
    [UIView transitionWithView:_rotateShare duration:XGSavePictureAnimationDuration options:UIViewAnimationOptionTransitionFlipFromLeft animations:nil completion:nil];
    
    _signatureBtn.enabled = !emptyTitle;
    _signatureBtn.backgroundColor = emptyTitle ? UIColor.lightGrayColor : UIColor.whiteColor;
    _signatureBtn.layer.borderColor = emptyTitle ? UIColor.lightGrayColor.CGColor : UIColor.greenColor.CGColor;
    _fontColorBtn.enabled = !emptyTitle;
    _fontSizeBtn.enabled = !emptyTitle;
}

#pragma mark - 保存照片后的回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *msg = (error == nil) ? @"照片保存成功🎁" : @"照片保存失败💔";
    _saveTipLable.text = msg;
    
    [self xg_stopCapture];
    
    [UIView animateWithDuration:XGSavePictureAnimationDuration delay:0.5 options:0 animations:^{
        _saveTipLable.alpha = 1.0;
    } completion:^(BOOL finished) {
       [UIView animateWithDuration:XGSavePictureAnimationDuration animations:^{
           _saveTipLable.alpha = 0.0;
       }];
    }];
    _captureDonePicture = image;
}

#pragma mark - 设置签名的方法
-(void)xg_setupSignature{
    // 签名弹框
    UIAlertController *tipView = [UIAlertController alertControllerWithTitle:@"个性签名" message:@"请输入您要签名的内容" preferredStyle:UIAlertControllerStyleAlert];
    // 向弹框中添加输入框
    [tipView addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.placeholder = @"请输入您要签名的内容";
    }];
    // 取消操作
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [tipView addAction:cancel];
    // 确认操作
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 取出弹框中的textField
        UITextField *textContent = [tipView textFields][0];
        // 取出textField中的内容
        NSString *sigContent = textContent.text;
        _waterLable.text = sigContent;
        _waterLable.textAlignment = _waterLable.text.length >= 15? NSTextAlignmentLeft : NSTextAlignmentCenter;
    }];
    // 将确认按钮添加到弹框
    [tipView addAction:sure];
    
    // 让弹框显示
    [self presentViewController:tipView animated:YES completion:nil];
}

#pragma mark - 改变签名文字的颜色
-(void)xg_addChangeSignWithFontColor:(UIButton *)sender{
    XGSwitchColorController *switchColor = XGSwitchColorController.new;
    switchColor.xg_BgColor = ^(UIColor *cellColor){
        _waterLable.textColor = cellColor;
        _popSwitchFontColor = cellColor;
    };
    [self xg_setupPopViewWithAttribute:switchColor andView:sender];
}

#pragma mark - 改变签名字体的大小
-(void)xg_changeSignatureWithFontSize:(UIButton *)sender{
    XGSwitchFontSizeController *switchSize = XGSwitchFontSizeController.new;
    switchSize.xg_FontSize = ^(NSInteger fontSize){
        _waterLable.font = [UIFont systemFontOfSize:fontSize];
        textSize = fontSize;
    };
    [self xg_setupPopViewWithAttribute:switchSize andView:sender];
}

#pragma mark - pop展现视图的公共方法
-(void)xg_setupPopViewWithAttribute:(UIViewController *)vc andView:(UIView *)view{
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.preferredContentSize = CGSizeMake(60, 200);
    vc.popoverPresentationController.delegate = self;
    vc.popoverPresentationController.sourceView = view;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    
    CGSize size = view.bounds.size;
    vc.popoverPresentationController.sourceRect = CGRectMake(size.width * 0.5, -5, 0, 0);
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 不使用系统默认的方式展现
-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}

/******************************自定义相机及相关控件的响应方法******************************/

/******************************界面中的控件布局******************************/
#pragma mark - 布局相机底部的按钮
-(void)xg_layoutCameraBottomWithBtn{
    // 预览视图
    UIView *previewView = UIView.new;
    previewView.backgroundColor = UIColor.whiteColor;
    previewView.frame = CGRectMake(0, 0, ScreenW, ScreenH * 0.8);
    [self.view addSubview:previewView];
    _previewView = previewView;
    
    // 拍照按钮
    UIButton *patPic = UIButton.new;
    patPic.titleLabel.font = [UIFont boldSystemFontOfSize:40];
    UIImage *patPicImage = [UIImage imageNamed:@"camera_pat"];
    [patPic setBackgroundImage:patPicImage forState:UIControlStateNormal];
    CGFloat patPicW = patPicImage.size.width;
    CGFloat patPicH = patPicImage.size.height;
    patPic.frame = CGRectMake((ScreenW - patPicW)* 0.5, ScreenH - patPicH - 20, patPicW, patPicH);
    [self.view addSubview:patPic];
    _patPicBtn = patPic;
    [patPic addTarget:self action:@selector(xg_captureWithPicture) forControlEvents:UIControlEventTouchUpInside];
    
    // 关闭按钮
    UIButton *closeBtn = UIButton.new;
    UIImage *closeImage = [UIImage imageNamed:@"camera_close"];
    [closeBtn setImage:closeImage forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"camera_close_pressed"] forState:UIControlStateHighlighted];
    CGFloat closeBtnW = closeImage.size.width;
    CGFloat closeBtnH = closeImage.size.height;
    CGFloat closeDetal = (patPicH - closeBtnH)* 0.5;
    closeBtn.frame = CGRectMake(XGCameraSubViewMargin, patPic.y + closeDetal, closeBtnW, closeBtnH);
    [self.view addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(xg_dissWithCameraVC) forControlEvents:UIControlEventTouchUpInside];
    
    // 镜头旋转和分享按钮
    UIButton *rotateShare = UIButton.new;
    UIImage *roShareImage = [UIImage imageNamed:@"camera_change"];
    CGFloat roShareW = roShareImage.size.width;
    CGFloat roShareH = roShareImage.size.height;
    [rotateShare setImage:roShareImage forState:UIControlStateNormal];
    rotateShare.frame = CGRectMake(ScreenW - XGCameraSubViewMargin - roShareW, closeBtn.y, roShareW, roShareH);
    [self.view addSubview:rotateShare];
    _rotateShare = rotateShare;
    [rotateShare addTarget:self action:@selector(xg_switchCapture) forControlEvents:UIControlEventTouchUpInside];
    
    // 签名按钮
    UIButton *signatureBtn = UIButton.new;
    signatureBtn.backgroundColor = UIColor.whiteColor;
    signatureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [signatureBtn setTitle:@"签  名" forState:UIControlStateNormal];
    [signatureBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    signatureBtn.frame = CGRectMake(CGRectGetMaxX(closeBtn.frame) + XGCameraSubViewMargin, closeBtn.y, 60, closeBtnH);
    signatureBtn.layer.cornerRadius = 16;
    signatureBtn.layer.borderWidth = 3;
    signatureBtn.layer.borderColor = UIColor.greenColor.CGColor;
    signatureBtn.clipsToBounds = YES;
    [self.view addSubview:signatureBtn];
    _signatureBtn = signatureBtn;
    [signatureBtn addTarget:self action:@selector(xg_setupSignature) forControlEvents:UIControlEventTouchUpInside];
    
    // 字体颜色
    UIButton *fontColorBtn = UIButton.new;
    [fontColorBtn setImage:[UIImage imageNamed:@"fontColor"] forState:UIControlStateNormal];
    fontColorBtn.frame = CGRectMake(CGRectGetMinX(rotateShare.frame)-XGCameraSubViewMargin-roShareW, rotateShare.y, roShareW, roShareH);
    [self.view addSubview:fontColorBtn];
    [fontColorBtn addTarget:self action:@selector(xg_addChangeSignWithFontColor:) forControlEvents:UIControlEventTouchUpInside];
    _fontColorBtn = fontColorBtn;
    
    // 字体大小
    UIButton *fontSizeBtn = UIButton.new;
    [fontSizeBtn setImage:[UIImage imageNamed:@"fontSize"] forState:UIControlStateNormal];
    fontSizeBtn.frame = CGRectMake(CGRectGetMinX(fontColorBtn.frame) - XGCameraSubViewMargin - fontColorBtn.width, fontColorBtn.y, fontColorBtn.width, fontColorBtn.height);
    [self.view addSubview:fontSizeBtn];
    [fontSizeBtn addTarget:self action:@selector(xg_changeSignatureWithFontSize:) forControlEvents:UIControlEventTouchUpInside];
    _fontSizeBtn = fontSizeBtn;
}

#pragma mark -为照片添加水印图片
-(void)xg_addWaterMarkPictureAndText{
    UIImageView *waterPicture = UIImageView.new;
    waterPicture.image = [UIImage imageNamed:@"water"];
    waterPicture.contentMode = 0;
    waterPicture.frame = CGRectMake(0, CGRectGetMaxY(_previewView.frame) - 80, ScreenW, 80);
    [self.view addSubview:waterPicture];
    _waterPicture = waterPicture;
    
    UILabel *waterLable = UILabel.new;
    waterLable.textAlignment = NSTextAlignmentCenter;
    waterLable.text = @"拍照之前别忘了签名哦😊";
    waterLable.textColor = UIColor.magentaColor;
    waterLable.numberOfLines = 0;
    waterLable.font = [UIFont systemFontOfSize:15];
    [waterLable sizeToFit];
    CGFloat waterLabW = ScreenW * 0.68;
    CGFloat waterLabH = 60;
    waterLable.frame = CGRectMake((ScreenW - waterLabW) *0.5, waterPicture.y + 12, waterLabW, waterLabH);
    [self.view addSubview:waterLable];
    _waterLable = waterLable;
}

#pragma mark - 添加照片保存后的提示文字
-(void)xg_addSavePictureTipMessage{
    UILabel *tipLab = [UILabel new];
    tipLab.text = @"照片保存成功🎁";
    tipLab.textColor = UIColor.whiteColor;
    tipLab.font = [UIFont boldSystemFontOfSize:16];
    [tipLab sizeToFit];
    CGFloat tipLabW = tipLab.size.width;
    CGFloat tiplabH = tipLab.size.height;
    tipLab.frame = CGRectMake((ScreenW - tipLabW) * 0.5, 70, tipLabW, tiplabH);
    tipLab.alpha = 0.0;
    [self.view addSubview:tipLab];
    _saveTipLable = tipLab;
}
/******************************界面中的控件布局******************************/

#pragma mark - 关闭相机界面
-(void)xg_dissWithCameraVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}
@end
