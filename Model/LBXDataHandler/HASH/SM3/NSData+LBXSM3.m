//
//  NSData+LBXSM3.m
//  DataHandler
//
//  Created by lbxia on 2017/4/18.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "NSData+LBXSM3.h"
#import "LBXSM3.h"

@implementation NSData (LBXSM3)

- (NSData*)SM3
{
    return [LBXSM3 sm3WithData:self];
}

- (NSData*)HMACSM3WithKey:(NSData*)key
{
    return [LBXSM3 HMACSM3WithKey:self data:key];
}

@end
