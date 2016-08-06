//
//  XBAlertViewHeader.h
//  XBAlertView
//
//  Created by xshenpan on 16/8/6.
//  Copyright © 2016年 xshenpan. All rights reserved.
//

#ifndef XBAlertViewHeader_h
#define XBAlertViewHeader_h

#define XBScreen ([UIScreen mainScreen].bounds)
#define XBScreenHeight (XBScreen.size.height)
#define XBScreenWidth (XBScreen.size.width)
#define XBRGBAColor(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define XBRGBColor(r,g,b) XBRGBAColor(r,g,b,1.0f)

#endif /* XBAlertViewHeader_h */
