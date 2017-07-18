//
//  HashViewController.h
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger,HASHType)
{
    HASHType_MD5,
    HASHType_SHA,
    HASHType_SM3,
    HASHType_HMAC
};

@interface HashViewController : NSViewController


- (void)setHashType:(HASHType)type;

@end
