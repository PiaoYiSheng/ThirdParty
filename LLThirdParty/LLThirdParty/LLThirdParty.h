//
//  LLThirdParty.h
//  Pet_Enjoying
//
//  Created by 国 on 2016/12/29.
//  Copyright © 2016年 Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
@class LLThirdParty;
@protocol LLThirdPartyDelegate <NSObject>
/** 微博 */
-(void)thirdPartyWBId:(NSString *)idStr;

/** 微信 */
-(void)thirdPartyWXId:(NSString *)idStr;

/** QQ */
-(void)thirdPartyQQId:(NSString *)idStr;

@end

@interface LLThirdParty : NSObject<WeiboSDKDelegate,TencentSessionDelegate,TencentLoginDelegate,WXApiDelegate>
@property (nonatomic, weak) id<LLThirdPartyDelegate> delegate;
/** 微博登录 */
+(void)weiboLogin;

/** 微信登录 */
+(void)weixinLogin;

/** QQ登录 */
+(void)qqLogin;

+(instancetype)thirdPartyLoginManager;
@end
