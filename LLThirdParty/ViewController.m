//
//  ViewController.m
//  LLThirdParty
//
//  Created by 国 on 2016/12/29.
//  Copyright © 2016年 Liu. All rights reserved.
//

#import "ViewController.h"
#import "LoginView.h"
@interface ViewController ()<LoginViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LoginView *login = [[LoginView alloc] init];
    login.frame = self.view.bounds;
    login.delegate = self;
    [self.view addSubview:login];
}

#pragma mark - qq
-(void)loginViewReturnQQ:(NSString *)idStr{
    NSLog(@"qq------%@",idStr);
}

#pragma mark - 微博
-(void)loginViewReturnWB:(NSString *)idStr{
    NSLog(@"微博------%@",idStr);
}

#pragma mark - 微信
-(void)loginViewReturnWX:(NSString *)idStr{
    NSLog(@"微信------%@",idStr);
}



@end
