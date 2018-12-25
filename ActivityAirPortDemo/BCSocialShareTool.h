//
//  BCSocialShareTool.h
//  BatteryCam
//
//  Created by ocean on 2018/12/21.
//  Copyright © 2018年 oceanwing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface BCSocialShareTool : NSObject

- (void)shareWithTitle:(NSString *)title description:(NSString *)description url:(NSString *)path image:(UIImage *)image completionHandler:(UIActivityViewControllerCompletionHandler)completionHandler;

@end
