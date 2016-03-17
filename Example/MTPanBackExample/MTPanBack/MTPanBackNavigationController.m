//
//  MTPanBackNavigationController.m
//  MTPanBackNavigationViewController
//
//  Created by suyuxuan on 16/3/15.
//  Copyright © 2016年 MonkTang. All rights reserved.
//

#import "MTPanBackNavigationController.h"
#import "MTPanGestureRecognizer.h"
#import "UIView+MTSnapshot.h"
#import <objc/runtime.h>
#import "MTPanBackModel.h"
#import "UIViewController+MTPan.h"

@interface MTPanBackNavigationController ()<UIGestureRecognizerDelegate>

/** 滑动手势 */
@property (nonatomic, strong) MTPanGestureRecognizer *mtPanGes;

/** 图片缓存 */
@property (nonatomic, strong) NSMutableArray *imageStack;

/** 最后一个vc快照 */
@property (nonatomic, strong) UIImageView *lastVCSnapshot;

/** 最后一个覆盖图 */
@property (nonatomic, strong) UIView *lastOverlayView;

/** 最后一个导航栏快照 */
@property (nonatomic, strong) UIImageView *lastNavBarSnapshot;

/** 视图offset */
@property (nonatomic, assign) CGFloat showViewOffset;

/** 视图offset比例 */
@property (nonatomic, assign) CGFloat showViewOffsetScale;

/** 导航栏背景图 */
@property (weak, nonatomic) UIView *barBackgroundView;

@end

@implementation MTPanBackNavigationController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mtPanGes];
    [self lastVCSnapshot];
    [self lastNavBarSnapshot];
    [self lastOverlayView];
    [self imageStack];
    
    //显示快照比例
    self.showViewOffsetScale = 1 / 3.0;
    self.showViewOffset = self.showViewOffsetScale * self.view.frame.size.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - method
- (void)navBarTransitionWithAlpha:(CGFloat)alpha
{
    UINavigationItem *topItem = self.navigationBar.topItem;
    UIView *titleView = topItem.titleView;
    if (!titleView) {
        //没有自定义titleView
        UIView *defaultTitleView = nil;
        @try {
            //kvc 获取默认titleView
            defaultTitleView = [topItem valueForKey:@"_defaultTitleView"];
        }
        @catch (NSException *exception) {
            defaultTitleView = nil;
        }
        
        titleView = defaultTitleView;
    }
    titleView.alpha = alpha;
    
    
    UIView *backButton = self.navigationBar.backItem.backBarButtonItem.customView;
    if (!backButton) {
        //没有自定义返回按钮
        UIView *defaultBackButton = nil;
        @try {
            //kvc 获取默认返回按钮
            /**
             TODO:
             存在bug  更改alpha时，只对默认返回按钮的字有效果，对箭头并无效果。
             */
            defaultBackButton = [self.navigationBar.backItem valueForKey:@"_backButtonView"];
        }
        @catch (NSException *exception) {
            defaultBackButton = nil;
        }
        
        backButton = defaultBackButton;
    }
    
    backButton.alpha = alpha;
    topItem.leftBarButtonItem.customView.alpha = alpha;
    topItem.rightBarButtonItem.customView.alpha = alpha;
}

- (UIImage *)barSnapshot
{
    //为去掉navbar多余背景
    self.barBackgroundView.hidden = YES;
    UIImage *viewImage = [self.navigationBar snapshot];
    self.barBackgroundView.hidden = NO;
    return viewImage;
}

- (UIView *)barBackgroundView
{
    if (_barBackgroundView) return _barBackgroundView;
    
    for (UIView *subview in self.navigationBar.subviews) {
        if (!subview.hidden && subview.frame.size.height >= self.navigationBar.frame.size.height
            && subview.frame.size.width >= self.navigationBar.frame.size.width) {
            _barBackgroundView = subview;
            break;
        }
    }
    return _barBackgroundView;
}

#pragma mark - core
- (void)panGes:(MTPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            MTPanBackModel *model = [self.imageStack lastObject];
            UIImage *viewImage;
            CGRect rect;
            
            if (self.tabBarController == nil) {
                viewImage = model.rootViewImage;
                rect = model.rootViewFrame;
            }else
            {
                viewImage = model.tabBarViewImage;
                rect = model.tabBarViewFrame;
            }
            
            self.lastVCSnapshot.image = viewImage;
            self.lastVCSnapshot.frame = rect;
            
            self.lastVCSnapshot.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,
                                                                       - self.showViewOffset,
                                                                       0);
            //添加到最底层
            [self.visibleViewController.view.superview insertSubview:self.lastVCSnapshot
                                                             atIndex:0];
            
            //处理navigationBar
            self.lastNavBarSnapshot.image = model.navBarImage;
            self.lastNavBarSnapshot.frame = self.navigationBar.bounds;
            self.lastNavBarSnapshot.alpha = 0;
            [self.navigationBar addSubview:self.lastNavBarSnapshot];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translationPoint = [self.mtPanGes translationInView:self.view];
            if (translationPoint.x < 0) translationPoint.x = 0;
            if (translationPoint.x > 320) translationPoint.x = 320;
            
            float f = translationPoint.x / self.view.frame.size.width;
            [self navBarTransitionWithAlpha:1 - f];
            
            self.lastNavBarSnapshot.alpha = f;
            
            self.lastVCSnapshot.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,
                                                                       - self.showViewOffset + translationPoint.x * self.showViewOffsetScale,
                                                                       0);
            self.lastOverlayView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2 * (1 - f)];
            self.visibleViewController.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,
                                                                                   translationPoint.x,
                                                                                   0);
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint velocity = [self.mtPanGes velocityInView:self.view];
            BOOL reset = velocity.x < 0;
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [UIView animateWithDuration:0.3
                             animations:^{
                                 CGFloat alpha = reset ? 1.f : 0.f;
                                 [self navBarTransitionWithAlpha:alpha];
                                 self.lastNavBarSnapshot.alpha = 1 - alpha;
                                 
                                 self.lastVCSnapshot.transform = reset ? CGAffineTransformTranslate(CGAffineTransformIdentity, - self.showViewOffset, 0) : CGAffineTransformIdentity;
                                 self.visibleViewController.view.transform = reset ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, [UIScreen mainScreen].bounds.size.width, 0);
                                 self.lastOverlayView.backgroundColor = reset ? [[UIColor grayColor] colorWithAlphaComponent:0.2] : [UIColor clearColor];
                             }
                             completion:^(BOOL finished) {
                                 [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                 [self navBarTransitionWithAlpha:1];
                                 self.visibleViewController.view.transform = CGAffineTransformIdentity;
                                 self.lastVCSnapshot.transform = CGAffineTransformIdentity;
                                 self.lastVCSnapshot = nil;
                                 self.lastNavBarSnapshot.alpha = 0;
                                 [self.lastVCSnapshot removeFromSuperview];
                                 [self.lastNavBarSnapshot removeFromSuperview];
                                 self.lastNavBarSnapshot = nil;
                                 if (!reset) {
                                     [self popViewControllerAnimated:NO];
                                 }
                             }];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *lastViewController = [self.viewControllers lastObject];
    if (lastViewController) {
        UIImage *navBarImage = [self barSnapshot];
        UIImage *tabBarImage = [self.tabBarController.view snapshot];
        UIImage *rootViewImage = [self.visibleViewController.view snapshot];
        double delayInSeconds = animated ? 0.35 : 0.1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            MTPanBackModel *model = [[MTPanBackModel alloc] init];
            
            if (self.tabBarController == nil) {
                model.rootViewFrame = self.visibleViewController.view.frame;
                model.rootViewImage = rootViewImage;
            }else
            {
                model.tabBarViewFrame = self.tabBarController.view.frame;
                model.tabBarViewImage = tabBarImage;
            }
            
            model.navBarImage = navBarImage;
            [self.imageStack addObject:model];
        });
    }
    
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.imageStack removeLastObject];
    
    UIViewController *vc = [super popViewControllerAnimated:animated];
    if (vc == [self.viewControllers firstObject]) {
        vc.hidesBottomBarWhenPushed = NO;
    }
    return vc;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    [self.imageStack removeAllObjects];
    [[self.viewControllers firstObject] setHidesBottomBarWhenPushed:NO];
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //返回指定vc，倒叙查找
    int deleteCount = 0;
    BOOL isFind = NO;
    for (int i = (int)self.viewControllers.count; i > 0; i--) {
        if (viewController == self.viewControllers[i - 1]) {
            //查找到
            isFind = YES;
            break;
        }
        deleteCount++;
    }
    if (isFind) {
        //将中间出栈的缓存快照删除
        for (int j = 0; j < deleteCount; j++) {
            [self.imageStack removeLastObject];
        }
    }
    
    if (viewController == [self.viewControllers firstObject]) {
        [[self.viewControllers firstObject] setHidesBottomBarWhenPushed:NO];
    }
    return [super popToViewController:viewController animated:animated];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.visibleViewController == [self.viewControllers firstObject]) {
        //如果当前vc是第一个，则不允许滑动
        return NO;
    }
    
    UIViewController *tmpViewController = self.visibleViewController;
    if ([tmpViewController respondsToSelector:@selector(panUnable)]) {
        BOOL unable = tmpViewController.panUnable;
        return !unable;
    }else
    {
        return YES;
    }
    
}

#pragma mark - getter
- (MTPanGestureRecognizer *)mtPanGes
{
    if (!_mtPanGes) {
        _mtPanGes = [[MTPanGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(panGes:)];
        _mtPanGes.delegate = self;
        _mtPanGes.maximumNumberOfTouches = 1;
        [self.view addGestureRecognizer:_mtPanGes];
    }
    return _mtPanGes;
}

- (UIImageView *)lastVCSnapshot
{
    if (!_lastVCSnapshot) {
        _lastVCSnapshot = [[UIImageView alloc] init];
        _lastVCSnapshot.frame = self.view.bounds;
    }
    return _lastVCSnapshot;
}

- (UIView *)lastOverlayView
{
    if (!_lastOverlayView) {
        _lastOverlayView = [[UIView alloc] init];
        _lastOverlayView.frame = self.view.bounds;
        _lastOverlayView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];
        [self.lastVCSnapshot addSubview:_lastOverlayView];
    }
    return _lastOverlayView;
}

- (UIImageView *)lastNavBarSnapshot
{
    if (!_lastNavBarSnapshot) {
        _lastNavBarSnapshot = [[UIImageView alloc] init];
        _lastNavBarSnapshot.frame = self.navigationBar.bounds;
        _lastNavBarSnapshot.backgroundColor = [UIColor clearColor];
    }
    return _lastNavBarSnapshot;
}

- (NSMutableArray *)imageStack
{
    if (!_imageStack) {
        _imageStack = [@[] mutableCopy];
    }
    return _imageStack;
}

@end
