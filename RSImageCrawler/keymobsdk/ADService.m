//
//  ADService.m
//  LiQingzhaoPoetry
//
//  Created by shen on 16/2/20.
//  Copyright © 2016年 shen. All rights reserved.
//

#import "ADService.h"

@implementation ADService

+(ADService*)sharedInstance {
    
    static ADService *ADServiceclass;
    static dispatch_once_t ADServiceclassonce;
    dispatch_once(&ADServiceclassonce, ^{
        ADServiceclass = [[ADService alloc] init];
    });
    return ADServiceclass;
}

-(id)init{
    if (self = [super init]) {
        [AdManager sharedInstance].listener=[[AdListener alloc]init];
//#error 填写你自己的keymob的appID，如果你愿意帮我打广告，我更谢谢你了，O(∩_∩)O
        [[AdManager sharedInstance] configWithKeymobService:@"10371" isTesting:NO];
    }
    return self;
}

-(void)showFullScreenAD:(UIViewController *)controller{
    [AdManager sharedInstance].controller = controller;
    if([[AdManager sharedInstance] isInterstitialReady]){
        [[AdManager sharedInstance] showInterstitialWithController:controller];
    }else{
        [[AdManager sharedInstance] loadInterstitial];
    }
}

@end
