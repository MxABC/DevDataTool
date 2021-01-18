//
//  NSString+LBXFileHash.m
//  DataHandler
//
//  Created by lbxia on 16/9/2.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "NSString+LBXFileHash.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#import "NSString+LBXConverter.h"
#import "NSData+LBXConverter.h"
#import "LBXSM3.h"

#pragma mark - 文件散列函数

#define FileHashDefaultChunkSizeForReadingData 4096

@implementation NSString (LBXFileHash)

- (NSData *)fileMD5Hash {
    NSFileHandle *fp = [NSFileHandle fileHandleForReadingAtPath:self];
    if (fp == nil) {
        return nil;
    }
    
    CC_MD5_CTX hashCtx;
    CC_MD5_Init(&hashCtx);
    
    while (YES) {
        @autoreleasepool {
            NSData *data = [fp readDataOfLength:FileHashDefaultChunkSizeForReadingData];
            
            CC_MD5_Update(&hashCtx, data.bytes, (CC_LONG)data.length);
            
            if (data.length == 0) {
                break;
            }
        }
    }
    [fp closeFile];
    
    uint8_t buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(buffer, &hashCtx);
    
    return [NSData dataWithBytes:buffer length:CC_MD5_DIGEST_LENGTH];

}

- (NSData *)fileSHA1Hash {
    NSFileHandle *fp = [NSFileHandle fileHandleForReadingAtPath:self];
    if (fp == nil) {
        return nil;
    }
    
    CC_SHA1_CTX hashCtx;
    CC_SHA1_Init(&hashCtx);
    
    while (YES) {
        @autoreleasepool {
            NSData *data = [fp readDataOfLength:FileHashDefaultChunkSizeForReadingData];
            
            CC_SHA1_Update(&hashCtx, data.bytes, (CC_LONG)data.length);
            
            if (data.length == 0) {
                break;
            }
        }
    }
    [fp closeFile];
    
    uint8_t buffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(buffer, &hashCtx);
    
    return [NSData dataWithBytes:buffer length:CC_SHA1_DIGEST_LENGTH];
    
}

- (NSData *)fileSHA256Hash
{
    NSFileHandle *fp = [NSFileHandle fileHandleForReadingAtPath:self];
    if (fp == nil) {
        return nil;
    }

    CC_SHA256_CTX hashCtx;
    CC_SHA256_Init(&hashCtx);
    
    while (YES) {
        @autoreleasepool {
            NSData *data = [fp readDataOfLength:FileHashDefaultChunkSizeForReadingData];
            
            CC_SHA256_Update(&hashCtx, data.bytes, (CC_LONG)data.length);
            
            if (data.length == 0) {
                break;
            }
        }
    }
    [fp closeFile];
    
    uint8_t buffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA256_Final(buffer, &hashCtx);
    
    return [NSData dataWithBytes:buffer length:CC_SHA1_DIGEST_LENGTH];
    
}

- (NSData*)fileSM3Hash
{
    return [LBXSM3 sm3WithFilePath:self];
}

@end
