//
//  FirstViewController.m
//  MTPanBackExample
//
//  Created by suyuxuan on 16/3/17.
//  Copyright © 2016年 Monk.Tang. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"First";
    self.view.backgroundColor = [UIColor redColor];
    
    UIImageView *testImageView = [[UIImageView alloc] init];
    testImageView.frame = CGRectMake(0, 0, 170, 170);
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
    SecondViewController *vc = [[SecondViewController alloc] init];
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
