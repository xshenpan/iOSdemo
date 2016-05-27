//
//  XBDownloadTaskRecord.m
//  07-断点下载
//
//  Created by xshenpan on 16/5/24.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "XBDownloadTaskRecord.h"
#import "XBDownloadTaskInfo.h"

static NSString * const kTaskInfo = @"XBDownloadTaskRecordTaskInfo";

@implementation XBDownloadTaskRecord

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.taskInfo = [coder decodeObjectForKey:kTaskInfo];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.taskInfo forKey:kTaskInfo];
}

- (XBDownloadTaskInfo *)taskInfo
{
    if (_taskInfo == nil) {
        _taskInfo = [[XBDownloadTaskInfo alloc] init];
    }
    return _taskInfo;
}

- (void)dealloc
{
    NSLOG(@"%s", __func__);
}

@end
