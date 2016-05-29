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

- (void)managerAddTaskName:(NSString *)name andStatus:(XBDownloadTaskStatus)status fileLength:(NSInteger)length forKey:(NSString *)key atIndex:(NSInteger)idx;
- (void)managerDeleteTaskForKey:(NSString *)key atIndex:(NSInteger)idx;
- (void)managerTaskFileLength:(NSInteger)fileLength forKey:(NSString *)key atIndex:(NSInteger)idx;
- (void)managerRefreshTaskProgress:(CGFloat)progress speed:(CGFloat)speed forKey:(NSString *)key atIndex:(NSInteger)idx;
- (void)managerTaskStatusChanged:(XBDownloadTaskStatus)status forKey:(NSString *)key atIndex:(NSInteger)idx;
- (void)managerTaskCompleteWithError:(NSError *)error forKey:(NSString *)key atIndex:(NSInteger)idx;

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
//设置代理
- (void)setDelegate:(id<XBDownloadManagerDelegate>)delegate andDelegateQueue:(NSOperationQueue *)queue;
/** 添加一个下载任务,path=nil这默认在cache/xbdownload目录 路经以home开始, key=nil 则key = url.md5string */
- (NSString *)addDownloadTaskWithUrl:(NSString *)url andRelativePath:(NSString *)path taskKey:(NSString *)key taskExist:(void(^)(NSString *key))exist;

+ (instancetype)manager;

@end
