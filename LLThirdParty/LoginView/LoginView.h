//
//  LoginView.h
//  Pet_Enjoying
//
//  Created by 国 on 2016/12/23.
//  Copyright © 2016年 Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginView;
@protocol LoginViewDelegate <NSObject>

/** qq跳转 */
-(void) loginViewReturnQQ:(NSString *)idStr;

/** 微信跳转 */
-(void) loginViewReturnWX:(NSString *)idStr;

/** 微博跳转 */
-(void) loginViewReturnWB:(NSString *)idStr;
@end


@interface LoginView : UIView
@property (nonatomic, weak) id<LoginViewDelegate> delegate;
@end
