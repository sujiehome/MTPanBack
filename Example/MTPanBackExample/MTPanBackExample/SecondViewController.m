//
//  SecondViewController.m
//  MTPanBackExample
//
//  Created by suyuxuan on 16/3/17.
//  Copyright © 2016年 Monk.Tang. All rights reserved.
//

#import "SecondViewController.h"
#import "ThirdViewController.h"

/*********禁止划动*********/
#import "UIViewController+MTPan.h"
/*************************/

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    /*********禁止划动*********/
    self.panUnable = YES;
    /*************************/
    
    self.navigationItem.title = @"Second";
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIImageView *testImageView = [[UIImageView alloc] init];
    testImageView.frame = CGRectMake(0, 0, 100, 100);
    testImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2,
                                       [UIScreen mainScreen].bounds.size.height / 2);
    testImageView.image = [UIImage imageNamed:@"MonkTang.png"];
    testImageView.userInteractionEnabled = YES;
    [self.view addSubview:testImageView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tap:)];
    [testImageView addGestureRecognizer:tap];
}

- (void)tap:(UIGestureRecognizer *)ges
{
    ThirdViewController *vc = [[ThirdViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
