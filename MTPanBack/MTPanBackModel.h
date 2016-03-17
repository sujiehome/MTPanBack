//
//  MTPanBackModel.h
//  MTPanBackNavigationViewController
//
//  Created by suyuxuan on 16/3/16.
//  Copyright © 2016年 MonkTang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTPanBackModel : NSObject

/** 无tabbarViewController */
@property (nonatomic, strong) UIImage *rootViewImage;
@property (nonatomic, assign) CGRect rootViewFrame;

/** 有tabBarViewController */
@property (nonatomic, strong) UIImage *tabBarViewImage;
@property (nonatomic, assign) CGRect tabBarViewFrame;

/** 导航栏 */
@property (nonatomic, strong) UIImage *navBarImage;

@end
