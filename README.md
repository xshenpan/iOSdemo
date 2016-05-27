# XBDownloader

## 一个多任务下载的框架
### 该框架是学习iOS网络编程时做的小demo,框架有一些BUG,仅供学习交流

- 作为一个初学者，代码中免不了许多BUG、考虑不周、思想错误、接口不合理、英语语法错误(英语太烂)等等问题，写这个小小的demo也是为了加强学习，希望大家能够对其中的各种错误轻喷😲

### 用法
#### 控制器不关心任务详情

```objc
//获取XBDownloadManager单例对象
self.downloadManager = [XBDownloadManager manager];
//设定最多同时的下载任务的数量，默认为1
self.downloadManager.maxDownloadTask = 3;
//如果不关心任务具体信息，只想知道任务的个数(如在底部工具栏显示任务数量)那么可以注册一个通知接受者
[[NSNotificationCenter defaultCenter] addObserverForName:kXBDownloadManagerNotification object:self.downloadManager queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
    NSNumber *num = note.userInfo[kManagerNotificationKeyTaskNumber];
    self.downloadNum.title = num.stringValue;  
}];

//添加一个下载任务,如果路径为nil，那么会存在默认的目录下
//- (NSString *)addDownloadTaskWithUrl:(NSString *)url andRelativePath:(NSString *)path taskExistReload:(BOOL (^)())reload;
[self.downloadManager addDownloadTaskWithUrl:response.URL.absoluteString andRelativePath:nil taskExistReload:nil];
```

#### 控制器关心任务详情

```objc
self.downloadManager = [XBDownloadManager manager];
self.manager.delegate = self;

//实现协议中的某些方法
//当进度更新时调用
- (void)managerTaskProgressRefresh:(XBDownloadTaskInfo *)taskInfo atIndex:(NSInteger)idx;
//在设置代理时会调用该方法，将所有的任务信息传递过来
- (void)managerTaskList:(NSArray<XBDownloadTaskInfo *> *)taskList;
//任务状态改变时调用
- (void)managerTaskStatusChanged:(XBDownloadTaskInfo*)taskInfo atIndex:(NSInteger)idx;
//任务完成时调用
- (void)managerTask:(XBDownloadTaskInfo*)taskInfo didCompleteWithError:(NSError *)error atIndex:(NSInteger)idx;
//任务被添加或被删除时调用
- (void)managerTaskListChange:(XBDownloadTaskInfo*)taskInfo isDelete:(BOOL)isDelete atIndex:(NSInteger)idx;

```
