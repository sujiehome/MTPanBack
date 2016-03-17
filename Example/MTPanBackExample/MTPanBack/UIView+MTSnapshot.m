//
//  UIView+MTSnapshot.m
//  MTPanBackNavigationViewController
//
//  Created by suyuxuan on 16/3/15.
//  Copyright © 2016年 MonkTang. All rights reserved.
//

#import "UIView+MTSnapshot.h"

@implementation UIView (MTSnapshot)

- (UIImage *)snapshot
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}


@end
