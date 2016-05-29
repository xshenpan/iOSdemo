//
//  XBDownloadTaskInfo.h
//  07-断点下载
//
//  Created by xshenpan on 16/5/24.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    XBDownloadTaskStatusWaiting = 0,
    XBDownloadTaskStatusPause,
    XBDownloadTaskStatusRunning,
    XBDownloadTaskStatusComplete,
    XBDownloadTaskStatusCancel,
    XBDownloadTaskStatusError = 0x1000,
} XBDownloadTaskStatus;

@interface XBDownloadTaskInfo : NSObject

/** 文件相对路径，相对于home */
@property (nonatomic, copy) NSString *relativePath;
/** 任务url */
@property (nonatomic, copy) NSString *url;
/** 文件名 */
@property (nonatomic, copy) NSString *name;
/** 下载进度 */
@property (nonatomic, assign) CGFloat progress;
/** 下载速度 */
@property (nonatomic, assign) CGFloat speed;
/** 文件大小 */
@property (nonatomic, assign) NSInteger filesize;
/** 临时文件名/任务标记 */
@property (nonatomic, copy) NSString *taskKey;
/** 任务状态 */
@property (nonatomic, assign) XBDownloadTaskStatus status;

@end
