//
//  XBPopViewController.h
//  密码管家
//
//  Created by xshenpan on 16/8/1.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  按钮样式
 */
typedef NS_ENUM(NSInteger, XBAlertButtonStyle)
{
    XBAlertButtonStyleBlue,         //亮蓝色-白字
    XBAlertButtonStyleOrange,       //亮橙色-白字
    XBAlertButtonStyleGray,         //亮灰色-白字
    XBAlertButtonStyleRed,          //亮红色-白字
};
/**
 *  退出动画
 */
typedef NS_ENUM(NSInteger, XBAlertShowAnimate)
{
    XBAlertShowFadeIn,              //淡入
    XBAlertShowFromTop,
    XBAlertShowFromBottom,
    XBAlertShowFromLeft,
    XBAlertShowFromRight
};

/**
 *  退出动画
 */
typedef NS_ENUM(NSInteger, XBAlertExitAnimate)
{
    XBAlertNotExit,                 
    XBAlertExitNone,
    XBAlertExitFadeOut,             //淡出
    XBAlertExitBottom,              //从下面退出
    XBAlertExitTop,
    XBAlertExitLeft,
    XBAlertExitRight,
    //返回下面的效果AlertView不会消失
    XBAlertRetryNone = 100,         //需重试-无动画
    XBAlertRetryLeftRightShake,     //需重试-左右摇晃
    XBAlertRetryUpDownShake,        //需重试-上下摇晃
};

typedef NS_ENUM(NSInteger, XBAlertButtonShowDir)
{
    XBAlertButtonShowAuto,          //自动，3个及以下按钮垂直排布，否则水平排布
    XBAlertButtonShowVetical,       //按钮垂直排布   
    XBAlertButtonShowHorizontal,    //按钮水平排布
};

@class XBAlertTextField, XBPinPasswordField;

typedef XBAlertExitAnimate (^buttonActionBlock)(void);
typedef XBAlertExitAnimate (^pinCompleteBlock)(XBPinPasswordField *field);

@interface XBAlertViewController : UIViewController

/** 
 * 主标题颜色
 */
@property (nonatomic, strong) UIColor *titleColor;

/** 
 * 子标题颜色
 */
@property (nonatomic, strong) UIColor *subTitleColor;

/** 
 *  按钮布局方向
 *  见XBAlertButtonShowDir
 */
@property (nonatomic, assign) XBAlertButtonShowDir buttonDirection;

/** 
 *  控制弹窗出现的方式
 *  默认为 XBAlertShowFadeIn 效果
 */
@property (nonatomic, assign) XBAlertShowAnimate showAnimateType;
/**
 *  控制弹窗消失的方式
 *  默认为 XBAlertExitFadeOut 效果
 *  button block返回的退出方式优先级高
 */
@property (nonatomic, assign) XBAlertExitAnimate exitAnimateType;

/**
 *  只读属性,用于访问添加的textFiled
 */
@property (nonatomic, strong, readonly) NSArray<XBAlertTextField *> *textFields;

/**
 *  为AlertView添加一个按钮
 *  title   标题
 *  acion   按钮执行动作
 *          返回值决定退出的动作和动画
 *          block为nil == XBAlertExitFadeOut
 */
- (void)addButtonWithTitle:(NSString *)title style:(XBAlertButtonStyle)style actionBlock:(buttonActionBlock)acion;

/**
 *  为弹窗添加一个文本框
 *  placeholder 占位文字
 *  
 *  返回值：返回该文本框
 */
- (XBAlertTextField *)addTextFieldWithPlaceholder:(NSString *)placeholder;

/**
 *  为弹窗添加一个类似支付密码的文本框
 *  length 密码长度
 *
 *  返回值：返回该文本框
 */
- (XBPinPasswordField *)addPinFieldWithLength:(NSInteger)length completeBlock:(pinCompleteBlock) block;

/**
 *  显示弹窗
 *  vc          需要附加到的控制器，nil则创建新的window
 *  title       弹窗的主标题
 *  subTitle    弹窗的副标题
 */
- (void)showAlertView:(UIViewController *)vc title:(NSString *)title subTitle:(NSString *)subTitle;

@end
