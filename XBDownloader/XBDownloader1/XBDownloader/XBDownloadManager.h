//
//  XBDownloadManager.h
//  07-断点下载
//
//  Created by xshenpan on 16/5/20.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBDownloadTaskInfo.h"

@class XBDownloadManager;
@class XBDownloadTaskInfo;

static const CGFloat kManagerProgressUpdateInterval = 0.5;    //unit : second
static NSString * const kXBDownloadManagerNotification = @"XBDownloadManagerNotification";
static NSString * const kManagerNotificationKeyTaskNumber = @"XBDownloadManagerTaskNumber";

@protocol XBDownloadManagerDelegate <NSObject>
@optional
//删除任务时调用,内部保证同一任务的其他代理方法会在该方法之前调用
- (void)managerDeleteTaskForKey:(NSString *)key atIndex:(NSInteger)idx;
//获得响应文件长度是调用
- (void)managerTaskFileLength:(NSInteger)fileLength forKey:(NSString *)key atIndex:(NSInteger)idx;
//进度和速度更新是调用，由kManagerProgressUpdateInterval控制
- (void)managerRefreshTaskProgress:(CGFloat)progress speed:(CGFloat)speed forKey:(NSString *)key atIndex:(NSInteger)idx;
//任务状态改变时调用
- (void)managerTaskStatusChanged:(XBDownloadTaskStatus)status forKey:(NSString *)key atIndex:(NSInteger)idx;
//任务完成时调用
- (void)managerTaskCompleteWithError:(NSError *)error forKey:(NSString *)key atIndex:(NSInteger)idx;
//添加任务，或设置代理时调用
- (void)managerAddTaskName:(NSString *)name andStatus:(XBDownloadTaskStatus)status fileLength:(NSInteger)length forKey:(NSString *)key atIndex:(NSInteger)idx;

@end

@interface XBDownloadManager : NSObject
/** 最大同时下载任务数 */
@property (nonatomic, assign) NSInteger maxDownloadTask;
/** 代理 */
@property (nonatomic, weak, readonly) id<XBDownloadManagerDelegate> delegate;
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
- (void)reloadWithKey:(NSString *)key;
//查询任务
- (XBDownloadTaskInfo *)taskInfoWithIndex:(NSInteger)idx;
- (XBDownloadTaskInfo *)taskInfoWithKey:(NSString *)key;
//设置代理和代理执行的队列
- (void)setDelegate:(id<XBDownloadManagerDelegate>)delegate andDelegateQueue:(NSOperationQueue *)queue;
/** 添加一个下载任务,path=nil这默认在cache/xbdownload目录 路经以home开始, key=nil 则key = url.md5string */
- (NSString *)addDownloadTaskWithUrl:(NSString *)url andRelativePath:(NSString *)path taskKey:(NSString *)key taskExist:(void(^)(NSString *key))exist;

+ (instancetype)manager;

@end
