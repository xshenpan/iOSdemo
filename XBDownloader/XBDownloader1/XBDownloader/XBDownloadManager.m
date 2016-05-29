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

@property (nonatomic, strong) NSMutableDictionary<NSString*, XBDownloadTaskRecord*> *taskDict;
@property (nonatomic, strong) NSMutableArray<XBDownloadTaskRecord*> *taskQueue;
@property (nonatomic, strong) NSOperationQueue *delegateQueue;
@property (nonatomic, assign) NSUInteger count;
@property (atomic, assign) NSInteger currentTask;

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
        while ([self tryStartupWaitingTask] != -1);
    }else if (_maxDownloadTask < self.currentTask){
        //将多于指定数量的正在执行的任务变更为等待状态
        XBDownloadTaskRecord *record = nil;
        for (NSInteger i = self.taskQueue.count-1; i >= 0; --i) {
            record = self.taskQueue[i];
            if (record.taskInfo.status != XBDownloadTaskStatusRunning) {
                continue;
            }
            //先改变状态再结束任务
            [self changeTaskStatus:XBDownloadTaskStatusWaiting withRecord:record];
            [record.task cancel];
            self.currentTask--;
            record.task = nil;
            if (self.currentTask <= _maxDownloadTask) {
                break;
            }
        }
    }
    _maxDownloadTask = maxDownloadTask;
}

- (NSMutableDictionary<NSString *,XBDownloadTaskRecord *> *)taskDict
{
    if (_taskDict == nil) {
        _taskDict = [NSMutableDictionary dictionary];
    }
    return _taskDict;
}

- (NSMutableArray<XBDownloadTaskRecord *> *)taskQueue
{
    if (_taskQueue == nil) {
        _taskQueue = [self readInfoFromFile];
        if (_taskQueue == nil) {
            _taskQueue = [NSMutableArray array];
        }else{
            for (XBDownloadTaskRecord *record in _taskQueue) {
                if (record.taskInfo.relativePath == nil){
                    record.taskInfo.name = [record.taskInfo.url lastPathComponent];
                }else{
                    record.taskInfo.name = [record.taskInfo.relativePath lastPathComponent];
                }
                self.taskDict[record.taskInfo.taskKey] = record;
                record.taskInfo.status = XBDownloadTaskStatusPause;
            }
        }
    }
    return _taskQueue;
}

- (void)setDelegate:(id<XBDownloadManagerDelegate>)delegate andDelegateQueue:(NSOperationQueue *)queue
{
    if (queue == nil || delegate == nil) return;
    self.delegateQueue = queue;
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        //使用delegate而不是_delegate防止在设置代理未完成时导致其他代理方法执行发生错误
        if ([delegate respondsToSelector:@selector(managerAddTaskName:andStatus:forKey:atIndex:)]) {
            for (NSInteger i = 0; i < self.taskQueue.count; ++i) {
                XBDownloadTaskRecord *rd = self.taskQueue[i];
                [delegate managerAddTaskName:rd.taskInfo.name andStatus:rd.taskInfo.status forKey:rd.taskInfo.taskKey atIndex:i];
            }
        }
    }];
    
    if ([[NSOperationQueue currentQueue] isEqual:self.delegateQueue]) {
        [op start];
    }else{
        [self.delegateQueue addOperations:@[op] waitUntilFinished:YES];
    }
    
    _delegate = delegate;
}

- (NSInteger)taskNumber
{
    return self.taskQueue.count;
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
    XBDownloadTaskRecord *record = self.taskDict[key];
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
    XBDownloadTaskRecord *record = self.taskDict[key];
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
    XBDownloadTaskRecord *record = self.taskDict[key];
    if (record == nil) return;
    
    [self cancelTask:record];
}

/**
 *  重新下载任务
 */

- (void)reloadWithKey:(NSString *)key
{
    XBDownloadTaskRecord *record = self.taskDict[key];
    if (record == nil) return;
    record.startup = NO;
    if (record.taskInfo.status == XBDownloadTaskStatusRunning) {
        //不执行currentTask--，即先占用一个任务数
        [record.task cancel];
        record.task = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[kDownloadDirictory stringByAppendingPathComponent:record.taskInfo.taskKey] error:nil];
        record.taskInfo.status = XBDownloadTaskStatusWaiting;
        //当前任务数减1,此时相当于有一个任务未启动,然后立即启动当前需要重载的任务
        self.currentTask--;
        [self tryStartupTheTask:record];
    }else {
        [[NSFileManager defaultManager] removeItemAtPath:[kDownloadDirictory stringByAppendingPathComponent:record.taskInfo.taskKey] error:nil];
        [self tryStartupTheTask:record];
    }
}

#pragma mark - 启动/暂停/关闭任务--公共方法

- (void)startTask:(XBDownloadTaskRecord *)record
{
    [self tryStartupTheTask:record];
}

- (void)pauseTask:(XBDownloadTaskRecord *)record
{
    if (record.task) {
        [record.task cancel];
        record.task = nil;
        self.currentTask--;
    }
    [self changeTaskStatus:XBDownloadTaskStatusPause withRecord:record];
    [self tryStartupWaitingTask];
}

- (void)cancelTask:(XBDownloadTaskRecord *)record
{
    if (record.task) {
        [record.task cancel];
        record.task = nil;
        self.currentTask--;
    }
    [self removeTaskWithRecord:record];
    [self tryStartupWaitingTask];
    // 移除临时文件
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [[NSFileManager defaultManager] removeItemAtPath:[kDownloadDirictory stringByAppendingPathComponent:record.taskInfo.taskKey] error:nil];
    }];
}


#pragma mark - 添加一个下载信息
- (NSString *)addDownloadTaskWithUrl:(NSString *)url andRelativePath:(NSString *)path taskKey:(NSString *)key taskExist:(void(^)(NSString *key))exist
{
    NSString *taskKey = (key == nil) ? url.md5String : key;
    XBDownloadTaskRecord *record = self.taskDict[taskKey];
    
    if (record == nil) {
        //任务没有被创建,创建一条记录
        record = [[XBDownloadTaskRecord alloc] init];
        record.startup = NO;
        record.taskInfo.taskKey = taskKey;
        record.taskInfo.url = url;
        record.taskInfo.status = XBDownloadTaskStatusWaiting;
        record.taskInfo.relativePath = path;
        record.taskInfo.name = path == nil ? [url lastPathComponent] : [path lastPathComponent];
        //将任务加入到任务信息队列中
        [self addTaskWithRecord:record];
        [self tryStartupTheTask:record];
        
    }else {
        if(exist == nil) return taskKey;
        exist(record.taskInfo.taskKey);
    }
    return taskKey;
}

#pragma mark - 内部逻辑
/**
 *  尝试启动指定的任务
 */
- (void)tryStartupTheTask:(XBDownloadTaskRecord *)taskRecord
{
    if (taskRecord == nil || taskRecord.taskInfo.status == XBDownloadTaskStatusRunning) return;
    if (self.currentTask >= self.maxDownloadTask) {
        //任务达到上限,更改任务的状态为等待
        [self changeTaskStatus:XBDownloadTaskStatusWaiting withRecord:taskRecord];
        return;
    }
    //占用一个任务
    self.currentTask++;
    [self startupTaskWithRecord:taskRecord];
}

/**
 *  尝试启动等待的任务
 */
- (NSInteger)tryStartupWaitingTask
{
    if (self.currentTask >= self.maxDownloadTask) return -1;
    //可能有任务被启动，先占用一个任务数量
    self.currentTask++;
    for (XBDownloadTaskRecord *record in self.taskQueue) {
        if (record.taskInfo.status == XBDownloadTaskStatusWaiting) {
            [self startupTaskWithRecord:record];
            return 0;
        }
    }
    //在对列中没有找到合适的任务，归还占用的任务数
    self.currentTask--;
    return -1;
}
/**
 *  根据任务记录，创建下载任务
 */
- (void)startupTaskWithRecord:(XBDownloadTaskRecord *)taskRecord
{
    if (taskRecord.task) {
        //任务对象存在，直接启动
        [taskRecord.task start];
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:taskRecord.taskInfo.url]];
    
    if (taskRecord.startup != YES) {
        //任务启动过,但任务对象被销毁了,需要设置请求的范围
        if (taskRecord.taskInfo.taskKey == nil) taskRecord.taskInfo.taskKey = taskRecord.taskInfo.url.md5String;
        NSString *filePath = [kDownloadDirictory stringByAppendingPathComponent:taskRecord.taskInfo.taskKey];
        NSInteger size = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil][NSFileSize] integerValue];
        [request setValue:[NSString stringWithFormat:@"bytes=%zd-",size] forHTTPHeaderField:@"Range"];
        taskRecord.tmpFileSize = size;
    }
    
    [self writeInfoToFile];
    
    __weak typeof(self) weakSelf = self;
    //创建下载任务对象
    XBDownloadTask *dwTask = [XBDownloadTask downloadWithRequest:request andTempFileName:taskRecord.taskInfo.taskKey];
    
    [dwTask setProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        
        NSInteger diff = _count - taskRecord.timerFlag;
        if (diff > 0) {
            if ([self.delegate respondsToSelector:@selector(managerRefreshTaskProgress:speed:forKey:atIndex:)]) {
                //0.5s * diff间隔内的数据差值
                NSInteger idx = [self.taskQueue indexOfObject:taskRecord];
                
                if (taskRecord.taskInfo.filesize == 0) {
                    taskRecord.taskInfo.filesize = taskRecord.tmpFileSize + totalBytesExpectedToRead;
                    if ([self.delegate respondsToSelector:@selector(managerTaskFileLength:forKey:atIndex:)]) {
                        [self.delegateQueue addOperationWithBlock:^{
                            [self.delegate managerTaskFileLength:taskRecord.taskInfo.filesize forKey:taskRecord.taskInfo.taskKey atIndex:idx];
                        }];
                    }
                }
                NSInteger diffBytes = totalBytesRead - taskRecord.bytesLength;
                taskRecord.taskInfo.speed = diffBytes / (kManagerProgressUpdateInterval * diff * 1024); //  KB/s
                taskRecord.taskInfo.progress = (taskRecord.tmpFileSize + totalBytesRead)*1.0 / taskRecord.taskInfo.filesize;
                
                [self.delegateQueue addOperationWithBlock:^{
                    [self.delegate managerRefreshTaskProgress:taskRecord.taskInfo.progress speed:taskRecord.taskInfo.speed forKey:taskRecord.taskInfo.taskKey atIndex:idx];
                }];
            }
            taskRecord.timerFlag = _count;
            taskRecord.bytesLength = totalBytesRead;
        }
    }];
    
    [dwTask setCompleteBlock:^(NSString *filePath, NSError *error) {
        
        NSInteger idx = [self.taskQueue indexOfObject:taskRecord];
        if (!error) {
            //移动临时文件到指定文件夹
            NSString *dstPath = taskRecord.taskInfo.relativePath;
            if (dstPath == nil) {
                dstPath = [kDownloadDirictory stringByAppendingPathComponent:[taskRecord.taskInfo.url lastPathComponent]];
            }else{
                dstPath = [NSHomeDirectory() stringByAppendingPathComponent:dstPath];
            }
            [weakSelf moveFileAtPath:filePath toPath:dstPath];
            
            //通知代理任务完成
            if ([self.delegate respondsToSelector:@selector(managerTaskCompleteWithError:forKey:atIndex:)]) {
                [self.delegateQueue addOperationWithBlock:^{
                    [self.delegate managerTaskCompleteWithError:error forKey:taskRecord.taskInfo.taskKey atIndex:idx];
                }];
            }
            [weakSelf removeTaskWithRecord:taskRecord];
            
        }else{
            //主动关闭任务
            if (error.code == NSURLErrorCancelled) return;
            
            [self changeTaskStatus:XBDownloadTaskStatusError withRecord:taskRecord];
            //通知代理任务完成
            if ([self.delegate respondsToSelector:@selector(managerTaskCompleteWithError:forKey:atIndex:)]) {
                [self.delegateQueue addOperationWithBlock:^{
                    [self.delegate managerTaskCompleteWithError:error forKey:taskRecord.taskInfo.taskKey atIndex:idx];
                }];
            }
            XBWARNLOG(@"download error---%@",error);
        }
        //启动一个等待任务
        self.currentTask--;
        [weakSelf tryStartupWaitingTask];
    }];
    
    taskRecord.task = dwTask;
    [dwTask start];
    [self changeTaskStatus:XBDownloadTaskStatusRunning withRecord:taskRecord];
}

#pragma mark - 增加/删除/改变/查询任务

/**
 *  将任务添加到任务队列和任务字典中
 */
- (void)addTaskWithRecord:(XBDownloadTaskRecord *)record
{
    [self.taskQueue addObject:record];
    self.taskDict[record.taskInfo.taskKey] = record;
    [self writeInfoToFile];
    
    if ([self.delegate respondsToSelector:@selector(managerAddTaskName:andStatus:forKey:atIndex:)]) {
        NSInteger idx = self.taskQueue.count-1;
        [self.delegateQueue addOperationWithBlock:^{
            [self.delegate managerAddTaskName:record.taskInfo.name andStatus:record.taskInfo.status forKey:record.taskInfo.taskKey atIndex:idx];
        }];
    }
    
    NSDictionary *dict = @{kManagerNotificationKeyTaskNumber : @(self.taskQueue.count)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kXBDownloadManagerNotification object:self userInfo:dict];
}

/**
 *  从队列删除任务
 */
- (void)removeTaskWithRecord:(XBDownloadTaskRecord *)record
{
    
    NSInteger idx = [self.taskQueue indexOfObject:record];
    [self.taskQueue removeObject:record];
    [self.taskDict removeObjectForKey:record.taskInfo.taskKey];
    [self writeInfoToFile];
    
    if ([self.delegate respondsToSelector:@selector(managerDeleteTaskForKey:atIndex:)]) {
        //等待其他代理执行完成
        XBWARNLOG(@"will call remove delegate");
        [self.delegateQueue waitUntilAllOperationsAreFinished];
        [self.delegateQueue addOperationWithBlock:^{
            [self.delegate managerDeleteTaskForKey:record.taskInfo.taskKey atIndex:idx];
        }];
        XBWARNLOG(@"did call remove delegate");
    }
    
    NSDictionary *dict = @{kManagerNotificationKeyTaskNumber : @(self.taskQueue.count)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kXBDownloadManagerNotification object:self userInfo:dict];
}

/**
 *  改变record中的任务状态
 */
- (void)changeTaskStatus:(XBDownloadTaskStatus)status withRecord:(XBDownloadTaskRecord *)record
{
    record.taskInfo.status = status;
    if ([self.delegate respondsToSelector:@selector(managerTaskStatusChanged:forKey:atIndex:)]) {
        NSInteger idx = [self.taskQueue indexOfObject:record];
        if (idx == NSNotFound) { XBERRORLOG(@"index = NSNotFound status = %zd",status); return;}
        [self.delegateQueue addOperationWithBlock:^{
            [self.delegate managerTaskStatusChanged:record.taskInfo.status forKey:record.taskInfo.taskKey atIndex:idx];
        }];
    }
}

/**
 *  通过index查询任务信息
 */

- (XBDownloadTaskInfo *)taskInfoWithIndex:(NSInteger)idx
{
    if (idx >=  self.taskQueue.count) return nil;
    return [self.taskQueue[idx].taskInfo copy];
}

/**
 *  通过key查询任务信息
 */
- (XBDownloadTaskInfo *)taskInfoWithKey:(NSString *)key
{
    return [self.taskDict[key].taskInfo copy];
}

#pragma mark - 磁盘记录读写

- (void)writeInfoToFile
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.taskQueue];
        [data writeToFile:kAllTaskRecordFilePath atomically:YES];
    }];
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
        error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:&error];
        if (error.code == NSFileWriteFileExistsError) {
            NSString *extension = [dstPath pathExtension];
            if (orig == nil) orig = [dstPath stringByDeletingPathExtension];
            dstPath = [NSString stringWithFormat:@"%@_%zd.%@", orig, i++, extension];
        }else if (error.code == NSFileWriteInvalidFileNameError){
            dstPath = [srcPath stringByAppendingPathExtension:[dstPath pathExtension]];
        }else if(error) {
            XBERRORLOG(@"move file error %@", error);
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
