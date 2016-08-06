//
//  XBTableViewCell.h
//  07-断点下载
//
//  Created by xshenpan on 16/5/25.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XBDownloadTaskInfo;

@interface XBTableViewCell : UITableViewCell

/** 模型 */
@property (nonatomic, strong) XBDownloadTaskInfo *info;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
