//
//  XBDownloadTaskInfo.h
//  07-断点下载
//
//  Created by xshenpan on 16/5/24.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    XBDownloadTaskStatusBorn = 0,
    XBDownloadTaskStatusWaiting,
    XBDownloadTaskStatusPause,
    XBDownloadTaskStatusRunning,
    XBDownloadTaskStatusComplete,
    XBDownloadTaskStatusError,
    XBDownloadTaskStatusCancel,
} XBDownloadTaskStatus;

@interface XBDownloadTaskInfo : NSObject
//会写入文件的属性
/** 任务名/文件名 */
@property (nonatomic, copy) NSString *relativePath;
/** 任务url */
@property (nonatomic, copy) NSString *url;
/** 任务状态 */
@property (nonatomic, assign) XBDownloadTaskStatus status;

//不会写入文件的属性
/** 文件名 */
@property (nonatomic, copy) NSString *name;
/** 临时文件名/任务标记 */
@property (nonatomic, copy) NSString *taskKey;
/** 下载进度 */
@property (nonatomic, assign) CGFloat progress;
/** 下载速度 */
@property (nonatomic, assign) CGFloat speed;
/** 文件大小 */
@property (nonatomic, assign) NSInteger filesize;



@end
