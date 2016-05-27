//
//  XBDownloadTask.h
//  07-断点下载
//
//  Created by xshenpan on 16/5/24.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^XBCompleteBlock)(NSString *filePath, NSError *error);
typedef void(^XBDownloadProgressBlock)(NSInteger bytesRead, NSInteger totalBytesRead , NSInteger totalBytesExpectedToRead);

@interface XBDownloadTask : NSObject

- (void)pause;
- (void)start;
- (void)cancel;

- (void)setProgressBlock:(XBDownloadProgressBlock)progressBlock;
- (void)setCompleteBlock:(XBCompleteBlock)completeBlock;
+ (instancetype)downloadWithRequest:(NSURLRequest *)req andTempFileName:(NSString *)name;

@end
