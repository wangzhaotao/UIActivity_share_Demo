//
//  BCPHAidPref.h
//  BatteryCam
//
//  Created by yf on 2018/8/29.
//  Copyright © 2018年 oceanwing. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 保存相册的aid和本地沙盒文件路径的映射关系
 */
@interface BCPHAidPref : NSObject
+(void)savePath:(NSString *)path aid:(NSString *)aid;
+(void)assetUrlByPath:(NSString *)path cb:(void(^)(NSURL *assUrl))cb;
+(NSURL *)assetUrlByPath:(NSString *)path;


+(void)saveVideoToAlbum:(NSString *)path compCb:(void (^)(BOOL  suc))compCb;
@end
