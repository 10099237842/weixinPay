//
//  ViewController.m
//  WeiXinPayDemo
//
//  Created by tiger on 16/1/9.
//  Copyright © 2016年 韩山虎. All rights reserved.
//

#import "ViewController.h"
#import "WXApi.h"
#import "WXApiObject.h"



@interface ViewController ()

@end

@implementation ViewController
- (IBAction)weixinpayAction:(id)sender
{
    
    
    
    //判断用户是否安装微信客户端
    if ([WXApi isWXAppInstalled]) {
        //调用微信支付
        [self payWithWeixin];
    }else{
        NSLog(@"未检测到客户端,请自行下载");
        return;
    }
    }

#pragma mark 微信支付
- (void)payWithWeixin
{
    //从服务器端获取
    //微信支付按钮方法
    PayReq *request = [[PayReq alloc] init];
    //商家向财付通申请的商家id
    request.partnerId = @"1415010902";
    //预支付订单 : 里面包含了 商品的标题 . 描述, 价格等商品信息.
    request.prepayId= @"9201039000160109a802876d726d4458";
    ///** 商家根据财付通文档填写的数据和签名 */
    // 相当于一种标识
    request.package = @"Sign=WXPay";
    ///** 随机串，防重发 */
    request.nonceStr= @"DOagHs30hjYYeRSy";
    //时间戳.  防止重发.
    //从1970年之后的秒数.
    request.timeStamp= 1452325279;
    ///** 商家根据微信开放平台文档对数据做的签名 */
    //加密数据用的
    request.sign= @"A79A67051489D48E1B6D557F64FFFE79";
    //调用微信支付.
    [WXApi sendReq:request];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
