//
//  XBWebViewController.m
//  07-断点下载
//
//  Created by xshenpan on 16/5/26.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "XBWebViewController.h"
#import "XBDownloader/XBDownloader.h"
#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface XBWebViewController () <WKNavigationDelegate, WKUIDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *downloadNum;
@property (weak, nonatomic) WKWebView *web;
@property (strong, nonatomic) NSMutableArray<WKWebView *> *webs;
@property (strong, nonatomic) XBDownloadManager *downloadManager;
@end

@implementation XBWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webs = [NSMutableArray array];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    frame.size.height -= 44;
    WKWebView *web = [[WKWebView alloc] initWithFrame:frame];
    self.web = web;
    self.web.navigationDelegate = self;
    self.web.UIDelegate = self;
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.sogou.com"]]];
    [self.view addSubview:web];
    
    //WKWebView
    //获取下载器的单例对象
    self.downloadManager = [XBDownloadManager manager];
    //设定同时下载数量
//    self.downloadManager.maxDownloadTask = 3;
    //获取当前任务数量
    self.downloadNum.title = [NSString stringWithFormat:@"%zd", self.downloadManager.taskNumber];
    //注册通知，这个通知仅仅是通知任务数量
    [[NSNotificationCenter defaultCenter] addObserverForName:kXBDownloadManagerNotification object:self.downloadManager queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSNumber *num = note.userInfo[kManagerNotificationKeyTaskNumber];
        self.downloadNum.title = num.stringValue;
        
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 按钮监听

- (IBAction)rewind:(id)sender {
    [self.web goBack];
}
- (IBAction)forward:(id)sender {
    [self.web goForward];
}
- (IBAction)refresh:(id)sender {
    [self.web reload];
}

- (IBAction)closeWebPage:(id)sender {
    if (self.webs.count > 0) {
        WKWebView *web = [self.webs lastObject];
        [web removeFromSuperview];
        [self.webs removeObject:web];
    }
}


#pragma mark - <WKNavigationDelegate>

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)navigationResponse.response;
//        XBINFOLOG(@"%@", response);
        if([response.allHeaderFields[@"Content-Type"] isEqualToString:@"application/octet-stream"] ||
           [response.allHeaderFields[@"Content-Type"] isEqualToString:@"application/x-apple-diskimage"]){
            
            XBINFOLOG(@"NSThread %@", [NSThread currentThread]);
            
            __weak typeof(self) wself = self;
            
            //"Content-Type"为二进制数据,创建下载任务,如果路径为nil，那么会存在默认的目录下
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
            //关闭当前请求
            decisionHandler(WKNavigationResponsePolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    XBINFOLOG(@"%s", __func__);
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler
{
    XBINFOLOG(@"%s", __func__);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}



#pragma mark - <WKUIDelegate>

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    WKWebView *web = [[WKWebView alloc] initWithFrame:self.web.bounds configuration:configuration];
    web.UIDelegate = self;
    web.navigationDelegate = self;
    [self.view addSubview:web];
    [self.webs addObject:web];
    return web;
}

@end
