//
//  XGMainViewController.m
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/6.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGMainViewController.h"
#import "XGCameraController.h"
@interface XGMainViewController ()

@end

@implementation XGMainViewController{
    UIButton    *_openCameraBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupOpenCameraBtn];
}

#pragma mark - 添加打开相机按钮
-(void)setupOpenCameraBtn{
    _openCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    _openCameraBtn.center = self.view.center;
    [self.view addSubview:_openCameraBtn];
    [_openCameraBtn setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal];
    [_openCameraBtn addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 打开相机的方法
-(void)openCamera{
    XGCameraController *cameraVC = [XGCameraController new];
    [self presentViewController:cameraVC animated:YES completion:nil];
}
@end
