//
//  LoginView.m
//  Pet_Enjoying
//
//  Created by 国 on 2016/12/23.
//  Copyright © 2016年 Liu. All rights reserved.
//
#define qqImage @"icon_QQ_80x80" // qq
#define wxImage @"icon_WX_80x80" // 微信
#define wbImage @"icon_WB_80x80" // 微博
/** 获取屏幕宽 */
#define kScreenWidth \
([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.width)

/** 获取屏幕高 */
#define kScreenHeight \
([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)] ? [UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale : [UIScreen mainScreen].bounds.size.height)
/** iPhone5 坐标适配 */
#define ScreenZoomScaleFive kScreenWidth/320.0f  // iPhone5
#define ScreenFive(value) value *ScreenZoomScaleFive

#define LColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "LoginView.h"
#import "Masonry.h"
#import "LLThirdParty.h"
@interface LoginView ()<UITextFieldDelegate,LLThirdPartyDelegate>

@property (nonatomic, strong) UIButton *qqButton; // QQ登录
@property (nonatomic, strong) UIButton *wbButton;// 微博登录
@property (nonatomic, strong) UIButton *wxButton; // 微信登录
@property (nonatomic, strong) LLThirdParty *thirdParty;
@end
@implementation LoginView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];

        [self setSubviews];
        
        // 初始化三方登录Delegate
        [self setThirdPartyDelegate];
    }
    return self;
}

/** 添加子控件 */
-(void)setSubviews{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, kScreenHeight)];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.alpha = 0.9;
    [self addSubview:toolbar];
    
    // 微信
    self.wxButton = [[UIButton alloc] init];
    [self.wxButton setImage:[UIImage imageNamed:wxImage] forState:UIControlStateNormal];
    [self addSubview:self.wxButton];
    [self.wxButton addTarget:self action:@selector(clickWX) forControlEvents:UIControlEventTouchUpInside];
    [self.wxButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(ScreenFive(-56));
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(ScreenFive(40), ScreenFive(40)));
    }];
    
    // QQ
    self.qqButton = [[UIButton alloc] init];
    [self.qqButton setImage:[UIImage imageNamed:qqImage] forState:UIControlStateNormal];
    [self addSubview:self.qqButton];
    [self.qqButton addTarget:self action:@selector(clickQQ) forControlEvents:UIControlEventTouchUpInside];
    [self.qqButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(ScreenFive(-56));
        make.size.mas_equalTo(CGSizeMake(ScreenFive(40), ScreenFive(40)));
        make.right.equalTo(self.wxButton.mas_left).offset(ScreenFive(-26));
    }];
    
    // 微博
    self.wbButton = [[UIButton alloc] init];
    [self.wbButton setImage:[UIImage imageNamed:wbImage] forState:UIControlStateNormal];
    [self addSubview:self.wbButton];
    [self.wbButton addTarget:self action:@selector(clickWB) forControlEvents:UIControlEventTouchUpInside];
    [self.wbButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(ScreenFive(-56));
        make.size.mas_equalTo(CGSizeMake(ScreenFive(40), ScreenFive(40)));
        make.left.equalTo(self.wxButton.mas_right).offset(ScreenFive(26));
    }];
}

#pragma mark - 初始化三方登录Delegate
-(void)setThirdPartyDelegate{
    LLThirdParty *thirdParty = [LLThirdParty new];
    thirdParty.delegate = self;
}

#pragma mark - QQ
-(void) clickQQ{
    // qq跳转登录
    [LLThirdParty qqLogin];
}
// qq返回值
-(void)thirdPartyQQId:(NSString *)idStr{
    if ([self.delegate respondsToSelector:@selector(loginViewReturnQQ:)]) {
        [self.delegate loginViewReturnQQ:idStr];
    }
}

#pragma mark - 微信
-(void) clickWX{
    // 微信跳转登录
    [LLThirdParty weixinLogin];
}

// 微信返回值
-(void)thirdPartyWXId:(NSString *)idStr{
    if ([self.delegate respondsToSelector:@selector(loginViewReturnWX:)]) {
        [self.delegate loginViewReturnWX:idStr];
    }
}


#pragma mark - 微博
-(void) clickWB{
    /// 微博跳转登录
    [LLThirdParty weiboLogin];
    
}
// 微博返回值
-(void)thirdPartyWBId:(NSString *)idStr{
    if ([self.delegate respondsToSelector:@selector(loginViewReturnWB:)]) {
        [self.delegate loginViewReturnWB:idStr];
    }
}

#pragma 收起键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];
}




#pragma 点击关闭按钮
-(void)clickShutDown{
    
    [self removeFromSuperview];
    
    
}

-(UITextField *)textFieldPlacceholeder:(NSString *)placeholder tag:(NSInteger)tag{
    UITextField *textField = [[UITextField alloc] init];
    textField.tag = tag;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.delegate = self;
    textField.textColor = LColorFromRGB(0xffffff);
    UIColor *placeholderColor = LColorFromRGB(0xffffff);
    textField.font = [UIFont systemFontOfSize:ScreenFive(12)];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    textField.layer.cornerRadius = 5;
    
    return textField;
}
@end
