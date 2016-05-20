//
//  ADService.h
//  LiQingzhaoPoetry
//
//  Created by shen on 16/2/20.
//  Copyright © 2016年 shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KeymobAd/KeymobAd.h>
#import "AdListener.h"
@interface ADService : NSObject

+(ADService*)sharedInstance;
-(void)showFullScreenAD:(UIViewController *)controller;
@end
