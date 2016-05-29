//
//  XBDownloadTaskRecord.m
//  07-断点下载
//
//  Created by xshenpan on 16/5/24.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "XBDownloadTaskRecord.h"
#import "XBDownloadTaskInfo.h"

static NSString * const kTaskInfo = @"XBDownloadTaskInfo";
static NSString * const kTaskStartup = @"XBDownloadTaskInfoTaskStartup";

@implementation XBDownloadTaskRecord

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.startup = [coder decodeBoolForKey:kTaskStartup];
        self.taskInfo = [coder decodeObjectForKey:kTaskInfo];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.startup forKey:kTaskStartup];
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
    XBINFOLOG(@"%s", __func__);
}



@end
