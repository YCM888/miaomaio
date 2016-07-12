//
//  ScanViewController.m
//  HYRtspSDK
//
//  Created by Strong on 15/8/22.
//  Copyright © 2015年 PPStrong. All rights reserved.
//

#import "ScanViewController.h"
#import "ZBarSDK.h"

@interface ScanViewController ()<ZBarReaderDelegate, ZBarReaderViewDelegate>
{
    UIView *_scanLine;
    NSTimer *_moveTimer;
    
    UIImageView *_imageView;
    BOOL _isScaning;
}
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 设置标题和背景色
    self.title = @"Scanning";
    self.view.backgroundColor = [UIColor blackColor];
    // 设置导航条
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = backBtn;
    UIBarButtonItem *btnSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(clickToSearchDevice)];
    self.navigationItem.rightBarButtonItem = btnSearch;
    
    // 开始扫描:调用系统方式
    //[self startSystemScanningAction];
    // 开始扫描:自定义方式
    [self startCustomScanningAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)clickBack {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)clickToSearchDevice {
    NSLog(@"进入搜索列表页面");
}

#pragma mark - SystemScanning
- (void)startSystemScanningAction {
    ZBarReaderViewController *readerV = [ZBarReaderViewController new];
    readerV.readerDelegate = self;
    readerV.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    // 显示底部控制按钮
    readerV.showsZBarControls = NO;
    // 设置自定义的界面
    [self setOverlaySystemView:readerV];
    
    ZBarImageScanner *scanner = readerV.scanner;
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    [self presentViewController:readerV animated:YES completion:nil];
}
- (void)setOverlaySystemView:(ZBarReaderViewController *)readerView {
    //清除原有控件
    for (UIView *temp in [readerView.view subviews]) {
        for (UIButton *button in [temp subviews]) {
            if ([button isKindOfClass:[UIButton class]]) {
                [button removeFromSuperview];
            }
        }
        
        for (UIToolbar *toolbar in [temp subviews]) {
            if ([toolbar isKindOfClass:[UIToolbar class]]) {
                [toolbar setHidden:YES];
                [toolbar removeFromSuperview];
            }
        }
    }
    // 画中间的基准线
    _scanLine = [[UIView alloc] initWithFrame:CGRectMake(100, 200, self.view.bounds.size.width-200, 1)];
    _scanLine.backgroundColor = [UIColor redColor];
    [readerView.view addSubview:_scanLine];
    // 最上部view
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 150)];
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor clearColor];
    [readerView.view addSubview:upView];
    // 用于说明的label
    UILabel *tiplabel= [[UILabel alloc] initWithFrame:CGRectMake(50, 100, self.view.bounds.size.width-100, 40)];
    tiplabel.backgroundColor = [UIColor clearColor];
    tiplabel.text = @"将二维码/条码图像置于矩形框内";
    tiplabel.textColor = [UIColor whiteColor];
    tiplabel.textAlignment = NSTextAlignmentCenter;
    [upView addSubview:tiplabel];
    // 左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 100, 250)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor clearColor];
    [readerView.view addSubview:leftView];
    // 右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-100, 150, 100, 250)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor clearColor];
    [readerView.view addSubview:rightView];
    // 底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, 400, self.view.bounds.size.width, self.view.bounds.size.height-400)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor clearColor];
    [readerView.view addSubview:downView];
    // TODO: 用于取消操作的button
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(50, 500, self.view.bounds.size.width-100, 40);
    cancelButton.alpha = 0.5;
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(dismissOverlayView:)forControlEvents:UIControlEventTouchUpInside];
    [readerView.view addSubview:cancelButton];
    
    // 创建定时器
    _moveTimer =[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats:YES];
}
// 横线移动实现扫描的效果
- (void)moveUpAndDownLine {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionRepeat animations:^{
        _scanLine.frame =  CGRectMake(100, 200, self.view.bounds.size.width-200, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            _scanLine.frame =  CGRectMake(100, 200+_scanLine.bounds.size.width, self.view.bounds.size.width-200, 1);
        }];
    }];
}
// 点击取消按钮
- (void)dismissOverlayView:(id)sender{
    [self stopTimer];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)stopTimer {
    if ([_moveTimer isValid] == YES) {
        [_moveTimer invalidate];
        _moveTimer = nil;
    }
}
#pragma mark - ZBarReaderDelegate
- (void)readerControllerDidFailToRead:(ZBarReaderController *)reader withRetry:(BOOL)retry {
    // ??????
    //_isScaning = NO;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (_isScaning) {
        id<NSFastEnumeration> results = [info objectForKey:ZBarReaderControllerResults];
        ZBarSymbol * symbol = nil;
        for(symbol in results)
            break;
        
        NSLog(@"-----%@", symbol.data);
        NSString *textStr = symbol.data;
        // 解决中文乱码问题
        if ([textStr canBeConvertedToEncoding:NSShiftJISStringEncoding]) {
            textStr = [NSString stringWithCString:[textStr cStringUsingEncoding:
                                                   NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        }
        NSString *string = [NSString stringWithFormat:@"%@", textStr];
        NSLog(@"%@", string);
        
        // ??????
        //_imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self stopTimer];
        _isScaning = NO;
        // 进入下一级页面
        //ScanViewController *scanVC = [[ScanViewController alloc] init];
        //[self.navigationController pushViewController:scanVC animated:YES];
    }
    
}


#pragma mark - CustomScanning
- (void)startCustomScanningAction {
    // 初始化照相机窗口
    ZBarReaderView *readview = [ZBarReaderView new];
    readview.frame = CGRectMake(50, 180, self.view.bounds.size.width-100, self.view.bounds.size.width-100);
    readview.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5];
    readview.readerDelegate = self;
    [self.view addSubview:readview];
    // 关闭闪光灯
    readview.torchMode = 0;
    // 设置自定义的界面
    [self setOverlayCustomView:readview];
    
    // 二维码/条形码识别设置
    ZBarImageScanner *scanner = readview.scanner;
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    //启动扫描, 然后扫描的图像才可以显示
    [readview start];
}
// 设置自定义的界面
- (void)setOverlayCustomView:(ZBarReaderView *)readerView {
    //清除原有控件
    for (UIView *temp in [readerView subviews]) {
        for (UIButton *button in [temp subviews]) {
            if ([button isKindOfClass:[UIButton class]]) {
                [button removeFromSuperview];
            }
        }
        
        for (UIToolbar *toolbar in [temp subviews]) {
            if ([toolbar isKindOfClass:[UIToolbar class]]) {
                [toolbar setHidden:YES];
                [toolbar removeFromSuperview];
            }
        }
    }
    // 画中间的基准线
    _scanLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, readerView.bounds.size.width, 1)];
    _scanLine.backgroundColor = [UIColor redColor];
    [readerView addSubview:_scanLine];
    // 创建定时器
    _moveTimer =[NSTimer scheduledTimerWithTimeInterval:1 target:self
                                               selector:@selector(moveToScanQrcode) userInfo:nil repeats:YES];
}
// 横线移动实现扫描的效果
- (void)moveToScanQrcode {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionRepeat animations:^{
        _scanLine.frame =  CGRectMake(0, 0, self.view.bounds.size.width-100, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            _scanLine.frame =  CGRectMake(0, _scanLine.bounds.size.width, self.view.bounds.size.width-100, 1);
        }];
    }];
}
#pragma mark - ZBarReaderViewDelegate
- (void)readerView:(ZBarReaderView *)readerView
    didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image {
    
    NSLog(@"已扫描到二维码");
    ZBarSymbol *symbol = nil;
    for(symbol in symbols)
        break;
    
    NSString *textStr = symbol.data;
    NSLog(@"-----%@", textStr);
    // 停止连扫
    [readerView stop];
    [_scanLine removeFromSuperview];
}

/*
 目前市场主流APP里，二维码/条形码集成主要分两种表现形式来集成：
 a. 一种是调用手机摄像头并打开系统照相机全屏去拍摄
 b. 一种是自定义照相机视图的frame，自己控制并添加相关扫码指南
*/

@end
