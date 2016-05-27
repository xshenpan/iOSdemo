//
//  XBDownloadTaskInfo.m
//  07-断点下载
//
//  Created by xshenpan on 16/5/24.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "XBDownloadTaskInfo.h"

static NSString * const kFilePath = @"XBDownloadTaskInfoFilePath";
static NSString * const kTaskUrl = @"XBDownloadTaskInfoTaskUrl";
static NSString * const kTaskStatus = @"XBDownloadTaskInfoTaskStatus";
static NSString * const kTaskFlag = @"XBDownloadTaskInfoTaskFlag";

@implementation XBDownloadTaskInfo

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.status = [coder decodeIntegerForKey:kTaskStatus];
        self.relativePath = [coder decodeObjectForKey:kFilePath];
        self.url = [coder decodeObjectForKey:kTaskUrl];
//        self.taskFlag = [coder decodeObjectForKey:kTaskFlag];
        
//        NSLOG(@"decode");
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.status forKey:kTaskStatus];
    [aCoder encodeObject:self.url forKey:kTaskUrl];
    [aCoder encodeObject:self.relativePath forKey:kFilePath];
//    [aCoder encodeObject:self.taskFlag forKey:kTaskFlag];
//    NSLOG(@"encode");
}

- (void)dealloc
{
    NSLOG(@"%s", __func__);
}

@end
