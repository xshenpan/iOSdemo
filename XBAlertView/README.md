### XBAlertView集成了一些常用的弹窗功能
  
  ![动态示例](http://tu.wco.cc/images/2016/08/06/demo7.gif)
  
  - 在写一个小学习项目时发现系统的UIAlertController不具有类似输错密码的抖动效果
  - 于是自己参考网上的一些第三方框架写了一个自己的小框架
    - 参考了SCLAlertView、WCLPassWordView等框架
  
### 用法
  
#### 普通弹窗
  
  ```objc
    //创建弹窗控制器
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    //设置弹出进入动画
    alert.showAnimateType = XBAlertShowFromTop;
    //添加确定和取消按钮
    [alert addButtonWithTitle:@"取消" style:XBAlertButtonStyleGray actionBlock:nil];
    [alert addButtonWithTitle:@"确定" style:XBAlertButtonStyleBlue actionBlock:nil];
    //显示弹窗
    [alert showAlertView:self title:@"测试" subTitle:@"普通窗口"];
  ```
  
##### 带文本框的弹窗
  
  ```objc
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    alert.showAnimateType = XBAlertShowFromRight;
    //添加文本框
    XBAlertTextField *txt = [alert addTextFieldWithPlaceholder:@"请输入文字"];
    [alert addButtonWithTitle:@"取消" style:XBAlertButtonStyleGray actionBlock:nil];
    //block的返回值是弹窗退出动画，如果不适用该返回值则exitAnimateType值作为退出动画
    [alert addButtonWithTitle:@"确定" style:XBAlertButtonStyleBlue actionBlock:^XBAlertExitAnimate{
        NSLog(@"输入的文字是:%@", txt.text);
        return XBAlertExitRight;
    }];
    //设置子标题颜色
    alert.subTitleColor = [UIColor blueColor];
    [alert showAlertView:self title:@"文本框测试" subTitle:@"我是蓝色文字,我是蓝色文字,我是蓝色文字,我是蓝色文字"];
  
  ```
  
##### 设置密码文本框
  
  ```objc
  
    XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    alert.showAnimateType = XBAlertShowFromBottom;
    XBAlertTextField *txt = [alert addTextFieldWithPlaceholder:@"请输入密码"];
    //如果密码错误，再次输入密码前会将之前的密码清除
    txt.clearWhenRetry = YES;
    txt.secureTextEntry = YES;
    //如果密码输入错误，则文本框会显示的提示信息
    txt.retryPlaceholder = @"密码错误请重试";
    [alert addButtonWithTitle:@"取消" style:XBAlertButtonStyleGray actionBlock:nil];
    [alert addButtonWithTitle:@"确定" style:XBAlertButtonStyleBlue actionBlock:^XBAlertExitAnimate{
        //如果密码正确则退出弹窗
        if ([txt.text isEqualToString:@"123456"]) {
            return XBAlertExitRight;
        }
        //密码不正确则左右摇晃弹窗，不退出弹窗
        return XBAlertRetryLeftRightShake;
    }];
    //设置主标题颜色
    alert.titleColor = [UIColor redColor];
    [alert showAlertView:self title:@"输入密码" subTitle:@"测试密码:123456"];
  ```
  
#### 支付密码样式弹窗
  
  ```objc
  
   XBAlertViewController *alert = [[XBAlertViewController alloc] init];
    //添加支付密码样式文本框 密码长度为6 重试时清除原有密码，密码输入完成后会自动调动completeBlock
    [alert addPinFieldWithLength:6 completeBlock:^XBAlertExitAnimate(XBPinPasswordField *field) {
        if ([field.password isEqualToString:@"123456"]) {
            return XBAlertExitRight;
        }
        return XBAlertRetryLeftRightShake;
        
    }].clearWhenRetry = YES;
    
    //添加长度为4的密码弹窗，并由点击按钮去确认密码
    XBPinPasswordField *field = [alert addPinFieldWithLength:4 completeBlock:nil];
    field.clearWhenRetry = YES;
    [alert addButtonWithTitle:@"第二个密码确定" style:XBAlertButtonStyleBlue actionBlock:^XBAlertExitAnimate{
        if ([field.password isEqualToString:@"1234"]) {
            return XBAlertExitRight;
        }
        return XBAlertRetryUpDownShake;
    }];
    
    [alert showAlertView:self title:@"输入支付密码" subTitle:@"测试密码1:123456 \n测试密码2:1234"];
  
  ```
  
