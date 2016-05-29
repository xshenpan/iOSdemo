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
/** 下载任务对象 */
@property (nonatomic, weak) XBDownloadTask *task;
/** 已下载的临时文件大小 */
@property (nonatomic, assign) NSInteger tmpFileSize;
/** 时间标记，用于计算网速 */
@property (nonatomic, assign) NSUInteger timerFlag;
/** 在时间标记时下载的文件长度，用于计算网速 */
@property (nonatomic, assign) NSInteger bytesLength;

//写入文件的信息
/** 记录该任务否启动过了 */
@property (nonatomic, assign, getter=isStartup) BOOL startup;
@property (nonatomic, strong) XBDownloadTaskInfo *taskInfo;

//准备废弃的属性
/** 同步代理执行顺序 */
//@property (atomic, assign) NSInteger sync;

@end
