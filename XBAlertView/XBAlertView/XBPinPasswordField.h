//
//  XBPinPasswordView.h
//  密码管家
//
//  Created by xshenpan on 16/8/5.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBAlertViewController.h"

@class XBPinPasswordField;
@protocol XBPinPasswordDelegate <NSObject>
@optional

- (void)XBPinPasswordDidChange:(XBPinPasswordField *)password;
- (void)XBPinPasswordDidComplete:(XBPinPasswordField *)password;
- (void)XBPinPasswordDidBegin:(XBPinPasswordField *)password;

@end

@interface XBPinPasswordField : UIView

- (instancetype)initWithCompeletBlock:(pinCompleteBlock)block;

/** 
 *  密码长度  3 <= pinLength <= 8
 */
@property (nonatomic, assign) NSUInteger pinLength;

/** 
 *  边框和中间的线的颜色
 */
@property (nonatomic, strong) UIColor *borderColor;

/** 
 *  圆点的颜色
 */
@property (nonatomic, strong) UIColor *circleColor;

/**
 *  密码,只接受数字,长度超过 pinLength会被截断
 */
@property (copy, nonatomic) NSString *password;

/** 
 *  代理
 */
@property (nonatomic, weak) id<XBPinPasswordDelegate> delegate;

/** 
 * 输入完成block,仅仅用来保存block
 */
@property (nonatomic, strong, readonly) pinCompleteBlock completeBlock;

/** 
 * 重试清空输入
 */
@property (nonatomic, assign) BOOL clearWhenRetry;


@end
