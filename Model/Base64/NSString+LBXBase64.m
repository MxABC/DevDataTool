//
//  NSString+LBXBase64.m
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import "NSString+LBXBase64.h"


@implementation NSString (LBXBase64)


- (NSString*)encodeBase64WithOptions:(NSDataBase64EncodingOptions)options
{
    NSString *base64Encoded = [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:options];
    
    return base64Encoded;
}

- (NSString*)decodeBase64WithOptions:(NSDataBase64DecodingOptions)options
{
    NSData *nsdataFromBase64String = [[NSData alloc]initWithBase64EncodedString:self options:options];
    
    return  [[NSString alloc]initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
}

- (NSData*)decodeBase64StringWithOptions:(NSDataBase64DecodingOptions)options
{
    return  [[NSData alloc]initWithBase64EncodedString:self options:options];
}


@end
