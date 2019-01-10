//
//  ViewController.m
//  ActivityAirPortDemo
//
//  Created by ocean on 2018/12/25.
//  Copyright © 2018年 ocean. All rights reserved.
//

#import "ViewController.h"
#import "BCSocialShareTool.h"

@interface ViewController ()
- (IBAction)shareButtonAction:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    NSString *localPath = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"MP4"];
    NSURL *urlPath1 = [NSURL fileURLWithPath:localPath];
    NSURL *urlPath2 = [NSURL URLWithString:localPath];
    NSLog(@"localPath=%@", localPath);
    NSLog(@"urlPath1=%@", urlPath1);
    NSLog(@"urlPath2=%@", urlPath2);
}


- (IBAction)shareButtonAction:(UIButton *)sender {
    
    NSString *localPath = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"MP4"];
    //这里URL是用[NSURL fileURLWithPath:localPath];
    [[[BCSocialShareTool alloc]init]shareWithTitle:nil description:nil url:localPath image:nil completionHandler:^(UIActivityType  _Nullable activityType, BOOL completed) {
    }];
}
@end
