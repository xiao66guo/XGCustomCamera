//
//  XGBaseController.m
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/14.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGBaseController.h"

@interface XGBaseController ()

@end

@implementation XGBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *table = UITableView.new;
    table.dataSource = self;
    table.delegate = self;
    table.showsVerticalScrollIndicator = NO;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.frame = CGRectMake(0, 0, 60, 200);
    [self.view addSubview:table];
    self.tableView = table;
    [self setupUI];
}

#pragma mark - 设置界面
-(void)setupUI{
    
}
@end
