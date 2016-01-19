//
//  ViewController.m
//  LDNetDiagnoServieDemo
//
//  Created by 庞辉 on 14-10-29.
//  Copyright (c) 2014年 庞辉. All rights reserved.
//

#import "ViewController.h"
#import "LDNetDiagnoService.h"
#import "SVProgressHUD.h"
#import "QiniuSDK.h"
#import "AFNetworking.h"


//获取当前屏幕宽高
#define QNDeviceWidth [UIScreen mainScreen].bounds.size.width        //屏幕宽
#define QNDeviceHeight [UIScreen mainScreen].bounds.size.height      //屏幕高

@interface ViewController () <LDNetDiagnoServiceDelegate, UITextFieldDelegate> {
    UIActivityIndicatorView *_indicatorView;
    UIButton *btn;
    UITextView *_txtView_log;
    UITextField *_txtfield_dormain;

    NSString *_logInfo;
    LDNetDiagnoService *_netDiagnoService;
    BOOL _isRunning;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"网络诊断";

    _indicatorView = [[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.frame = CGRectMake(0, 0, 30, 30);
    _indicatorView.hidden = NO;
    _indicatorView.hidesWhenStopped = YES;
    [_indicatorView stopAnimating];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_indicatorView];
    self.navigationItem.rightBarButtonItem = rightItem;


    btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(10.0f, 79.0f, 100.0f, 50.0f);
    btn.frame = CGRectMake(QNDeviceWidth-55, 79.0f, 50.0f, 40.0f);
    [btn setBackgroundColor:[UIColor colorWithRed:0.16f green:0.56f blue:0.97f alpha:1.00f]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btn.titleLabel setNumberOfLines:2];
    [btn setTitle:@"检测" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    btn.layer.cornerRadius = 5;
    [btn addTarget:self
                  action:@selector(startNetDiagnosis)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];


    _txtfield_dormain =
            [[UITextField alloc] initWithFrame:CGRectMake(5, 79.0f, QNDeviceWidth-65 , 40)];
    _txtfield_dormain.delegate = self;
    _txtfield_dormain.returnKeyType = UIReturnKeyDone;
    _txtfield_dormain.placeholder = @"请输入测试网址";
    _txtfield_dormain.text = @"upload.qiniu.com";
    _txtfield_dormain.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_txtfield_dormain];


    _txtView_log = [[UITextView alloc] initWithFrame:CGRectZero];
    _txtView_log.layer.borderWidth = 1.0f;
    _txtView_log.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _txtView_log.backgroundColor = [UIColor whiteColor];
    _txtView_log.font = [UIFont systemFontOfSize:10.0f];
    _txtView_log.textAlignment = NSTextAlignmentLeft;
    _txtView_log.scrollEnabled = YES;
    _txtView_log.editable = NO;
    _txtView_log.frame =
        CGRectMake(0.0f, 140.0f, self.view.frame.size.width, self.view.frame.size.height - 120.0f);
    [self.view addSubview:_txtView_log];

    // Do any additional setup after loading the view, typically from a nib.
    _netDiagnoService = [[LDNetDiagnoService alloc] initWithAppCode:@"QNNetTest"
                                                            appName:@"网络诊断"
                                                         appVersion:@"1.0.0"
                                                             userID:@"Qiniu"/*@"huipang@corp.netease.com"*/
                                                           deviceID:nil
                                                            dormain:_txtfield_dormain.text
                                                        carrierName:nil
                                                     ISOCountryCode:nil
                                                  MobileCountryCode:nil
                                                      MobileNetCode:nil];
    _netDiagnoService.delegate = self;
    _isRunning = NO;
}


- (void)startNetDiagnosis
{
    [_txtfield_dormain resignFirstResponder];
    if (!_txtfield_dormain.text || [_txtfield_dormain.text isEqualToString: @""]) {
        [SVProgressHUD showAlterMessage:@"网址不能为空"];
        return;
    }
    _netDiagnoService.dormain = _txtfield_dormain.text;
    if (!_isRunning) {
        [_indicatorView startAnimating];
        [btn setTitle:@"停止" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor grayColor]];
        [btn setUserInteractionEnabled:FALSE];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
        _txtView_log.text = @"";
        _logInfo = @"";
        _isRunning = !_isRunning;
        [_netDiagnoService startNetDiagnosis];
    } else {
        [_indicatorView stopAnimating];
        _isRunning = !_isRunning;
        [btn setTitle:@"检测" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithRed:0.16f green:0.56f blue:0.97f alpha:1.00f]];
        [btn setUserInteractionEnabled:FALSE];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
        [_netDiagnoService stopNetDialogsis];
    }
}

- (void)delayMethod
{
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    [btn setUserInteractionEnabled:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NetDiagnosisDelegate
- (void)netDiagnosisDidStarted
{
    NSLog(@"开始诊断～～～");
}

- (void)netDiagnosisStepInfo:(NSString *)stepInfo
{
    NSLog(@"%@", stepInfo);
    _logInfo = [_logInfo stringByAppendingString:stepInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        _txtView_log.text = _logInfo;
    });
}


- (void)netDiagnosisDidEnd:(NSString *)allLogInfo;
{
    NSLog(@"logInfo>>>>>\n%@", allLogInfo);
    //可以保存到文件，也可以通过邮件发送回来
    [self takeToken];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_indicatorView stopAnimating];
        [btn setTitle:@"检测" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithRed:0.16f green:0.56f blue:0.97f alpha:1.00f]];
        _isRunning = NO;
    });
}

- (void)takeToken
{
    //1.管理器
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //2.设置登录参数
//    NSDictionary *dict = @{ @"username":@"xn", @"password":@"123" };
    
    //3.请求
    [manager GET:@"http://jssdk.demo.qiniu.io/uptoken" parameters:nil success: ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GET --> %@, %@", responseObject, [NSThread currentThread]); //自动返回主线程
        [self uploadToQiNiu:responseObject[@"uptoken"]];
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
                                         
}

- (void)emailLogInfo
{
    [_netDiagnoService printLogInfo];
}

- (void)uploadToQiNiu:(NSString *)token
{
    
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970] *1000;
    long long int startTimeDate = (long long int)startTime;
    
    QNUploadManager * qnUploadManger = [[QNUploadManager alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"xxxxx" ofType:@"jpeg"];
    [qnUploadManger putFile:path key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (!info.error) {
            NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970] * 1000 ;
            long long int  endTimeDate = (long long int)endTime;
            long int uploadTime = (long int) (endTimeDate - startTimeDate);
            [_netDiagnoService recordStepInfo:[NSString stringWithFormat:@"七牛云上传:成功\n文件大小:3M\n所用时间:%ld ms\n\n\n",uploadTime]];
        }else
        {
            [_netDiagnoService recordStepInfo:[NSString stringWithFormat:@"七牛云上传:失败\n文件大小:3M\n失败原因:%@\n\n\n",info.error]];
        }
        
        [self emailLogInfo];
    } option:nil];
    
    
}


#pragma mark -
#pragma mark - textFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end
