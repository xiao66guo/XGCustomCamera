//
//  XGMainViewController.m
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/6.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGMainViewController.h"

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
    _openCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    _openCameraBtn.backgroundColor = [UIColor blueColor];
    _openCameraBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _openCameraBtn.center = self.view.center;
    [self.view addSubview:_openCameraBtn];
    [_openCameraBtn setTitle:@"打开相机" forState:UIControlStateNormal];
    [_openCameraBtn addTarget:self action:@selector(openCamera) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 打开相机的方法
-(void)openCamera{
    NSLog(@"打开相机");
}
@end
