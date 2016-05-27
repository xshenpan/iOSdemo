//
//  XBDownloadManager.m
//  07-断点下载
//
//  Created by xshenpan on 16/5/20.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "XBDownloadManager.h"
#import "XBDownloadTaskInfo.h"
#import "XBDownloadTaskRecord.h"
#import "XBDownloadTask.h"
#import "NSString+Hash.h"

#define kAllTaskRecordFilePath [kDownloadDirictory stringByAppendingPathComponent:@"xbdownload.record"]

@interface XBDownloadManager() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString*, XBDownloadTaskRecord*> *taskRecord;
@property (nonatomic, strong) NSMutableArray<XBDownloadTaskRecord*> *taskQueue;
@property (nonatomic, assign) NSInteger currentTask;
@property (nonatomic, assign) NSUInteger count;
@end

@implementation XBDownloadManager

#pragma mark - 单例模式
static id _instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
- (id)copyWithZone:(NSZone *)zone
{
    return _instance;
}
+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance setMaxDownloadTask:1];
        //创建用于计算网速的和通知刷新进度的定时器
        NSTimer*timer = [NSTimer timerWithTimeInterval:kManagerProgressUpdateInterval target:_instance selector:@selector(timerCount) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    });
    return _instance;
}

#pragma mark - setter/getter

- (void)setMaxDownloadTask:(NSInteger)maxDownloadTask
{
    if (maxDownloadTask < 1 || maxDownloadTask > 10) return;
    _maxDownloadTask = maxDownloadTask;
    if (_maxDownloadTask > self.currentTask) {
        NSLOG(@"setMaxDownload>>> = %zd", self.currentTask);
        while ([self tryStartupWaitingTask] != -1);
        NSLOG(@"setMaxDownload>>>... = %zd", self.currentTask);
    }else if (_maxDownloadTask < self.currentTask){
        XBDownloadTaskRecord *record = nil;
        NSLOG(@"setMaxDownload<<< = %zd", self.currentTask);
        for (NSInteger i = self.taskQueue.count-1; i >= 0; --i) {
            record = self.taskQueue[i];
            if (record.taskInfo.status != XBDownloadTaskStatusRunning) {
                continue;
            }
            //先改变状态再结束任务
            [self changeTaskStatus:XBDownloadTaskStatusWaiting withRecord:record];
            [record.task cancel];
            record.task = nil;
            self.currentTask--;
            if (self.currentTask <= _maxDownloadTask) {
                break;
            }
        }
        NSLOG(@"setMaxDownload<<<... = %zd", self.currentTask);
    }
    _maxDownloadTask = maxDownloadTask;
}

- (NSMutableDictionary<NSString *,XBDownloadTaskRecord *> *)taskRecord
{
    if (_taskRecord == nil) {
        _taskRecord = [NSMutableDictionary dictionary];
    }
    return _taskRecord;
}

- (NSMutableArray<XBDownloadTaskRecord *> *)taskQueue
{
    if (_taskQueue == nil) {
        _taskQueue = [self readInfoFromFile];
        if (_taskQueue == nil) {
            _taskQueue = [NSMutableArray array];
        }
        for (XBDownloadTaskRecord *record in _taskQueue) {
            record.taskInfo.taskKey = record.taskInfo.url.md5String;
            if (record.taskInfo.relativePath == nil){
                record.taskInfo.name = [record.taskInfo.url lastPathComponent];
            }else{
                record.taskInfo.name = [record.taskInfo.relativePath lastPathComponent];
            }
            
            self.taskRecord[record.taskInfo.taskKey] = record;
            record.taskInfo.status = XBDownloadTaskStatusPause;
        }
    }
    return _taskQueue;
}

- (void)setDelegate:(id<XBDownloadManagerDelegate>)delegate
{
    if (delegate == nil) return;
    
    //使用delegate而不是_delegate防止在设置代理未完成时导致其他代理方法执行发生错误
    if ([delegate respondsToSelector:@selector(managerTaskList:)]) {
        NSMutableArray *taskList = [NSMutableArray array];
        for (XBDownloadTaskRecord *rd in self.taskQueue) {
            [taskList addObject:rd.taskInfo];
        }
        [delegate managerTaskList:taskList];
    }
    _delegate = delegate;
}


- (NSInteger)taskNumber
{
    return self.taskQueue.count;
}

#pragma mark - 查询方法 --- 外部接口

- (XBDownloadTaskInfo *)taskInfoWithIndex:(NSInteger)idx
{
    if (idx >= self.taskQueue.count) return nil;
    return self.taskQueue[idx].taskInfo;
}

- (XBDownloadTaskInfo *)taskInfoWithKey:(NSString *)key
{
    return self.taskRecord[key].taskInfo;
}

#pragma mark - 开始/暂停/关闭任务--外部接口

- (void)startAllDownloadTask
{
    for (XBDownloadTaskRecord *record in self.taskQueue) {
        if (record.taskInfo.status != XBDownloadTaskStatusRunning) {
            [self changeTaskStatus:XBDownloadTaskStatusWaiting withRecord:record];
        }
    }
    while ([self tryStartupWaitingTask] != -1);
}

- (void)pauseAllDownloadTask
{
    for (XBDownloadTaskRecord *record in self.taskQueue) {
        if (record.taskInfo.status != XBDownloadTaskStatusPause){
            [self changeTaskStatus:XBDownloadTaskStatusPause withRecord:record];
        }
    }
    for (XBDownloadTaskRecord *record in self.taskQueue) {
        if (record.task) {
            [self pauseTask:record];
        }
    }
}

/**
*  开始一个任务
*/
-(void)startWithIndex:(NSInteger)idx
{
    if (idx >= self.taskQueue.count) return;
    XBDownloadTaskRecord *record = self.taskQueue[idx];
    
    [self startTask:record];
}

-(void)startWithKey:(NSString *)key
{
    XBDownloadTaskRecord *record = self.taskRecord[key];
    if (record == nil) return;
    
    [self startTask:record];
}


/**
 *  暂停一个任务
 */
- (void)pauseWithIndex:(NSInteger)idx
{
    if (idx >= self.taskQueue.count) return;
    
    XBDownloadTaskRecord *record = self.taskQueue[idx];
    [self pauseTask:record];
}

- (void)pauseWithKey:(NSString *)key
{
    XBDownloadTaskRecord *record = self.taskRecord[key];
    if (record == nil) return;
    
    [self pauseTask:record];
}


/**
 *  关闭一个任务
 */

-(void)cancelWithIndex:(NSInteger)idx
{
    if (idx >= self.taskQueue.count) return;
    XBDownloadTaskRecord *record = self.taskQueue[idx];
    
    [self cancelTask:record];
}

-(void)cancelWithKey:(NSString *)key
{
    XBDownloadTaskRecord *record = self.taskRecord[key];
    if (record == nil) return;
    
    [self cancelTask:record];
}


#pragma mark - 启动/暂停/关闭任务--公共方法

- (void)startTask:(XBDownloadTaskRecord *)record
{
    [self tryStartupTheTask:record];
}

- (void)pauseTask:(XBDownloadTaskRecord *)record
{
    //先改变状态再关闭任务，不然后面会将任务当成异常结束
    [self changeTaskStatus:XBDownloadTaskStatusPause withRecord:record];
    if (record.task) {
        [record.task cancel];
        record.task = nil;
        self.currentTask--;
    }
    [self tryStartupWaitingTask];
}

- (void)cancelTask:(XBDownloadTaskRecord *)record
{
    if (record.task) {
        [record.task cancel];
        self.currentTask--;
        record.task = nil;
    }
    record.taskInfo.status = XBDownloadTaskStatusCancel;
    [self removeTaskWithRecord:record];
    [self tryStartupWaitingTask];
    // 移除临时文件，不管任务有没有
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [[NSFileManager defaultManager] removeItemAtPath:[kDownloadDirictory stringByAppendingPathComponent:record.taskInfo.taskKey] error:nil];
    }];
}


#pragma mark - 添加一个下载信息
- (NSString *)addDownloadTaskWithUrl:(NSString *)url andRelativePath:(NSString *)path taskExistReload:(BOOL (^)())reload
{
    NSString *taskKey = url.md5String;
    XBDownloadTaskRecord *record = self.taskRecord[taskKey];
    
    if (record == nil) {
        //任务没有被创建,创建一条记录
        record = [[XBDownloadTaskRecord alloc] init];
        record.taskInfo.taskKey = taskKey;
        
        record.taskInfo.url = url;
        record.taskInfo.status = XBDownloadTaskStatusBorn;
        record.taskInfo.relativePath = path;
        record.taskInfo.name = path == nil ? [url lastPathComponent] : [path lastPathComponent];
        //将任务加入到任务信息队列中
        [self addTaskWithRecord:record];
        [self tryStartupTheTask:record];
        
    }else if (record.taskInfo.status == XBDownloadTaskStatusRunning){
        //任务正在运行,检查是否重新下载
        if(reload){
            //cancel任务，重新加到下载任务中
        }
    }
    
    return taskKey;
}

#pragma mark - 内部管理逻辑
/**
 *  尝试启动指定的任务
 */
- (void)tryStartupTheTask:(XBDownloadTaskRecord *)taskRecord
{
    if (taskRecord == nil || taskRecord.taskInfo.status == XBDownloadTaskStatusRunning) return;
    if (self.currentTask >= self.maxDownloadTask) {
        //任务达到上限,更改任务的状态为等待
        [self changeTaskStatus:XBDownloadTaskStatusWaiting withRecord:taskRecord];
        NSLOG(@"return trystarup record = %zd", self.currentTask);
        return;
    }
    NSLOG(@"startup trystarup record = %zd", self.currentTask);
    [self startupTaskWithRecord:taskRecord];
}

/**
 *  尝试启动等待的任务
 */
- (NSInteger)tryStartupWaitingTask
{
    if (self.currentTask >= self.maxDownloadTask) return -1;
    //从任务信息队列中取出未执行或等待执行的任务
    for (XBDownloadTaskRecord *record in self.taskQueue) {
        if (record.taskInfo.status == XBDownloadTaskStatusWaiting ||
            record.taskInfo.status == XBDownloadTaskStatusBorn) {
            
            [self startupTaskWithRecord:record];
            NSLOG(@"0 trystarup = %zd", self.currentTask);
            return 0;
        }
    }
    NSLOG(@"-1 trystarup = %zd", self.currentTask);
    return -1;
}
/**
 *  根据任务记录，创建下载任务
 */
- (void)startupTaskWithRecord:(XBDownloadTaskRecord *)taskRecord
{
    self.currentTask++;
    if (taskRecord.task) {
        //任务对象存在，直接启动
        [taskRecord.task start];
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:taskRecord.taskInfo.url]];
    //任务对象不存在
    if (taskRecord.taskInfo.status != XBDownloadTaskStatusBorn) {
    //任务启动过,但任务对象被销毁了,需要设置请求的范围
        if (taskRecord.taskInfo.taskKey == nil) taskRecord.taskInfo.taskKey = taskRecord.taskInfo.url.md5String;
        NSString *filePath = [kDownloadDirictory stringByAppendingPathComponent:taskRecord.taskInfo.taskKey];
        NSInteger size = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil][NSFileSize] integerValue];
        [request setValue:[NSString stringWithFormat:@"bytes=%zd-",size] forHTTPHeaderField:@"Range"];
        taskRecord.tmpFileSize = size;
    }else{
        //任务在程序运行期间添加进来，并且没有启动过
    }
    [self changeTaskStatus:XBDownloadTaskStatusRunning withRecord:taskRecord];
    [self writeInfoToFile];
    
    __weak typeof(self) weakSelf = self;
    //创建下载任务对象
    XBDownloadTask *dwTask = [XBDownloadTask downloadWithRequest:request andTempFileName:taskRecord.taskInfo.taskKey];
    
    [dwTask setProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        NSInteger diff = _count - taskRecord.timerFlag;
        if (diff > 0) {
            
            if ([self.delegate respondsToSelector:@selector(managerTaskProgressRefresh:atIndex:)]) {
                taskRecord.sync++;
                if (taskRecord.taskInfo.filesize == 0) {
                    taskRecord.taskInfo.filesize = taskRecord.tmpFileSize + totalBytesExpectedToRead;
                }
                //0.5s * diff间隔内的数据差值
                NSInteger diffBytes = totalBytesRead - taskRecord.bytesLength;
                taskRecord.taskInfo.speed = diffBytes / (kManagerProgressUpdateInterval * diff * 1024); //  KB/s
                taskRecord.taskInfo.progress = (taskRecord.tmpFileSize + totalBytesRead)*1.0 / taskRecord.taskInfo.filesize;
                NSInteger idx = [self.taskQueue indexOfObject:taskRecord];
                [self.delegate managerTaskProgressRefresh:taskRecord.taskInfo atIndex:idx];
                taskRecord.sync--;
            }
            taskRecord.timerFlag = _count;
            taskRecord.bytesLength = totalBytesRead;
        }
    }];
    
    [dwTask setCompleteBlock:^(NSString *filePath, NSError *error) {
        if (!error) {
            
            [self changeTaskStatus:XBDownloadTaskStatusComplete withRecord:taskRecord];
            if ([self.delegate respondsToSelector:@selector(managerTask:didCompleteWithError:atIndex:)]) {
                taskRecord.sync++;
                NSInteger idx = [self.taskQueue indexOfObject:taskRecord];
                [self.delegate managerTask:taskRecord.taskInfo didCompleteWithError:error atIndex:idx];
                taskRecord.sync--;
            }
            
            [weakSelf removeTaskWithRecord:taskRecord];
            //移动临时文件到指定文件夹
            NSString *dstPath = taskRecord.taskInfo.relativePath;
            if (dstPath == nil) {
                dstPath = [kDownloadDirictory stringByAppendingPathComponent:[taskRecord.taskInfo.url lastPathComponent]];
            }else{
                dstPath = [NSHomeDirectory() stringByAppendingPathComponent:dstPath];
            }
            
            [weakSelf moveFileAtPath:filePath toPath:dstPath];
            
        }else{
            
            if (taskRecord.taskInfo.status != XBDownloadTaskStatusRunning) return;
            //如果是运行状态导致的错误，通知代理发生错误
            [self changeTaskStatus:XBDownloadTaskStatusError withRecord:taskRecord];
            if ([self.delegate respondsToSelector:@selector(managerTask:didCompleteWithError:atIndex:)]) {
                taskRecord.sync++;
                NSInteger idx = [self.taskQueue indexOfObject:taskRecord];
                [self.delegate managerTask:taskRecord.taskInfo didCompleteWithError:error atIndex:idx];
                taskRecord.sync--;
            }
            NSLOG(@"download error---%@",error);
        }
        //启动一个等待任务
        self.currentTask--;
        [weakSelf tryStartupWaitingTask];
    }];
    
    taskRecord.task = dwTask;
    [dwTask start];
    NSLOG(@"starup task = %zd", self.currentTask);
}

#pragma mark - 任务增加/删除/改变状态

- (void)changeTaskStatus:(XBDownloadTaskStatus)status withRecord:(XBDownloadTaskRecord *)record
{
    record.taskInfo.status = status;
    if ([self.delegate respondsToSelector:@selector(managerTaskStatusChanged:atIndex:)]) {
        record.sync++;
        NSInteger idx = [self.taskQueue indexOfObject:record];
        [self.delegate managerTaskStatusChanged:record.taskInfo atIndex:idx];
        record.sync--;
    }
}

- (void)removeTaskWithRecord:(XBDownloadTaskRecord *)record
{
    while (record.sync != 0) ;  //同步代理操作，保证在删除任务之前所有其他代理方法执行完成
    if ([self.delegate respondsToSelector:@selector(managerTaskListChange:isDelete:atIndex:)]) {
        NSInteger idx = [self.taskQueue indexOfObject:record];
        [self.delegate managerTaskListChange:record.taskInfo isDelete:YES atIndex:idx];
    }
    
    [self.taskQueue removeObject:record];
    [self.taskRecord removeObjectForKey:record.taskInfo.taskKey];
    [self writeInfoToFile];
    
    NSDictionary *dict = @{kManagerNotificationKeyTaskNumber : @(self.taskQueue.count)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kXBDownloadManagerNotification object:self userInfo:dict];
}

- (void)addTaskWithRecord:(XBDownloadTaskRecord *)record
{
    [self.taskQueue addObject:record];
    self.taskRecord[record.taskInfo.taskKey] = record;
    [self writeInfoToFile];
    if ([self.delegate respondsToSelector:@selector(managerTaskListChange:isDelete:atIndex:)]) {
        record.sync++;
        [self.delegate managerTaskListChange:record.taskInfo isDelete:NO atIndex:self.taskQueue.count-1];
        record.sync--;
    }
    
    NSDictionary *dict = @{kManagerNotificationKeyTaskNumber : @(self.taskQueue.count)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kXBDownloadManagerNotification object:self userInfo:dict];
}

#pragma mark - 磁盘记录读写

- (void)writeInfoToFile
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.taskQueue];
    [data writeToFile:kAllTaskRecordFilePath atomically:YES];
}

- (NSMutableArray *)readInfoFromFile
{
    NSData *data = [NSData dataWithContentsOfFile:kAllTaskRecordFilePath];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (void)moveFileAtPath:(NSString *)srcPath toPath:(NSString *)dstPath
{
    NSError *error;
    NSString *orig = nil;
    NSInteger i = 1;
    
    do {
        [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:&error];
        if (error.code == NSFileWriteFileExistsError) {
            NSString *extension = [dstPath pathExtension];
            if (orig == nil) orig = [dstPath stringByDeletingPathExtension];
            dstPath = [NSString stringWithFormat:@"%@_%zd.%@", orig, i++, extension];
        }else if (error.code == NSFileWriteInvalidFileNameError){
            dstPath = [srcPath stringByAppendingPathExtension:[dstPath pathExtension]];
        }else if(error) {
            NSLOG(@"file write error --- %@",error);
            [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
            break;
        }
    } while (error);
}

#pragma mark - 定时任务

- (void)timerCount;
{
    ++_count;
}

@end
