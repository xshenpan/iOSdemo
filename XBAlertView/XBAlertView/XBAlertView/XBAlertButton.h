//
//  XBButton.h
//  密码管家
//
//  Created by xshenpan on 16/8/1.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBAlertViewController.h"

@interface XBAlertButton : UIButton

/** action block */
@property (nonatomic, copy) buttonActionBlock actionBlock;

@end
