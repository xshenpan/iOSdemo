# XBDownloader

## 说明：
- XBDownloader是一个支持多任务断点下载的框架，在学习iOS网络时作为学习demo写的，由于是学习阶段写的东西，没有什么经验，所以代码中免不了许多BUG、考虑不周、思想错误、接口不合理、句子不通，单词错误（英语太菜了）等等问题。写这个小小的demo也是为了加强学习，希望大神对其中的各种错误轻喷

![demo.gif](http://i4.buimg.com/b55b96fe43e40370.gif)

## 用法
### 不关心具体的任务详情

```objc
//获取下载器的单例对象
self.downloadManager = [XBDownloadManager manager];
//设定同时下载数量
//self.downloadManager.maxDownloadTask = 3;
//获取当前任务数量
self.downloadNum.title = [NSString stringWithFormat:@"%zd", self.downloadManager.taskNumber];
//注册通知，这个通知仅仅是通知任务数量
[[NSNotificationCenter defaultCenter] addObserverForName:kXBDownloadManagerNotification object:self.downloadManager queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
    NSNumber *num = note.userInfo[kManagerNotificationKeyTaskNumber];
    self.downloadNum.title = num.stringValue;
        
}];

//添加任务
[self.downloadManager addDownloadTaskWithUrl:response.URL.absoluteString andRelativePath:nil taskKey:nil taskExist:^(NSString *key) {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"任务已经存在" message:@"要重新下载吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [wself.downloadManager reloadWithKey:key];
    }];
    [alert addAction:cancel];
    [alert addAction:sure];
    [wself presentViewController:alert animated:YES completion:nil];
}];

```

### 关心任务详情

```objc
//获取单例对象
self.manager = [XBDownloadManager manager];
//设置代理，指定代理工作的队列
[self.manager setDelegate:self andDelegateQueue:[NSOperationQueue mainQueue]];



//实现某些代理方法
//删除任务时调用,内部保证同一任务的其他代理方法会在该方法之前调用，index是任务按任务添加时的顺序排序的，结合Tableview能很好的工作
- (void)managerDeleteTaskForKey:(NSString *)key atIndex:(NSInteger)idx;
//获得响应文件长度是调用
- (void)managerTaskFileLength:(NSInteger)fileLength forKey:(NSString *)key atIndex:(NSInteger)idx;
//进度和速度更新是调用，由kManagerProgressUpdateInterval控制
- (void)managerRefreshTaskProgress:(CGFloat)progress speed:(CGFloat)speed forKey:(NSString *)key atIndex:(NSInteger)idx;
//任务状态改变时调用
- (void)managerTaskStatusChanged:(XBDownloadTaskStatus)status forKey:(NSString *)key atIndex:(NSInteger)idx;
//任务完成时调用
- (void)managerTaskCompleteWithError:(NSError *)error forKey:(NSString *)key atIndex:(NSInteger)idx;
//添加任务，或设置代理时调用
- (void)managerAddTaskName:(NSString *)name andStatus:(XBDownloadTaskStatus)status fileLength:(NSInteger)length forKey:(NSString *)key atIndex:(NSInteger)idx;

```
