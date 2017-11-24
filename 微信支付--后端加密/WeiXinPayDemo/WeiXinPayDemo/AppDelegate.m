//
//  AppDelegate.m
//  WeiXinPayDemo
//
//  Created by tiger on 16/1/9.
//  Copyright © 2016年 韩山虎. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    /*
     1、如果你app同时使用了友盟分享（含微信分享）和微信支付。如果你没有处理好这个两个SDK register的顺序，那就很不幸，也会出现这种情况。
     （如何出现这种情况，请看我的测试步骤：1、杀掉微信进程、2、删除自己开发的app、3、重新同步自己的app到设备，点击微信支付）
     两者register的顺序：如果是先调用微信registerApp、然后调用友盟的 [UMSocialWechatHandler setWXAppId:WXAppID appSecret:[NSString stringWithBundleNameForKey:@"WXAppSecret"] url:url] ，然后按照我测试的步骤，应该就会出现。
     解决办法：改变两者的register步骤。先调用友盟，然后调用微信。
     */
    
    //向微信注册appid.
    //Description :  更新后的api 没有什么作用,只是给开发者一种解释作用.
    [WXApi registerApp:@"wx88eefcab60edbec7" withDescription:@"WeiXinPayDemo"];
    
    return YES;
}

#pragma mark - WXApiDelegate  支付结果回调
-(void)onResp:(BaseResp*)resp{
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                NSLog(@"支付成功");
                break;
            case WXErrCodeCommon:
            { //签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等
                
                NSLog(@"支付结果: 失败!");
            }
                break;
            case WXErrCodeUserCancel:
            { //用户点击取消并返回
                
            }
                break;
            case WXErrCodeSentFail:
            { //发送失败
                NSLog(@"发送失败");
            }
                break;
            case WXErrCodeUnsupport:
            { //微信不支持
                NSLog(@"微信不支持");
            }
                break;
            case WXErrCodeAuthDeny:
            { //授权失败
                NSLog(@"授权失败");
            }
                break;

            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                break;
                /*
                 0  成功
                 -1 错误
                 -2 用户取消
                 
                 */
                
        }
    }
}


- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    return [WXApi handleOpenURL:url delegate:self];

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
