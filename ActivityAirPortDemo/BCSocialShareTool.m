//
//  BCSocialShareTool.m
//  BatteryCam
//
//  Created by ocean on 2018/12/21.
//  Copyright © 2018年 oceanwing. All rights reserved.
//

#import "BCSocialShareTool.h"
#import <UIKit/UIKit.h>
#import "BCMailTool.h"
#import <Photos/Photos.h>
#import "BCPHAidPref.h"
#import "AppDelegate.h"

static NSString *const kYouTubeType = @"YouTube";
static NSString *const kMailType = @"Mail";

static NSString *const kYouTubeImage = @"share_youtube_icon";
static NSString *const kMailImage = @"share_email_icon";


@interface HBShareBaseActivity : UIActivity
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *localPath;

@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, copy) NSString *shareDescription;
@property (nonatomic, copy) NSString *shareTitle;

//mail
@property (nonatomic, strong) BCMailTool *mailTool;

- (instancetype)initWithTitle:(NSString *)title type:(NSString *)type path:(NSString*)urlPath;
@end


@implementation HBShareBaseActivity

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}


- (instancetype)initWithTitle:(NSString *)title type:(NSString *)type path:(NSString*)urlPath {
    if (self = [super init]) {
        self.title = title;
        self.type = type;
        self.localPath = urlPath;
    }
    return self;
}
- (NSString *)activityTitle {
    return self.title;
}
- (NSString *)activityType {
    return self.title;
}
- (UIImage *)activityImage {
    NSString *imageName = kYouTubeImage;
    if ([self.type isEqualToString:kYouTubeType]) {
        imageName = kYouTubeImage;
    }else if ([self.type isEqualToString:kMailType] || [self.type isEqualToString:UIActivityTypeMail]) {
        imageName = kMailImage;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    return image;
}
- (void)prepareWithActivityItems:(NSArray *)activityItems {
    
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}
- (void)performActivity {
    
    if ([self.type isEqualToString:kYouTubeType]) {
        //在这里可以实现YouTube分享代码
        
        
    }else if ([self.type isEqualToString:kMailType] || [self.type isEqualToString:UIActivityTypeMail]) {
        //在这里可以实现Mail分享代码
        BCMailTool *mailTool = [[BCMailTool alloc]init];
        [mailTool sendMailWithLocalPath:self.localPath];
        _mailTool = mailTool;
    }
}
@end




@interface BCSocialShareTool ()
@property (nonatomic, copy) UIActivityViewControllerCompletionHandler completionHandler;
@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, strong) NSURL *assetUrlPath;
@end

@implementation BCSocialShareTool

- (void)shareWithTitle:(NSString *)title description:(NSString *)description url:(NSString *)path image:(UIImage *)image completionHandler:(UIActivityViewControllerCompletionHandler)completionHandler {
    
    self.assetUrlPath = nil;
    self.localPath = path;
    [self createAssetPathWithLocalPath:path completion:^(BOOL success, NSURL *assetURL) {
        [self inner_shareWithTitle:title description:description assetUrl:assetURL image:image completionHandler:^(UIActivityType  _Nullable activityType, BOOL completed) {
            if (completionHandler) {
                completionHandler(activityType, completed);
            }
        }];
    }];
}

- (void)inner_shareWithTitle:(NSString *)title description:(NSString *)description assetUrl:(NSURL *)url image:(UIImage *)image completionHandler:(UIActivityViewControllerCompletionHandler)completionHandler
{
    //需要分享的内容: 标题、图片、url
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (title) {
        [items addObject:title];
    }
    if (image) {
        [items addObject:image];
    }
//    if (url) {
//        [items addObject:url];
//    }
    if (self.localPath) {
        NSURL *urlPath = [NSURL fileURLWithPath:_localPath];
        [items addObject:urlPath];
    }
    
    //自定义“分享目标icon”
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    //youtube
    HBShareBaseActivity *youtubeActivity = [[HBShareBaseActivity alloc] initWithTitle:@"YouTube" type:kYouTubeType path:_localPath];
    //mail
    HBShareBaseActivity *mailActivity = [[HBShareBaseActivity alloc] initWithTitle:NSLocalizedString(@"bc.player.share_mail_title", 0) type:UIActivityTypeMail path:_localPath];//
    //
    [@[mailActivity, youtubeActivity] enumerateObjectsUsingBlock:^(HBShareBaseActivity *activity, NSUInteger idx, BOOL *stop) {
        activity.shareDescription = description;
        activity.shareTitle = title;
        activity.shareImage = image;
    }];
    [activities addObjectsFromArray:@[mailActivity, youtubeActivity]]; //
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:activities];
    //需要屏蔽的系统分享
    NSArray *excludedActivityTypes =  @[UIActivityTypePostToFacebook,
                                        UIActivityTypePostToTwitter,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeMessage,
                                        UIActivityTypeMail,
                                        UIActivityTypePrint,
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact,
                                        UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList,
                                        UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo,
                                        UIActivityTypePostToTencentWeibo,
                                        //UIActivityTypeAirDrop,
                                        UIActivityTypeOpenInIBooks,
                                        //UIActivityTypeMarkupAsPDF
                                        ];
    
    activityViewController.excludedActivityTypes = excludedActivityTypes;
    AppDelegate *iApp = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [iApp.window.rootViewController presentViewController:activityViewController animated:YES completion:nil];
    //[UIViewController.topVC presentViewController:activityViewController animated:YES completion:nil];
    
    activityViewController.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        NSLog(@"social share activityType=%@, returnedItems=%@", activityType, returnedItems);
        if (completionHandler) {
            completionHandler(activityType, completed);
            self.completionHandler = nil;
        }
    };
}

//保存本地文件到相册
-(void)createAssetPathWithLocalPath:(NSString*)path completion:(void(^)(BOOL success, NSURL *assetURL))compleiton {
    
    //@weakRef(self);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status==PHAuthorizationStatusAuthorized){
            [self saveLocalVideoToAsset:path completion:^(BOOL success, NSURL *assetURL) {
                if (compleiton) {
                    compleiton(success, assetURL);
                }
            }];
        }
    }];
}
-(void)saveLocalVideoToAsset:(NSString*)path completion:(void(^)(BOOL success, NSURL *assetURL))block{
    [BCPHAidPref assetUrlByPath:path cb:^(NSURL *assUrl) {
        if(assUrl){
            if (block) {
                block(YES, assUrl);
            }
            return;
        }
        
        [BCPHAidPref saveVideoToAlbum:path compCb:^(BOOL suc) {
            if(suc){
                NSURL *url = [BCPHAidPref assetUrlByPath:path];
                block(YES, url);
            }else{
                //保存失败
                block(NO, nil);
            }
        }];
    }];
}

@end
