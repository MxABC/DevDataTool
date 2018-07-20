//
//  NSData+LBXBase64.m
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "NSData+LBXBase64.h"
#import "NSData+LBXConverter.h"

@implementation NSData (LBXBase64)


- (NSString*)encodeBase64WithOptions:(NSDataBase64EncodingOptions)options
{
    return [self base64EncodedStringWithOptions:options];
}

- (NSString*)decodeBase64WithOptions:(NSDataBase64DecodingOptions)options
{
    NSData *nsdataFromBase64String = [[NSData alloc]initWithBase64EncodedString:self.utf8String options:options];
    
    return  [[NSString alloc]initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
}


@end
