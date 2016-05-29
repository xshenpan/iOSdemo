//
//  XBDownloadTaskInfo.m
//  07-断点下载
//
//  Created by xshenpan on 16/5/24.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "XBDownloadTaskInfo.h"
#import <objc/runtime.h>

static NSString * const kFilePath = @"XBDownloadTaskInfoFilePath";
static NSString * const kTaskUrl = @"XBDownloadTaskInfoTaskUrl";
static NSString * const kTaskKey = @"XBDownloadTaskInfoTaskKey";

@implementation XBDownloadTaskInfo

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.relativePath = [coder decodeObjectForKey:kFilePath];
        self.url = [coder decodeObjectForKey:kTaskUrl];
        self.taskKey = [coder decodeObjectForKey:kTaskKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:kTaskUrl];
    [aCoder encodeObject:self.relativePath forKey:kFilePath];
    [aCoder encodeObject:self.taskKey forKey:kTaskKey];
}

- (id)copyWithZone:(NSZone *)zone
{
    XBDownloadTaskInfo *info = [[self class] allocWithZone:zone];
    
    //使用运行时机制给copy对象的所有属性赋值
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (unsigned int i = 0; i < count; ++i) {
        objc_property_t property = properties[i];
        NSString *key = @(property_getName(property));
        id value = [self valueForKey:key];
        [info setValue:value forKey:key];
    }
//    info.name = self.name;
//    info.relativePath = self.relativePath;
//    info.url = self.url;
    
    return info;
}

- (void)dealloc
{
    XBINFOLOG(@"%s", __func__);
}

@end