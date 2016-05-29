//
//  ViewController.m
//  07-断点下载
//
//  Created by xshenpan on 16/5/20.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "ViewController.h"
#import "XBDownloadManager.h"
#import "XBDownloadTaskInfo.h"
#import "XBTableViewCell.h"

#define url1 @"http://192.168.1.102:8000/00.zip"
#define url2 @"http://192.168.1.102:8000/02.zip"
#define url3 @"http://192.168.1.102:8000/03.zip"
#define url4 @"http://192.168.1.102:8000/04.zip"
#define url5 @"http://192.168.1.102:8000/05.zip"
#define url6 @"http://192.168.1.102:8000/06.zip"
#define url7 @"http://192.168.1.102:8000/07.zip"
#define url8 @"http://192.168.1.102:8000/08.zip"
#define url9 @"http://192.168.1.102:8000/09.zip"
#define url10 @"http://192.168.1.102:8000/10.zip"
//#define url1 @"http://120.25.226.186:32812/resources/images/minion_05.png"
//#define url2 @"http://120.25.226.186:32812/resources/images/minion_06.png"
//#define url3 @"http://120.25.226.186:32812/resources/images/minion_07.png"
//#define url4 @"http://120.25.226.186:32812/resources/images/minion_08.png"
//#define url5 @"http://120.25.226.186:32812/resources/images/minion_09.png"

//#define url1 @"http://192.168.1.102:8000/01.mp3"
//#define url2 @"http://192.168.1.102:8000/02.mp3"
//#define url3 @"http://192.168.1.102:8000/03.mp3"
//#define url4 @"http://192.168.1.102:8000/04.mp3"
//#define url5 @"http://192.168.1.102:8000/05.mp3"
//#define url6 @"http://192.168.1.102:8000/06.mp3"
//#define url7 @"http://192.168.1.102:8000/07.mp3"
//#define url8 @"http://192.168.1.102:8000/08.mp3"
//#define url9 @"http://192.168.1.102:8000/09.mp3"
//#define url10 @"http://192.168.1.102:8000/10.mp3"
#define url11 @"http://192.168.1.102:8000/11.mp3"
#define url12 @"http://192.168.1.102:8000/12.mp3"
#define url13 @"http://192.168.1.102:8000/13.mp3"
#define url14 @"http://192.168.1.102:8000/14.mp3"
#define url15 @"http://192.168.1.102:8000/15.mp3"
#define url16 @"http://192.168.1.102:8000/16.mp3"
#define url17 @"http://192.168.1.102:8000/17.mp3"
#define url18 @"http://192.168.1.102:8000/18.mp3"
#define url19 @"http://192.168.1.102:8000/19.mp3"
#define url20 @"http://192.168.1.102:8000/20.mp3"
//    [self.manager addDownloadTaskWithUrl:url1 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url3 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url5 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url7 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url9 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url11 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url13 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url15 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url17 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url19 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url2 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url4 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url6 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url8 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url10 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url12 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url14 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url16 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url18 andRelativePath:nil taskExistReload:nil];
//    [self.manager addDownloadTaskWithUrl:url20 andRelativePath:nil taskExistReload:nil];



@interface ViewController () <NSURLSessionDataDelegate, UITableViewDataSource, UITableViewDelegate, XBDownloadManagerDelegate>

@property (nonatomic, strong) XBDownloadManager *manager;
@property (nonatomic, strong) NSMutableArray<XBDownloadTaskInfo*> *cells;

@property (weak, nonatomic) IBOutlet UILabel *concurrentLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@end

@implementation ViewController

- (NSMutableArray<XBDownloadTaskInfo *> *)cells
{
    if (_cells == nil) {
        _cells = [NSMutableArray array];
    }
    return _cells;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //下载管理的界面
    //获取单利对象
    self.manager = [XBDownloadManager manager];
    [self.manager setDelegate:self andDelegateQueue:[NSOperationQueue mainQueue]];
    self.stepper.value = self.manager.maxDownloadTask;
    self.concurrentLabel.text = [NSString stringWithFormat:@"%zd", self.manager.maxDownloadTask];
}

#pragma mark - 监听按钮点击

- (IBAction)startAll:(id)sender {
    [self.manager startAllDownloadTask];
}
- (IBAction)pauseAll:(id)sender {
    [self.manager pauseAllDownloadTask];
}
- (IBAction)adjust:(UIStepper*)sender {
    self.manager.maxDownloadTask = (NSInteger)sender.value;
    self.concurrentLabel.text = [NSString stringWithFormat:@"%zd", self.manager.maxDownloadTask];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview数据源

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    XBDownloadTaskInfo *info = self.cells[indexPath.row];
    XBTableViewCell *cell = [XBTableViewCell cellWithTableView:tableView];
    cell.info = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self.manager cancelWithIndex:indexPath.row];
    }];
    return @[delete];
}

#pragma mark - tableview代理

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.manager taskInfoWithIndex:indexPath.row].status != XBDownloadTaskStatusRunning) {
        [self.manager startWithIndex:indexPath.row];
    }else{
        [self.manager pauseWithIndex:indexPath.row];
    }
}

#pragma mark - DownloadManager代理

- (void)managerAddTaskName:(NSString *)name andStatus:(XBDownloadTaskStatus)status forKey:(NSString *)key atIndex:(NSInteger)idx
{
    XBDownloadTaskInfo *info = [[XBDownloadTaskInfo alloc] init];
    info.name = name;
    info.taskKey = key;
    info.status = status;
    [self.cells addObject:info];
}

- (void)managerDeleteTaskForKey:(NSString *)key atIndex:(NSInteger)idx
{
    [self.cells removeObjectAtIndex:idx];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)managerTaskStatusChanged:(XBDownloadTaskStatus)status forKey:(NSString *)key atIndex:(NSInteger)idx
{
    XBTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
    self.cells[idx].status = status;
    cell.info = self.cells[idx];
}

- (void)managerRefreshTaskProgress:(CGFloat)progress speed:(CGFloat)speed forKey:(NSString *)key atIndex:(NSInteger)idx
{
    XBTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
    self.cells[idx].progress = progress;
    self.cells[idx].speed = speed;
    cell.info = self.cells[idx];
}

- (void)managerTaskFileLength:(NSInteger)fileLength forKey:(NSString *)key atIndex:(NSInteger)idx
{
    XBTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
    self.cells[idx].filesize = fileLength;
    cell.info = self.cells[idx];
}

- (void)managerTaskCompleteWithError:(NSError *)error forKey:(NSString *)key atIndex:(NSInteger)idx
{

}



@end
