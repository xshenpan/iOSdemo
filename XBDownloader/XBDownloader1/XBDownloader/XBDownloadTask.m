//
//  XBDownloadTask.m
//  07-断点下载
//
//  Created by xshenpan on 16/5/24.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "XBDownloadTask.h"
#import "NSString+Hash.h"

@interface XBDownloadTask() <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) NSOutputStream *stream;
@property (nonatomic, copy) NSString *tmpPath;
@property (nonatomic, assign) NSInteger totalFileSize;
@property (nonatomic, assign) NSInteger downLength;
@property (nonatomic, strong) XBDownloadProgressBlock progressBlock;
@property (nonatomic, strong) XBCompleteBlock completeBlock;

@end

@implementation XBDownloadTask

+ (instancetype)downloadWithRequest:(NSURLRequest *)req andTempFileName:(NSString *)name
{
    XBDownloadTask *downloader = [[self alloc] init];
    
    //不使用request缓存,不然有时候重新下载同一地址，如果上次是从中间下载的这次可能本来想要下载完整数据，结构下载成了上次的半截数据
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:downloader delegateQueue:[[NSOperationQueue alloc] init]];
    
    downloader.task = [session dataTaskWithRequest:req];
    downloader.tmpPath = [kDownloadDirictory stringByAppendingPathComponent:name];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:kDownloadDirictory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:kDownloadDirictory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    
    return downloader;
}

- (void)setProgressBlock:(XBDownloadProgressBlock)progressBlock
{
    _progressBlock = progressBlock;
}

- (void)setCompleteBlock:(XBCompleteBlock)completeBlock
{
    _completeBlock = completeBlock;
}

#pragma mark - 下载动作
- (void)start
{
    [self.task resume];
}

- (void)pause
{
    [self.task suspend];
}

- (void)cancel
{
    [self.task cancel];
}

#pragma mark - <NSURLSessionDataDelegate>

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    if (response.statusCode != 200 && response.statusCode != 206) {
        completionHandler(NSURLSessionResponseCancel);
        XBINFOLOG(@"%zd", response.statusCode);
        return;
    }
    NSString *contentLength = response.allHeaderFields[@"Content-Length"];
    if (contentLength == nil) {
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    self.totalFileSize = contentLength.integerValue;
    //创建流
    self.stream = [[NSOutputStream alloc] initToFileAtPath:self.tmpPath append:YES];
    [self.stream open];
    
    //允许接收响应
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.stream write:data.bytes maxLength:data.length];
    self.downLength += data.length;
    if (self.progressBlock) {
        self.progressBlock(data.length, self.downLength, self.totalFileSize);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self.stream close];
    self.task = nil;
    self.stream = nil;
    
    if (self.completeBlock) {
        self.completeBlock(self.tmpPath, error);
    }
    
    [session finishTasksAndInvalidate];
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    
}

- (void)dealloc
{
    XBINFOLOG(@"dealloc -- %@", [self.tmpPath lastPathComponent]);
}

@end
