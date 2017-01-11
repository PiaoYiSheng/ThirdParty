//
//  LLThirdParty.m
//  Pet_Enjoying
//
//  Created by 国 on 2016/12/29.
//  Copyright © 2016年 Liu. All rights reserved.
//

#import "LLThirdParty.h"
#import "WeiboSDK.h"

/** 微博登录App Key */
#define WeiboAppKey @"微博AppKey"
#define WeiboRedirectURI @"微博回调链接"

/** qq登录App Key */
#define qqAppId @"QQAppID"
#define qqAppKey @"QQAppKey"

/** 微信登录App Key */
#define WeiXAppID @"微信AppID"
#define WeiXAppSecret @"微信AppSecret"
@interface LLThirdParty ()<NSURLSessionTaskDelegate>
@property (nonatomic, strong)TencentOAuth * tencentOAuth; // QQ
@property (nonatomic, strong)NSMutableArray * tencentPermissions; // QQ字典
@property (nonatomic, strong)NSString * access_token_WX; // 微信
@end

static LLThirdParty *_instance;

@implementation LLThirdParty

+(void)initialize{
    [LLThirdParty thirdPartyLoginManager];
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        [_instance setRegisterApps];
    });
    return _instance;
}
+ (instancetype)thirdPartyLoginManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]init];
        [_instance setRegisterApps];
    });
    return _instance;
}

/** 注册 */
- (void)setRegisterApps
{
    // 注册Sina微博
    [WeiboSDK registerApp:WeiboAppKey];
    
    // 微信注册
    [WXApi registerApp:WeiXAppID];
    
    // 注册QQ
    _tencentOAuth = [[TencentOAuth alloc]initWithAppId:qqAppId andDelegate:self];
    // 这个是说到时候你去qq那拿什么信息
    _tencentPermissions = [NSMutableArray arrayWithArray:@[/** 获取用户信息 */
                                                           kOPEN_PERMISSION_GET_USER_INFO,
                                                           /** 移动端获取用户信息 */
                                                           kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                                                           /** 获取登录用户自己的详细信息 */
                                                           kOPEN_PERMISSION_GET_INFO]];
}

#pragma mark - 微博登录
+(void)weiboLogin{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    //回调地址与 新浪微博开放平台中 我的应用  --- 应用信息 -----高级应用    -----授权设置 ---应用回调中的url保持一致就好了
    request.redirectURI = WeiboRedirectURI;
    
    //SCOPE 授权说明参考  http://open.weibo.com/wiki/
    request.scope = @"all";
    request.userInfo = nil;
    [WeiboSDK sendRequest:request];
}

#pragma mark - WeiboSDKDelegate

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) { // 获取成功
        [self getWeiBoUserInfo:[(WBAuthorizeResponse *) response userID] token:[(WBAuthorizeResponse *) response accessToken]];
    }
}
/** 微博获取微博用户数据 */
- (void)getWeiBoUserInfo:(NSString *)uid token:(NSString *)token
{
    NSString *url =[NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?uid=%@&access_token=%@&source=%@",uid,token,WeiboAppKey];
    NSURL *zoneUrl = [NSURL URLWithString:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    // 创建任务
    NSURLSessionDataTask * task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:zoneUrl] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSDictionary *paramter = @{@"third_id" : [dic valueForKeyPath:@"idstr"],
                                   @"third_name" : [dic valueForKeyPath:@"screen_name"],
                                   @"third_image":[dic valueForKeyPath:@"avatar_hd"],
                                   @"access_token":token};
        if ([self.delegate respondsToSelector:@selector(thirdPartyWBId:)]) {
            [self.delegate thirdPartyWBId:paramter[@"third_id"]];
        }
    }];
    
    // 启动任务
    [task resume];
}

#pragma mark - qq登录
+(void)qqLogin{
    [_instance.tencentOAuth authorize:_instance.tencentPermissions inSafari:NO];
}
/** QQ_Delegate */
-(void)tencentDidLogin{// 登录成功后的回调
    [_tencentOAuth getUserInfo];
}
- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response.retCode == URLREQUEST_SUCCEED)
    {
        NSDictionary *paramter = @{@"third_id" : [_tencentOAuth openId],
                                   @"third_name" : [response.jsonResponse valueForKeyPath:@"nickname"],
                                   @"third_image":[response.jsonResponse valueForKeyPath:@"figureurl_qq_2"],
                                   @"access_token":[_tencentOAuth accessToken]};
        if ([self.delegate respondsToSelector:@selector(thirdPartyQQId:)]) {
            [self.delegate thirdPartyQQId:paramter[@"third_id"]];
        }
    }
    else
    {
        NSLog(@"登录失败!");
    }
}

#pragma mark - 微信登录
+(void)weixinLogin{
    if ([WXApi isWXAppInstalled]) { // 安装了微信
        SendAuthReq* req = [[SendAuthReq alloc ] init ];
        req.openID = WeiXAppID;
        req.scope = @"snsapi_userinfo,snsapi_base";
//        req.state = @"0744" ;
        [WXApi sendReq:req];
    }else{// 未安装微信
        NSString *wxUrlStr = [WXApi getWXAppInstallUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:wxUrlStr]];
    }
}

-(void) onResp:(BaseResp*)resp
{
    SendAuthResp *aresp = (SendAuthResp *)resp;
    if (resp.errCode == 0) {
        [[LLThirdParty thirdPartyLoginManager] getWeiXinUserInfoWithCode:aresp.code];
    }
}


- (void)getWeiXinUserInfoWithCode:(NSString *)code
{
    NSOperationQueue * queue = [[NSOperationQueue alloc]init];
    NSBlockOperation * getAccessTokenOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSString * urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WeiXAppID,WeiXAppSecret,code];
        NSURL * url = [NSURL URLWithString:urlStr];
        NSString *responseStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        
        self.access_token_WX = [NSString stringWithFormat:@"%@",[dic objectForKey:@"access_token"]];
    }];
    
    NSBlockOperation * getUserInfoOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *urlStr =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",self.access_token_WX,WeiXAppID];
        NSURL * url = [NSURL URLWithString:urlStr];
        NSString *responseStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *responseData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSDictionary *paramter = @{@"third_id" : dic[@"openid"],
                                   @"third_name" : dic[@"nickname"],
                                   @"third_image":dic[@"headimgurl"],
                                   @"access_token":self.access_token_WX};
        
        if ([self.delegate respondsToSelector:@selector(thirdPartyWXId:)]) {
            [self.delegate thirdPartyWXId:paramter[@"third_id"]];
        }
    }];
    
    [getUserInfoOperation addDependency:getAccessTokenOperation];
    
    [queue addOperation:getAccessTokenOperation];
    [queue addOperation:getUserInfoOperation];
}
@end
