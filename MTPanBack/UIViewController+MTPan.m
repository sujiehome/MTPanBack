//
//  UIViewController+MTPan.m
//  MTPanBackNavigationViewController
//
//  Created by suyuxuan on 16/3/16.
//  Copyright © 2016年 MonkTang. All rights reserved.
//

#import "UIViewController+MTPan.h"
#import <objc/runtime.h>

static void* kUnablePan = (void *)@"kPanEnable";

@implementation UIViewController (MTPan)

- (void)setPanUnable:(BOOL)panUnable
{
    objc_setAssociatedObject(self, kUnablePan, [NSNumber numberWithBool:panUnable], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)panUnable
{
    BOOL b = [objc_getAssociatedObject(self, kUnablePan) boolValue];
    return b;
}

@end
