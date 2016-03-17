//
//  MTPanGestureRecognizer.m
//  MTPanBackNavigationViewController
//
//  Created by suyuxuan on 16/3/15.
//  Copyright © 2016年 MonkTang. All rights reserved.
//

#import "MTPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation MTPanGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //获取手指起始触控屏幕坐标点
    self.beginLocation = [touch locationInView:self.view];
    //获取事件
    self.event = event;
    //获取触碰发生时间戳
    self.timestamp = event.timestamp;
    
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStatePossible && event.timestamp - self.timestamp > 0.3) {
        //未识别手势 或 手指停留事件超过0.3秒
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)reset
{
    //重置
    self.timestamp = 0;
    self.beginLocation = CGPointZero;
    self.event = nil;
    [super reset];
}

- (CGPoint)beganLocationInView:(UIView *)view
{
    //将view坐标系中的点转换为self.view(手势作用的view)坐标系中的点
    return [view convertPoint:self.beginLocation fromView:self.view];
}

@end
