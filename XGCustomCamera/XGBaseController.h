//
//  XGBaseController.h
//  XGCustomCamera
//
//  Created by 小果 on 2016/12/14.
//  Copyright © 2016年 小果. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XGBaseController : UIViewController<UITableViewDataSource,UITableViewDelegate>
/**
 *  表格属性
 */
@property (nonatomic, weak) UITableView *tableView;
/**
 *  设置界面
 */
-(void)setupUI;


@end
