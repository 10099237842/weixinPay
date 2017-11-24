//
//  GetIPAddress.h
//  YuTongTianXia
//
//  Created by 合一网络 on 16/9/22.
//  Copyright © 2016年 合一网络. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetIPAddress : NSObject
/**
 获取ip地址
 */

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

@end
