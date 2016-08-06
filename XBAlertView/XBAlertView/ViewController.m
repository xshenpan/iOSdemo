//
//  ViewController.m
//  XBAlertView
//
//  Created by xshenpan on 16/8/6.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "ViewController.h"
#import "XBAlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  普通样式
 */
- (IBAction)normal:(id)sender {
    
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    alert.showAnimateType = XBAlertShowFromTop;
    [alert addButtonWithTitle:@"取消" style:XBAlertButtonStyleGray actionBlock:nil];
    [alert addButtonWithTitle:@"确定" style:XBAlertButtonStyleBlue actionBlock:nil];
    
    [alert showAlertView:self title:@"测试" subTitle:@"普通窗口"];

}

/**
 *  多个按钮水平布置
 */
- (IBAction)moreButtonHorizontal:(id)sender {
    
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    alert.buttonDirection = XBAlertButtonShowVetical;
    [alert addButtonWithTitle:@"按钮1" style:XBAlertButtonStyleGray actionBlock:nil];
    [alert addButtonWithTitle:@"按钮2" style:XBAlertButtonStyleBlue actionBlock:^XBAlertExitAnimate{
        return XBAlertExitNone;
    }];
    [alert addButtonWithTitle:@"按钮3" style:XBAlertButtonStyleOrange actionBlock:^XBAlertExitAnimate{
        return XBAlertExitBottom;
    }];
    [alert addButtonWithTitle:@"按钮4" style:XBAlertButtonStyleRed actionBlock:^XBAlertExitAnimate{
        return XBAlertExitTop;
    }];
    
    [alert showAlertView:self title:@"多按钮测试" subTitle:@"水平排布"];
}

/**
 *  多个按钮垂直布置
 */
- (IBAction)moreButtonVertical:(id)sender {
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    alert.showAnimateType = XBAlertShowFromLeft;
    [alert addButtonWithTitle:@"按钮1" style:XBAlertButtonStyleGray actionBlock:nil];
    [alert addButtonWithTitle:@"按钮2" style:XBAlertButtonStyleBlue actionBlock:^XBAlertExitAnimate{
        return XBAlertExitNone;
    }];
    [alert addButtonWithTitle:@"按钮3" style:XBAlertButtonStyleOrange actionBlock:^XBAlertExitAnimate{
        return XBAlertExitBottom;
    }];
    [alert addButtonWithTitle:@"按钮4" style:XBAlertButtonStyleRed actionBlock:^XBAlertExitAnimate{
        return XBAlertExitTop;
    }];
    
    [alert showAlertView:self title:@"多按钮测试" subTitle:@"垂直排布"];
}

/**
 *  具有文本框的弹窗
 */
- (IBAction)textField:(id)sender {
    
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    alert.showAnimateType = XBAlertShowFromRight;
    XBAlertTextField *txt = [alert addTextFieldWithPlaceholder:@"请输入文字"];
    [alert addButtonWithTitle:@"取消" style:XBAlertButtonStyleGray actionBlock:nil];
    [alert addButtonWithTitle:@"确定" style:XBAlertButtonStyleBlue actionBlock:^XBAlertExitAnimate{
        NSLog(@"输入的文字是:%@", txt.text);
        return XBAlertExitRight;
    }];
    alert.subTitleColor = [UIColor blueColor];
    [alert showAlertView:self title:@"文本框测试" subTitle:@"我是蓝色文字,我是蓝色文字,我是蓝色文字,我是蓝色文字"];
}

/**
 *  密码文本框
 */
- (IBAction)securityField:(id)sender {
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    alert.showAnimateType = XBAlertShowFromBottom;
    XBAlertTextField *txt = [alert addTextFieldWithPlaceholder:@"请输入密码"];
    txt.clearWhenRetry = YES;
    txt.secureTextEntry = YES;
    txt.retryPlaceholder = @"密码错误请重试";
    [alert addButtonWithTitle:@"取消" style:XBAlertButtonStyleGray actionBlock:nil];
    [alert addButtonWithTitle:@"确定" style:XBAlertButtonStyleBlue actionBlock:^XBAlertExitAnimate{
        if ([txt.text isEqualToString:@"123456"]) {
            return XBAlertExitRight;
        }
        return XBAlertRetryLeftRightShake;
    }];
    alert.titleColor = [UIColor redColor];
    [alert showAlertView:self title:@"输入密码" subTitle:@"测试密码:123456"];
}

/**
 *  类似支付宝的密码界面
 */
- (IBAction)payPassword:(id)sender {
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    
    [alert addPinFieldWithLength:6 completeBlock:^XBAlertExitAnimate(XBPinPasswordField *field) {
        if ([field.password isEqualToString:@"123456"]) {
            return XBAlertExitRight;
        }
        return XBAlertRetryLeftRightShake;
        
    }].clearWhenRetry = YES;
    
    XBPinPasswordField *field = [alert addPinFieldWithLength:4 completeBlock:nil];
    field.clearWhenRetry = YES;
    [alert addButtonWithTitle:@"第二个密码确定" style:XBAlertButtonStyleBlue actionBlock:^XBAlertExitAnimate{
        if ([field.password isEqualToString:@"1234"]) {
            return XBAlertExitRight;
        }
        return XBAlertRetryUpDownShake;
    }];
    
    [alert showAlertView:self title:@"输入支付密码" subTitle:@"测试密码1:123456 \n测试密码2:1234"];
}

/**
 *  大杂烩
 */
- (IBAction)everything:(id)sender {
    
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    alert.buttonDirection = XBAlertButtonShowVetical;
    [alert addButtonWithTitle:@"按钮1" style:XBAlertButtonStyleGray actionBlock:nil];
    [alert addButtonWithTitle:@"按钮2" style:XBAlertButtonStyleBlue actionBlock:^XBAlertExitAnimate{
        return XBAlertExitNone;
    }];
    [alert addButtonWithTitle:@"按钮3" style:XBAlertButtonStyleOrange actionBlock:^XBAlertExitAnimate{
        return XBAlertExitBottom;
    }];
    [alert addButtonWithTitle:@"按钮4" style:XBAlertButtonStyleRed actionBlock:^XBAlertExitAnimate{
        return XBAlertExitTop;
    }];
    
    [alert addTextFieldWithPlaceholder:@"文本框1"];
    [alert addTextFieldWithPlaceholder:@"文本框2"];
    
    [alert addPinFieldWithLength:3 completeBlock:nil];
    [alert addPinFieldWithLength:4 completeBlock:nil];
    [alert addPinFieldWithLength:5 completeBlock:nil];
    [alert addPinFieldWithLength:6 completeBlock:nil];
    
    [alert showAlertView:self title:@"大杂烩" subTitle:@"这是一段测试文字,这是一段测试文字,这是一段测试文字,这是一段测试文字,这是一段测试文字"];
}


@end
