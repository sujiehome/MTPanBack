//
//  MTPanGestureRecognizer.h
//  MTPanBackNavigationViewController
//
//  Created by suyuxuan on 16/3/15.
//  Copyright © 2016年 MonkTang. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 手势扩展类 */
@interface MTPanGestureRecognizer : UIPanGestureRecognizer

/** 触碰发生时间戳 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/** 获取手指起始触控屏幕坐标点 */
@property (nonatomic, assign) CGPoint beginLocation;

/** 触碰事件 */
@property (nonatomic, strong) UIEvent *event;

/** 坐标系转换 */
- (CGPoint)beganLocationInView:(UIView *)view;

@end
