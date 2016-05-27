//
//  XBDownloadTaskRecord.h
//  07-断点下载
//
//  Created by xshenpan on 16/5/24.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XBDownloadTask;
@class XBDownloadTaskInfo;

@interface XBDownloadTaskRecord : NSObject
/** 任务对象记录 */
@property (nonatomic, weak) XBDownloadTask *task;
/** 已下载大小 */
@property (nonatomic, assign) NSInteger tmpFileSize;
/** 时间标记 */
@property (nonatomic, assign) NSUInteger timerFlag;
/** 在时间标记时下载的文件长度 */
@property (nonatomic, assign) NSInteger bytesLength;
/** 同步代理执行顺序 */
@property (atomic, assign) NSInteger sync;

/** 任务信息记录 */
@property (nonatomic, strong) XBDownloadTaskInfo *taskInfo;

@end
