# XGCustomCamera
用完全自定义的方式来实现相机的拍照功能，并实现了在拍照前的签名、修改签名文字的大小、修改签名文字的颜色、前后摄像头的切换以及对拍完的照片进行分享等功能

项目功能介绍：

1️⃣ 用完全自定义的方式来实现相机的拍照功能；

2️⃣ 实现在拍照之前可以向照片界面添加签名效果；

3️⃣ 通过PopOver的方式来实现在签名前后可以对签名字体大小进行选择的功能；

4️⃣ 通过PopOver的方式实现在签名前后可以对签名字体颜色进行选择的功能；

5️⃣ 通过拍照是否完成来控制“签名"、“字体大小”、“字体颜色”按钮是否可用功能；

6️⃣ 通过“相机翻转”按钮来实现前后摄像头的切换功能；

7️⃣ 集成ShareSDK来实现对当前所拍的带有签名的照片进行分享的功能；

8️⃣ 通过点击“关闭”按钮来实现自定义相机的显示和隐藏功能；

9️⃣ 实现对拍完照后的照片保存到相册的功能；

🔟 对以上的功能进行了封装和抽取，可以单独使用，只需导入一个头文件进行控制的布局就可以了；

在主控制器中实现的代码：
```
//
//  XGMainViewController.m
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/6.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGMainViewController.h"
#import "XGCameraController.h"
@implementation XGMainViewController{
    UIButton    *_openCameraBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad]; 
    [self setupOpenCameraBtn];
}
-(void)setupOpenCameraBtn{
    _openCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    _openCameraBtn.center = self.view.center;
    [self.view addSubview:_openCameraBtn];
    [_openCameraBtn setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal];
    [_openCameraBtn addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside]; 
}
-(void)openCamera{
    XGCameraController *cameraVC = [XGCameraController new];
    [self presentViewController:cameraVC animated:YES completion:nil];
}
@end
```
通过PopOVer的方式实现字体大小和颜色选择的相关代码：
```
-(void)addChangeSignWithFontColor:(UIButton *)sender{
    XGSwitchColorController *switchColor = [XGSwitchColorController new];
    switchColor.bgColor = ^(UIColor *cellColor){
        _waterLable.textColor = cellColor;
        _popSwitchFontColor = cellColor;
    };
    [self setupPopViewWithAttribute:switchColor andView:sender];
}
-(void)changeSignatureWithFontSize:(UIButton *)sender{
    XGSwitchFontSizeController *switchSize = [XGSwitchFontSizeController new];
    switchSize.fontSize = ^(NSInteger fontSize){
        _waterLable.font = [UIFont systemFontOfSize:fontSize];
        textSize = fontSize;
    };
    [self setupPopViewWithAttribute:switchSize andView:sender];
}
-(void)setupPopViewWithAttribute:(UIViewController *)vc andView:(UIView *)view{
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.preferredContentSize = CGSizeMake(60, 200);
    vc.popoverPresentationController.delegate = self;
    vc.popoverPresentationController.sourceView = view;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    CGSize size = view.bounds.size;
    vc.popoverPresentationController.sourceRect = CGRectMake(size.width * 0.5, -5, 0, 0);
    [self presentViewController:vc animated:YES completion:nil];
}
```
