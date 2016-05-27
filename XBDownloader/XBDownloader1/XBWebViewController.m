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
        NSLog(@"%@", response);
        if([response.allHeaderFields[@"Content-Type"] isEqualToString:@"application/octet-stream"] ||
           [response.allHeaderFields[@"Content-Type"] isEqualToString:@"application/x-apple-diskimage"]){
            
            
            //"Content-Type"为二进制数据,创建下载任务,如果路径为nil，那么会存在默认的目录下
            [self.downloadManager addDownloadTaskWithUrl:response.URL.absoluteString andRelativePath:nil taskExistReload:nil];
            //关闭当前请求
            decisionHandler(WKNavigationResponsePolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"%s", __func__);
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"%s", __func__);
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"%s", __func__);
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%s %@", __func__, error);
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"%s", __func__);
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"%s", __func__);
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%s", __func__);
}

/*! @abstract Invoked when the web view needs to respond to an authentication challenge.
 @param webView The web view that received the authentication challenge.
 @param challenge The authentication challenge.
 @param completionHandler The completion handler you must invoke to respond to the challenge. The
 disposition argument is one of the constants of the enumerated type
 NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
 the credential argument is the credential to use, or nil to indicate continuing without a
 credential.
 @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler
{
    NSLog(@"%s", __func__);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView NS_AVAILABLE(10_11, 9_0)
{
    NSLog(@"%s", __func__);
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
