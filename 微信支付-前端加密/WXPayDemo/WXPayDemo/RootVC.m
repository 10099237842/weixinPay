//
//  ViewController.m
//  WXPayDemo
//
//  Created by 合一网络 on 2017/11/20.
//  Copyright © 2017年 合一网络. All rights reserved.
//

#import "RootVC.h"
#import "DataMD5.h"
#import "XMLDictionary.h"
#import "GetIPAddress.h"
//#import "AFNetworking.h"

@interface RootVC ()

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"微信支付";

}

#pragma mark 微信支付
- (IBAction)wxPayAction:(UIButton *)sender {
    [self weixinChooseActWithOrderNumber:@"订单号(从服务器获取)"];
}

#pragma mark - 微信支付相关方法
- (void)weixinChooseActWithOrderNumber:(NSString * )orderNumber{
    NSLog(@"微信充值");
    //判断用户是否安装微信客户端
    if (![WXApi isWXAppInstalled]) {
        NSLog(@"未检测到客户端,请自行下载");
        return;
    }

    NSString *appid,*mch_id,*nonce_str,*sign,*body,*out_trade_no,*total_fee,*spbill_create_ip,*notify_url,*trade_type,*partner;
    //应用APPID
    appid = WX_APPID;
    //微信支付商户号
    mch_id = WX_MCH_ID;
    //产生随机字符串，这里最好使用和安卓端一致的生成逻辑
    nonce_str = [self getRandomStringWithret32bitString];
    //商品描述
    body = @"商品描述";
    //从自己服务器获取的订单号
    out_trade_no = orderNumber;
    //交易价格1表示0.01元，10表示0.1元
    id result;
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    result=[f numberFromString:@"交易金额"];
    if(!(result))
    {
        result = @"交易金额";
    }
    total_fee = [NSString stringWithFormat:@"%.0f",[result floatValue] * 100];

    NSLog(@"total_fee = %@",total_fee);
    //获取终端IP地址
    spbill_create_ip = [GetIPAddress getIPAddress:NO];
    //微信支付异步通知地址
    notify_url = WX_APP_NOTIFY_URL;
    trade_type =@"APP";
    //API密钥
    partner = WX_PARTNER;
    //获取sign签名
    DataMD5 *data = [[DataMD5 alloc] initWithAppid:appid mch_id:mch_id nonce_str:nonce_str partner_id:partner body:body out_trade_no:out_trade_no total_fee:total_fee spbill_create_ip:spbill_create_ip notify_url:notify_url trade_type:trade_type];
    sign = [data getSignForMD5];
    //设置参数并转化成xml格式
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:appid forKey:@"appid"];//公众账号ID
    [dic setValue:mch_id forKey:@"mch_id"];//商户号
    [dic setValue:nonce_str forKey:@"nonce_str"];//随机字符串
    [dic setValue:sign forKey:@"sign"];//签名
    [dic setValue:body forKey:@"body"];//商品描述
    [dic setValue:out_trade_no forKey:@"out_trade_no"];//订单号
    [dic setValue:total_fee forKey:@"total_fee"];//金额
    [dic setValue:spbill_create_ip forKey:@"spbill_create_ip"];//终端IP
    [dic setValue:notify_url forKey:@"notify_url"];//通知地址
    [dic setValue:trade_type forKey:@"trade_type"];//交易类型

    //    NSLog(@"%@",dic);
    // 转换成xml字符串
    NSString *string = [dic XMLString];
    NSLog(@"xml源字符串  %@",string);
    [self http:string];

}



- (void)http:(NSString *)xml{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"https://api.mch.weixin.qq.com/pay/unifiedorder" forHTTPHeaderField:@"SOAPAction"];
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        NSLog(@"%@",xml);
        return xml;
    }];

    [manager POST:@"https://api.mch.weixin.qq.com/pay/unifiedorder" parameters:xml progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] ;
        // LXLog(@"responseString is %@",responseString);
        //将微信返回的xml数据解析转义成字典
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:responseString];
        //判断返回的许可
        if ([[dic objectForKey:@"result_code"] isEqualToString:@"SUCCESS"] &&[[dic objectForKey:@"return_code"] isEqualToString:@"SUCCESS"] ) {
            //发起微信支付，设置参数
            PayReq *request = [[PayReq alloc] init];
            request.openID = [dic objectForKey:@"appid"];
            request.partnerId = [dic objectForKey:@"mch_id"];
            request.prepayId= [dic objectForKey:@"prepay_id"];
            request.package = @"Sign=WXPay";
            request.nonceStr= [dic objectForKey:@"nonce_str"];
            request.sign = [dic objectForKey:@"sign"];

            //将当前事件转化成时间戳
            NSDate *datenow = [NSDate date];
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
            UInt32 timeStamp =[timeSp intValue];
            request.timeStamp= timeStamp;
            NSLog(@"timeStamp = %u",(unsigned int)timeStamp);
            // 签名加密
            DataMD5 *md5 = [[DataMD5 alloc] init];
            request.sign=[md5 createMD5SingForPay:request.openID partnerid:request.partnerId prepayid:request.prepayId package:request.package noncestr:request.nonceStr timestamp:request.timeStamp];
            // 调用微信
            [WXApi sendReq:request];

        }else{
            NSLog(@"参数不正确，请检查参数");
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure");
    }];
}

#pragma mark 产生32位随机字符串
-(NSString *)getRandomStringWithret32bitString
{
    char data[32];

    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));

    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

