//
//  XBTableViewCell.m
//  07-断点下载
//
//  Created by xshenpan on 16/5/25.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "XBTableViewCell.h"
#import "XBDownloadTaskInfo.h"

@interface XBTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *progress;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@end

@implementation XBTableViewCell

- (void)setInfo:(XBDownloadTaskInfo *)info
{
    _info = info;
    
    NSString *status = nil;
    switch (info.status) {
        case XBDownloadTaskStatusWaiting:
            status = @"等待下载";
            break;
        case XBDownloadTaskStatusPause:
            status = @"暂停";
            break;
        case XBDownloadTaskStatusRunning:
            status = @"正在下载";
            break;
        case XBDownloadTaskStatusError:
            status = @"下载错误";
            break;
        default:
            break;
    }
    
    UIImage *img = nil;
    NSString *extension = [info.name pathExtension];

    if ([extension compare:@"mp4" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        img = [UIImage imageNamed:@"mp4"];
    }else if ([extension compare:@"mp3" options:NSCaseInsensitiveSearch] == NSOrderedSame){
        img = [UIImage imageNamed:@"mp3"];
    }else if ([extension compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame){
        img = [UIImage imageNamed:@"zip"];
    }else{
        img = [UIImage imageNamed:@"file"];
    }

    self.icon.image = img;
    self.status.text = status;
    self.name.text = info.name;
    self.progress.text = [NSString stringWithFormat:@"%.2f%%", info.progress*100];
    self.fileSizeLabel.text = [NSString stringWithFormat:@"%.1fM", info.filesize*1.0/1024/1024];
    self.speedLabel.text = [NSString stringWithFormat:@"%.1fKB/s", info.speed];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString * const ID = @"cell";
    XBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
    }
    
    return cell;
}

@end
