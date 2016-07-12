//
//  ViewController.m
//  HYScanDemo
//
//  Created by Strong on 15/8/24.
//  Copyright (c) 2015年 PPStrong. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 设置标题和背景色
    self.title = @"首页";
    self.view.backgroundColor = [UIColor lightGrayColor];
    // 设置导航条
    UIBarButtonItem *btnScan = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(gotoNextPage:)];
    self.navigationItem.rightBarButtonItem = btnScan;
    
    // 创建扫描按钮
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(50, 360, self.view.bounds.size.width-100, 44);
    loginBtn.backgroundColor = [UIColor clearColor];
    [loginBtn setTitle:@"开始扫描" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(gotoNextPage:) forControlEvents:UIControlEventTouchUpInside];
    loginBtn.layer.cornerRadius = 3.0;
    loginBtn.layer.borderWidth = 1.0;
    loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:loginBtn];
    
}

- (void)gotoNextPage:(UIButton *)button {
    // 进入二维码扫描页面
    ScanViewController *scanVC = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
