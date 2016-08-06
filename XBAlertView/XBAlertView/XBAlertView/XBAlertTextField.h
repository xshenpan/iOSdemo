//
//  XBTextField.h
//  密码管家
//
//  Created by xshenpan on 16/8/1.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XBAlertTextField : UITextField

/**
 * 文本框重试的时候清楚其中的内容
 */
@property (nonatomic, assign) BOOL clearWhenRetry;
/**
 * 重试时显示的文本
 */
@property (nonatomic, copy) NSString *retryPlaceholder;
/** 
 * 重试提示文字颜色,默认为红色
 */
@property (nonatomic, strong) UIColor *retryColor;

@end
