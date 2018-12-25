//
//  BCMailTool.m
//  BatteryCam
//
//  Created by ocean on 2018/12/22.
//  Copyright © 2018年 oceanwing. All rights reserved.
//

#import "BCMailTool.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"

@interface BCMailTool ()<MFMailComposeViewControllerDelegate>
@property (nonatomic, copy) NSString *urlPath;
@property (nonatomic, strong) MFMailComposeViewController *mailCompose;

@end

@implementation BCMailTool

-(void)sendMailWithLocalPath:(NSString*)urlPath {
    
    self.urlPath = urlPath;
    
    [self sendMailAction];
}

- (void)sendMailAction {
    
    //附件
    NSData* pData = [[NSData alloc]initWithContentsOfFile:self.urlPath];
    if (pData) {
        
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        _mailCompose = mailCompose;
        if(mailCompose) {
            
            //设置代理
            [mailCompose setMailComposeDelegate:self];
            
            NSArray *toAddress = [NSArray arrayWithObject:@""]; //收件人
            NSArray *ccAddress = [NSArray arrayWithObject:@""]; //抄送人
            NSString *emailBody = @"<H1></H1>";                 //邮件内容
            
            //设置收件人
            [mailCompose setToRecipients:toAddress];
            //设置抄送人
            [mailCompose setCcRecipients:ccAddress];
            //设置邮件内容
            [mailCompose setMessageBody:emailBody isHTML:YES];
            
            //设置邮件主题
            [mailCompose setSubject:@""];           //邮件主题 email title
            //设置邮件附件{mimeType:文件格式|fileName:文件名}
            NSString *lastName = [_urlPath componentsSeparatedByString:@"/"].lastObject;
            NSString *fileExtension = [lastName componentsSeparatedByString:@"."].lastObject;
            if (!lastName) {
                lastName = @"test.mp4";
            }
            if (!fileExtension) {
                fileExtension = @"mp4";
            }
            [mailCompose addAttachmentData:pData mimeType:fileExtension fileName:lastName];
            //设置邮件视图在当前视图上显示方式
            AppDelegate *iApp = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [iApp.window.rootViewController presentViewController:mailCompose animated:YES completion:nil];
            //[UIViewController.topVC presentViewController:mailCompose animated:YES completion:nil];
        }
        return;
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    NSString *msg = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            break;
        case MFMailComposeResultSaved:
            msg = @"邮件保存成功";
            break;
        case MFMailComposeResultSent:
            msg = @"邮件发送成功";
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            break;
        default:
            break;
    }
    NSLog(@"发送邮件: %@", msg);
    [_mailCompose dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc {
    NSLog(@"dealloc");
}

@end
