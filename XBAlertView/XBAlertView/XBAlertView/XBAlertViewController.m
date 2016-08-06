//
//  XBAlertViewController.m
//  密码管家
//
//  Created by xshenpan on 16/8/1.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#define MAS_SHORTHAND_GLOBALS

#import "XBAlertViewController.h"
#import "XBAlertTextField.h"
#import "XBAlertButton.h"
#import "XBPinPasswordField.h"
#import "XBAlertViewHeader.h"
#import "Masonry.h"

@interface XBAlertViewController () <UITextFieldDelegate, XBPinPasswordDelegate>

@property (strong, nonatomic) NSMutableArray<XBAlertTextField*> *inputs;
@property (strong, nonatomic) NSMutableArray<XBPinPasswordField *> *pinInputs;
@property (strong, nonatomic) NSMutableArray<XBAlertButton *> *buttons;
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIFont *subTitleFont;
@property (strong, nonatomic) UIFont *buttonTitleFont;
@property (strong, nonatomic) UIWindow *alertWindow;
@property (weak, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *subTitleLabel;
@property (weak, nonatomic) UIView *alertView;
@property (assign, nonatomic) BOOL showing;
@property (assign, nonatomic) BOOL keyboardVisible;
@property (assign, nonatomic) BOOL newWindow;

@end

static CGFloat const kNormalMargin = 10.0;

@implementation XBAlertViewController

- (instancetype)init
{
    if (self = [super init]) {
        [self setupAlertView];
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    [self layoutAlertViews];
    [super viewWillLayoutSubviews];
}

- (void)setupAlertView
{
    _titleFont = [UIFont fontWithName:@"HelveticaNeue" size:18.0];
    _subTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    _buttonTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    UIView *alertView = [[UIView alloc] init];
    [self.view addSubview:alertView];
    _alertView = alertView;
    _alertView.layer.masksToBounds = YES;
    _alertView.layer.cornerRadius = 8.0;
    _alertView.backgroundColor = XBRGBAColor(255, 255, 255, 0.9);
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self.alertView addSubview:titleLabel];
    _titleLabel = titleLabel;
    _titleLabel.font = _titleFont;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    [self.alertView addSubview:subTitleLabel];
    _subTitleLabel = subTitleLabel;
    _subTitleLabel.font = _subTitleFont;
    _subTitleLabel.numberOfLines = 0;
    _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.view.backgroundColor = XBRGBAColor(0, 0, 0, 0.5);
    
    _showAnimateType = XBAlertShowFadeIn;
    _buttonDirection = XBAlertButtonShowAuto;
    _exitAnimateType = XBAlertExitFadeOut;
}

#pragma mark - 添加按钮

- (XBAlertButton *)addButtonWithTitle:(NSString *)title
{
    XBAlertButton *btn = [XBAlertButton buttonWithType:UIButtonTypeCustom];
    [self.buttons addObject:btn];
    [self.alertView addSubview:btn];
    btn.titleLabel.font = _buttonTitleFont;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)addButtonWithTitle:(NSString *)title style:(XBAlertButtonStyle)style actionBlock:(XBAlertExitAnimate (^)(void))acion
{
    XBAlertButton *btn = [self addButtonWithTitle:title];
    btn.actionBlock = acion;
    
    switch (style) {
        case XBAlertButtonStyleBlue: {
            btn.backgroundColor =  XBRGBColor(83, 175, 220);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
        case XBAlertButtonStyleOrange: {
            btn.backgroundColor =  XBRGBColor(255, 209, 16);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
        case XBAlertButtonStyleGray: {
            btn.backgroundColor =  XBRGBColor(209, 209, 209);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
        case XBAlertButtonStyleRed: {
            btn.backgroundColor =  XBRGBColor(233, 99, 76);
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
    }
    
}

- (void)buttonClick:(XBAlertButton *)btn
{
    XBAlertExitAnimate exitAnimate = _exitAnimateType;
    if (btn.actionBlock != nil) {
        exitAnimate = btn.actionBlock();
    }
    [self dismissOrRetry:exitAnimate];
}

#pragma mark - 添加文本框

- (XBAlertTextField *)addTextFieldWithPlaceholder:(NSString *)placeholder
{
    XBAlertTextField *txt = [[XBAlertTextField alloc] init];
    [self.inputs addObject:txt];
    [_alertView addSubview:txt];
    txt.placeholder = placeholder;
    txt.borderStyle = UITextBorderStyleRoundedRect;
    txt.delegate = self;
    txt.returnKeyType = UIReturnKeyDone;
    txt.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    
    if (_inputs.count > 1) {
        XBAlertTextField *txtField = _inputs[_inputs.count-2];
        txtField.returnKeyType = UIReturnKeyNext;
    }
    
    return txt;
}

#pragma mark - 添加Pin密码框

- (XBPinPasswordField *)addPinFieldWithLength:(NSInteger)length completeBlock:(pinCompleteBlock) block
{
    XBPinPasswordField *pin = [[XBPinPasswordField alloc] initWithCompeletBlock:block];
    [self.pinInputs addObject:pin];
    [self.alertView addSubview:pin];
    pin.pinLength = length;
    pin.delegate = self;
    pin.clearWhenRetry = YES;
    return pin;
}

#pragma mark - 显示/隐藏/重试及其动画

- (void)showAlertView:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle
{
    if (_showing) return;

    if (vc) {
        _newWindow = NO;
        self.view.alpha = 0.1;
        _currentViewController = vc;
        [_currentViewController addChildViewController:self];
        [_currentViewController.view addSubview:self.view];
        
    }else {
        _newWindow = YES;

        UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:XBScreen];
        alertWindow.windowLevel = UIWindowLevelAlert;
        alertWindow.backgroundColor = [UIColor clearColor];
        alertWindow.rootViewController = self;
        self.alertWindow = alertWindow;
    }
    
    _titleLabel.text = title;
    _subTitleLabel.text = subTitle;
    
    if (_newWindow) [self.alertWindow makeKeyAndVisible];
    
    [self animateShowView];
    _showing = YES;
}

- (void)layoutAlertViews
{
    //布局AlertView
    [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        //防止有导航栏位置不对
        make.center.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.8);
    }];
    
    UIView *refView = _titleLabel;
    //布局标题
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_alertView).offset(kNormalMargin);
        make.right.equalTo(_alertView).offset(-kNormalMargin);
        make.top.equalTo(_alertView).offset(kNormalMargin);
    }];
    if (_subTitleLabel.text.length > 0) {
        [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(kNormalMargin);
            make.left.equalTo(_alertView).offset(kNormalMargin);
            make.right.equalTo(_alertView).offset(-kNormalMargin);
        }];
        refView = _subTitleLabel;
    }
    
    //布局Pin输入框
    if (_pinInputs && _pinInputs.count) {
        XBPinPasswordField *pin;
        for (NSInteger i = 0; i < _pinInputs.count; ++i) {
            pin = _pinInputs[i];
            [pin mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_alertView).offset(kNormalMargin);
                make.right.equalTo(_alertView).offset(-kNormalMargin);
                make.height.equalTo(30);
                if (i == 0) {
                    make.top.equalTo(refView.mas_bottom).offset(kNormalMargin);
                }else{
                    make.top.equalTo(_pinInputs[i-1].mas_bottom).offset(kNormalMargin);
                }
            }];
        }
        refView = pin;
    }
    
    //布局文本框
    if (_inputs && _inputs.count) {
        XBAlertTextField *txt;
        for (NSInteger i = 0; i < _inputs.count; ++i) {
            txt = _inputs[i];
            [txt mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_alertView).offset(kNormalMargin);
                make.right.equalTo(_alertView).offset(-kNormalMargin);
                make.height.equalTo(30);
                if (i == 0) {
                    make.top.equalTo(refView.mas_bottom).offset(kNormalMargin);
                }else{
                    make.top.equalTo(_inputs[i-1].mas_bottom).offset(kNormalMargin);
                }
            }];
        }
        refView = txt;
    }
    
    //布局按钮
    if (_buttons && _buttons.count) {
        if (_buttonDirection == XBAlertButtonShowAuto) {
            _buttonDirection = XBAlertButtonShowVetical;
            if (_buttons.count > 3) {
                _buttonDirection = XBAlertButtonShowHorizontal;
            }
        }
        //垂直布局
        if (_buttonDirection == XBAlertButtonShowVetical) {
            XBAlertButton *btn;
            for (NSInteger i = 0; i < _buttons.count; ++i) {
                btn = _buttons[i];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(refView.mas_bottom).offset(kNormalMargin);
                    make.height.equalTo(30);
                    if (i == 0) {
                        make.left.equalTo(_alertView).offset(kNormalMargin);
                    }else{
                        make.width.equalTo(_buttons[0]);
                        make.left.equalTo(_buttons[i-1].mas_right).offset(5);
                    }
                }];
            }
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_alertView).offset(-kNormalMargin);
            }];
            refView = _buttons[0];
            
        //水平布局
        }else if (_buttonDirection == XBAlertButtonShowHorizontal) {
            XBAlertButton *btn;
            for (NSInteger i = 0; i < _buttons.count; ++i) {
                btn = _buttons[i];
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(_alertView).offset(kNormalMargin);
                    make.right.equalTo(_alertView).offset(-kNormalMargin);
                    if (i == 0) {
                        make.top.equalTo(refView.mas_bottom).offset(kNormalMargin);
                    }else{
                        make.top.equalTo(_buttons[i-1].mas_bottom).offset(kNormalMargin);
                    }
                }];
            }
            refView = btn;
        }

    }

    //布局AlertView的底部
    [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(refView.mas_bottom).offset(kNormalMargin);
    }];
}

- (void)animateShowView
{
    switch (_showAnimateType) {
        case XBAlertShowFadeIn: {
            [self fadeInAnimate];
            break;
        }
        case XBAlertShowFromTop: {
            [self fromTopAnimate];
            break;
        }
        case XBAlertShowFromBottom: {
            [self fromBottomAnimate];
            break;
        }
        case XBAlertShowFromLeft: {
            [self fromLeftAnimate];
            break;
        }
        case XBAlertShowFromRight: {
            [self fromRightAnimate];
            break;
        }
    }
}

- (void)dismissOrRetry:(XBAlertExitAnimate)animate
{
    switch (animate) {
        case XBAlertExitNone: {
            [self exitNone];
        }
        case XBAlertExitFadeOut: {
            [self exitFadeOut];
            break;
        }
        case XBAlertExitBottom: {
            [self exitToBottom];
            break;
        }
        case XBAlertExitTop: {
            [self exitToTop];
            break;
        }
        case XBAlertExitLeft: {
            [self exitToLeft];
            break;
        }
        case XBAlertExitRight: {
            [self exitToRight];
            break;
        }
        case XBAlertRetryNone: {
            [self retryNone];
            break;
        }
        case XBAlertRetryLeftRightShake:
        case XBAlertRetryUpDownShake: {
            [self shakeAnimation:animate];
            break;
        }
        case XBAlertNotExit: break;
    }
}

/**
 *  出场/退场/重试动画
 */

- (void)fadeInAnimate
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [self registerKeyboardNotification];
    }];
}
- (void)fromTopAnimate
{
    _alertView.transform = CGAffineTransformMakeTranslation(0, -XBScreenHeight);
    self.view.alpha = 1.0;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self registerKeyboardNotification];
    }];
}
- (void)fromBottomAnimate
{
    _alertView.transform = CGAffineTransformMakeTranslation(0, XBScreenHeight);
    self.view.alpha = 1.0;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self registerKeyboardNotification];
    }];
}
- (void)fromLeftAnimate
{
    _alertView.transform = CGAffineTransformMakeTranslation(-XBScreenWidth, 0);
    self.view.alpha = 1.0;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self registerKeyboardNotification];
    }];
}
- (void)fromRightAnimate
{
    _alertView.transform = CGAffineTransformMakeTranslation(XBScreenWidth, 0);
    self.view.alpha = 1.0;
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self registerKeyboardNotification];
    }];
}
- (void)exitNone
{
    [self removeViewFromController];
}
- (void)exitFadeOut
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeViewFromController];
    }];
}
- (void)exitToBottom
{
    [UIView animateWithDuration:0.3 animations:^{
        _alertView.transform = CGAffineTransformTranslate(_alertView.transform, 0, XBScreenHeight);
    } completion:^(BOOL finished) {
        [self removeViewFromController];
    }];
}
- (void)exitToTop
{
    [UIView animateWithDuration:0.3 animations:^{
        _alertView.transform = CGAffineTransformTranslate(_alertView.transform, 0, -XBScreenHeight);
    } completion:^(BOOL finished) {
        [self removeViewFromController];
    }];
}
- (void)exitToLeft
{
    [UIView animateWithDuration:0.3 animations:^{
        _alertView.transform = CGAffineTransformTranslate(_alertView.transform, -XBScreenWidth, 0);
    } completion:^(BOOL finished) {
        [self removeViewFromController];
    }];
}
- (void)exitToRight
{
    [UIView animateWithDuration:0.3 animations:^{
        _alertView.transform = CGAffineTransformTranslate(_alertView.transform, XBScreenWidth, 0);
    } completion:^(BOOL finished) {
        [self removeViewFromController];
    }];
}
- (void)retryNone
{
    for (XBAlertTextField *txt in _inputs) {
        if (txt.clearWhenRetry) {
            txt.text = nil;
        }
        if (txt.retryPlaceholder.length > 0) {
            txt.placeholder = txt.retryPlaceholder;
            [txt setValue:txt.retryColor forKeyPath:@"_placeholderLabel.textColor"];
        }
    }
    
    for (XBPinPasswordField *txt in _pinInputs) {
        if (txt.clearWhenRetry) {
            txt.password = nil;
        }
    }
    
}
- (void)shakeAnimation:(XBAlertExitAnimate)animate
{
    [self retryNone];
    // 获取到当前的View
    CALayer *viewLayer = _alertView.layer;
    // 获取当前View的位置
    CGPoint position = viewLayer.position;
    // 移动的两个终点位置
    CGPoint start = CGPointMake(position.x + 10, position.y);
    CGPoint end = CGPointMake(position.x - 10, position.y);
    
    if (animate == XBAlertRetryUpDownShake) {
        start = CGPointMake(position.x, position.y + 10);
        end = CGPointMake(position.x, position.y - 10);
    }
    
    // 设置动画对应的layer属性
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    // 设置开始位置
    [animation setFromValue:[NSValue valueWithCGPoint:start]];
    // 设置结束位置
    [animation setToValue:[NSValue valueWithCGPoint:end]];
    // 设置自动反转
    [animation setAutoreverses:YES];
    // 设置时间
    [animation setDuration:.05];
    // 设置次数
    [animation setRepeatCount:3];
    // 添加上动画
    [viewLayer addAnimation:animation forKey:nil];
    
}

- (void)removeViewFromController
{
    if (_newWindow) {
        [self.view endEditing:YES];
        self.alertWindow.hidden = YES;
        self.alertWindow = nil;
    }else{
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

#pragma mark - Setter/Getter

- (NSMutableArray<XBAlertButton *> *)buttons
{
    if (_buttons == nil) {
        _buttons = @[].mutableCopy;
    }
    return _buttons;
}

- (NSArray<XBAlertTextField *> *)textFields
{
    return _inputs;
}

- (NSMutableArray<XBAlertTextField *> *)inputs
{
    if (_inputs == nil) {
        _inputs = @[].mutableCopy;
    }
    return _inputs;
}

- (NSMutableArray<XBPinPasswordField *> *)pinInputs
{
    if (_pinInputs == nil) {
        _pinInputs = @[].mutableCopy;
    }
    return _pinInputs;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    _titleLabel.textColor = titleColor;
}

- (void)setSubTitleColor:(UIColor *)subTitleColor
{
    _subTitleColor = subTitleColor;
    _subTitleLabel.textColor = subTitleColor;
}

#pragma mark - 触摸事件
/** 阻止事件的传递 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - UITextField代理/键盘通知
/**
 *  控制文本框输入
 */
- (BOOL)textFieldShouldReturn:(XBAlertTextField *)textField
{
    //如果是最后一个文本框点击了enter则退出编辑
    if (textField == [_inputs lastObject]) {
        [textField resignFirstResponder];
    }else{
        //不是最后一个文本框，跳到下一个文本框
        NSUInteger index = [_inputs indexOfObject:textField];
        XBAlertTextField *txt = _inputs[index+1];
        [txt becomeFirstResponder];
    }
    return YES;
}

- (void)registerKeyboardNotification
{
    if (_inputs.count > 0 || _pinInputs.count > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        if (_inputs.count > 0) {
            [_inputs[0] becomeFirstResponder];
        }else{
            [_pinInputs[0] becomeFirstResponder];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)note
{
    if (_keyboardVisible) return;
    
    CGFloat duration = [note.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGPoint endPostion = [note.userInfo[@"UIKeyboardCenterEndUserInfoKey"] CGPointValue];
    CGFloat offset = XBScreenHeight - endPostion.y;
    
    [UIView animateWithDuration:duration animations:^{
        _alertView.transform = CGAffineTransformMakeTranslation(0, -offset);
    }];
    _keyboardVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)note
{
    if (!_keyboardVisible) return;
    
    CGFloat duration = [note.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        _alertView.transform = CGAffineTransformIdentity;
    }];
    _keyboardVisible = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s", __func__);
}

#pragma mark - XBPinPasswordDelegate

- (void)XBPinPasswordDidComplete:(XBPinPasswordField *)password
{
    if (password.completeBlock) {
        XBAlertExitAnimate exitAnimate = _exitAnimateType;
        exitAnimate = password.completeBlock(password);
        [self dismissOrRetry:exitAnimate];
    }
}

@end
