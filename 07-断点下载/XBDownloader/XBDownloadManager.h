//
//  XBDownloadManager.h
//  07-断点下载
//
//  Created by xshenpan on 16/5/20.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XBDownloadManager;
@class XBDownloadTaskInfo;

static const CGFloat kManagerProgressUpdateInterval = 0.5;    //unit : second
static NSString * const kXBDownloadManagerNotification = @"XBDownloadManagerNotification";
static NSString * const kManagerNotificationKeyTaskNumber = @"XBDownloadManagerTaskNumber";

@protocol XBDownloadManagerDelegate <NSObject>
@optional

- (void)managerTaskProgressRefresh:(XBDownloadTaskInfo *)taskInfo atIndex:(NSInteger)idx;
- (void)managerTaskList:(NSArray<XBDownloadTaskInfo *> *)taskList;
- (void)managerTaskStatusChanged:(XBDownloadTaskInfo*)taskInfo atIndex:(NSInteger)idx;
- (void)managerTask:(XBDownloadTaskInfo*)taskInfo didCompleteWithError:(NSError *)error atIndex:(NSInteger)idx;
- (void)managerTaskListChange:(XBDownloadTaskInfo*)taskInfo isDelete:(BOOL)isDelete atIndex:(NSInteger)idx;

@end

@interface XBDownloadManager : NSObject
/** 最大同时下载任务数 */
@property (nonatomic, assign) NSInteger maxDownloadTask;
/** 代理 */
@property (nonatomic, weak) id<XBDownloadManagerDelegate> delegate;
/** 任务数量 */
@property (nonatomic, assign, readonly) NSInteger taskNumber;


//控制方法
- (void)startAllDownloadTask;
- (void)pauseAllDownloadTask;
- (void)startWithIndex:(NSInteger)idx;
- (void)pauseWithIndex:(NSInteger)idx;
- (void)cancelWithIndex:(NSInteger)idx;
- (void)startWithKey:(NSString *)key;
- (void)pauseWithKey:(NSString *)key;
- (void)cancelWithKey:(NSString *)key;

//查询方法
- (XBDownloadTaskInfo *)taskInfoWithIndex:(NSInteger)idx;
- (XBDownloadTaskInfo *)taskInfoWithKey:(NSString *)key;
/** 添加一个下载任务,path=nil这默认在cache/xbdownload目录 路经以home开始 */
- (NSString *)addDownloadTaskWithUrl:(NSString *)url andRelativePath:(NSString *)path taskExistReload:(BOOL (^)())reload;

+ (instancetype)manager;

@end
