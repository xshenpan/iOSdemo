//
//  XBPinPasswordView.m
//  密码管家
//
//  Created by xshenpan on 16/8/5.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import "XBPinPasswordField.h"
#import "XBAlertViewHeader.h"

@interface XBPinPasswordField () <UIKeyInput>
{
    NSString *_password;
}
@property (assign, nonatomic) CGFloat marginLineToLine;
@property (strong, nonatomic) UIColor *backColor;
@property (strong, nonatomic) NSMutableString *text;

@end

@implementation XBPinPasswordField

- (instancetype)initWithCompeletBlock:(pinCompleteBlock)block
{
    self = [super init];
    if (self) {
        [super setBackgroundColor:[UIColor clearColor]];
        _backColor = [UIColor whiteColor];
        _borderColor = XBRGBColor(223, 223, 223);
        _circleColor = [UIColor blackColor];
        _pinLength = 4;
        _text = @"".mutableCopy;
        _completeBlock = block;
    }
    return self;
}

#pragma mark - Setter/Getter

- (void)setPinLength:(NSUInteger)pinLength
{
    if (pinLength < 3) {
        pinLength = 3;
    }else if (pinLength > 8) {
        pinLength = 8;
    }
    _pinLength = pinLength;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backColor = backgroundColor;
    [self setNeedsDisplay];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

- (void)setPassword:(NSString *)password
{
    if (password != nil) {
        if (password.length > _pinLength) {
            password = [password substringToIndex:_pinLength];
        }
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString*filtered = [[password componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if (![password isEqualToString:filtered]){
            [[NSException exceptionWithName:@"<XBPinPasswordField>无效参数" reason:@"只支持数字密码" userInfo:nil] raise];
            return;
        }
        _text = password.mutableCopy;
    }else{
        _text = @"".mutableCopy;
    }
    [self setNeedsDisplay];
    
}

- (NSString *)password
{
    return _text;
}

#pragma mark - 绘图

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //绘制边框
    UIBezierPath *border = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:5];
    [_backColor set];
    [border fill];
    [_borderColor set];
    [border stroke];
    
    //绘制中间的线
    _marginLineToLine = rect.size.width / _pinLength;
    for (NSInteger i = 0; i < _pinLength - 1; ++i) {
        CGContextMoveToPoint(ctx, _marginLineToLine * (i + 1), 0);
        CGContextAddLineToPoint(ctx, _marginLineToLine * (i + 1), rect.size.height);
        CGContextStrokePath(ctx);
    }
    
    //绘制圆点
    [_circleColor set];
    CGFloat y = rect.size.height/2.0;
    CGFloat x = _marginLineToLine/2.0;
    CGFloat radius = rect.size.height * 0.2;
    for (NSInteger i = 0; i < _text.length; ++i) {
        CGContextAddArc(ctx, x, y, radius, 0, M_PI * 2, YES);
        x += _marginLineToLine;
        CGContextFillPath(ctx);
    }
}

#pragma mark - UIKeyInput代理/键盘处理

- (BOOL)canBecomeFirstResponder
{
    if ([_delegate respondsToSelector:@selector(XBPinPasswordDidBegin:)]) {
        [_delegate XBPinPasswordDidBegin:self];
    }
    return YES;
}

- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypeNumberPad;
}

- (BOOL)hasText
{
    return _text.length > 0;
}

- (void)insertText:(NSString *)text
{
    if (_text.length < _pinLength) {
        [_text appendString:text];
        if ([_delegate respondsToSelector:@selector(XBPinPasswordDidChange:)]) {
            [_delegate XBPinPasswordDidChange:self];
        }
        if (_text.length == _pinLength) {
            if ([_delegate respondsToSelector:@selector(XBPinPasswordDidComplete:)]) {
                [_delegate XBPinPasswordDidComplete:self];
            }
        }
        [self setNeedsDisplay];
    }
}

- (void)deleteBackward
{
    if (_text.length > 0) {
        [_text deleteCharactersInRange:NSMakeRange(_text.length-1, 1)];
        if ([_delegate respondsToSelector:@selector(XBPinPasswordDidChange:)]) {
            [_delegate XBPinPasswordDidChange:self];
        }
        [self setNeedsDisplay];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

@end
