
//
//  BCPHAidPref.m
//  BatteryCam
//
//  Created by yf on 2018/8/29.
//  Copyright © 2018年 oceanwing. All rights reserved.
//

#import "BCPHAidPref.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define iPref(name)[[NSUserDefaults alloc] initWithSuiteName:(name)]
#define iFormatStr(...) ([NSString stringWithFormat:__VA_ARGS__])
#define iURL(name) [NSURL URLWithString:(name)]
#define iFURL(name) [NSURL fileURLWithPath:(name)]

void runOnMain(void (^blo)(void)){
    dispatch_async(dispatch_get_main_queue(), blo);
}
void runOnGlobal(void (^blo)(void)){
    dispatch_async(dispatch_get_global_queue(0, 0), blo);
}

@interface ALUtil:NSObject
+(void)setImgFromALURL:(NSURL*)alurl cb:(void(^)(UIImage *))cb;
+(void)videoFromALURL:(NSURL *)alurl cb:(void(^)(ALAsset *asset))cb;
@end

BOOL emptyStr(NSString *str){
    return !str||!str.length;
}

@implementation BCPHAidPref
+(void)savePath:(NSString *)path aid:(NSString *)aid{
    
    [iPref(@"Aid2Path") setObject:aid forKey:path.lastPathComponent];
    [iPref(@"Aid2Path") synchronize];
}
+(NSString *)aidFromPath:(NSString *)path{
    return [iPref(@"Aid2Path") objectForKey:path.lastPathComponent];
}
+(NSURL *)assetUrlByPath:(NSString *)path{
    NSString *aid = [self aidFromPath:path];
    if(emptyStr(aid))return nil;
    return [self assetUrlByAid:aid];
}
+(void)assetUrlByPath:(NSString *)path cb:(void(^)(NSURL *assUrl))cb{
    NSURL  *url = [self assetUrlByPath:path];
    [ALUtil videoFromALURL:url cb:^(ALAsset *asset) {
        if(asset){
            cb(url);
        }else{
            cb(nil);
        }
    }];
}

+(NSURL *)assetUrlByAid:(NSString *)aid{
    NSString * assetURLStr =iFormatStr(@"assets-library://asset/asset.mp4?id=%@&ext=mp4",aid);
    NSURL *url = iURL(assetURLStr);
    return url;
}


+(void)saveVideoToAlbum:(NSString *)path compCb:(void (^)(BOOL  suc))compCb{
    NSURL *url = iFURL(path);
    PHPhotoLibrary *plib = [PHPhotoLibrary sharedPhotoLibrary];
    __block PHObjectPlaceholder *pla;
    [plib performChanges:^{
        pla = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url].placeholderForCreatedAsset;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success){
            runOnMain(^{
                NSString *lid = pla.localIdentifier;
                NSString *aid = [lid stringByReplacingOccurrencesOfString:@"/.*" withString:@"" options:(NSRegularExpressionSearch) range:NSMakeRange(0, lid.length)];
                
                [self savePath:path aid:aid];
                if(compCb)compCb(YES);
                
            });
            return;
        }
        if(compCb)compCb(NO);
        NSLog(@"%@----",error);
    }];
}
@end



@implementation ALUtil:NSObject
+(void)setImgFromALURL:(NSURL*)alurl cb:(void(^)(UIImage *))cb{
    if(!alurl){
        if(cb)cb(nil);
        return;
    }
    
    ALAssetsLibraryAssetForURLResultBlock resultblock=^(ALAsset *asset){
        ALAssetRepresentation* rep = asset.defaultRepresentation;
        __unsafe_unretained CGImageRef iref =  [rep fullResolutionImage];
        UIImage * image = [UIImage imageWithCGImage:iref];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(cb)cb(image);
        });
    };
    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *error){
        NSLog(@"\n-----load ALAssets fail------\n");
        if(cb)cb(nil);
    };
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:alurl resultBlock:resultblock failureBlock:failureblock];
}
+(void)videoFromALURL:(NSURL *)alurl cb:(void(^)(ALAsset *asset))cb{
    if(!alurl){
        if(cb)cb(nil);
        return;
    }
    ALAssetsLibraryAssetForURLResultBlock resultblock=^(ALAsset *asset){
        if(cb)cb(asset);
    };
    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *error){
        NSLog(@"\n-----load ALAssets fail------\n");
        if(cb)cb(nil);
    };
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:alurl resultBlock:resultblock failureBlock:failureblock];
}
@end
