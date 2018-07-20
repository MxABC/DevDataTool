//
//  NSString+LBXBase64.m
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "NSString+LBXBase64.h"


@implementation NSString (LBXBase64)

- (NSData*)decodeBase64StringWithOptions:(NSDataBase64DecodingOptions)options
{
    return  [[NSData alloc]initWithBase64EncodedString:self options:options];
}

@end



