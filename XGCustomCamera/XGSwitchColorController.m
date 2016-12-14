//
//  XGSwitchColorController.m
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/8.
//  Copyright © 2016年 小果. All rights reserved.
//

#import "XGSwitchColorController.h"
#import "UIColor+Tools.h"
@interface XGSwitchColorController ()<UITableViewDataSource,UITableViewDelegate>

@end
static NSString *ID = @"cell";
@implementation XGSwitchColorController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *table = UITableView.new;
    [table registerClass:UITableViewCell.class forCellReuseIdentifier:ID];
    table.dataSource = self;
    table.delegate = self;
    table.showsVerticalScrollIndicator = NO;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.frame = CGRectMake(0, 0, 60, 200);
    [self.view addSubview:table];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    UILabel *bgLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 40, 20)];
    bgLab.backgroundColor = UIColor.xg_randomColor;
    [cell.contentView addSubview:bgLab];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:^{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        for (UIView *bgV in cell.contentView.subviews) {
            if ([bgV isKindOfClass:[UILabel class]]) {
                _xg_BgColor(bgV.backgroundColor);
            }
        }
    }];
}
@end
