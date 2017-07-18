//
//  NSString+LBXHash.m
//  EncryptionDeciphering
//
//  Created by lbxia on 16/9/2.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "NSString+LBXHash.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

#import "NSString+LBXConverter.h"
#import "NSData+LBXConverter.h"
#import "NSData+LBXCommonCrypto.h"

@implementation NSString (LBXHash)


#pragma mark -HASH
- (NSData*)md5
{
    return [self.utf8Data MD5Sum];
}


- (NSData *)sha1
{
    return [self.utf8Data SHA1Hash];
}

- (NSData*)sha2_256
{
    return [self.utf8Data SHA256Hash];
}
- (NSData*)sha2_384
{
    return [self.utf8Data SHA384Hash];
}
- (NSData*)sha2_512
{
    return [self.utf8Data SHA512Hash];
}

#pragma mark - HMAC 散列函数

- (NSData *)hMAC_MD5WithKey:(NSString *)key{
    return [self.utf8Data HMACWithAlgorithm:kCCHmacAlgMD5 key:key];
}

- (NSData *)hMAC_SHA1WithKey:(NSString *)key {
    return [self.utf8Data HMACWithAlgorithm:kCCHmacAlgSHA1 key:key];
}

- (NSData*)hMacWithAlgorithm:(CCHmacAlgorithm) algorithm key: (id) key{
    return [self.utf8Data HMACWithAlgorithm:algorithm key:key];
}

#pragma mark - 文件散列函数

#define FileHashDefaultChunkSizeForReadingData 4096

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


- (NSString *)stringFromBytes:(uint8_t *)bytes length:(int)length {
    NSMutableString *strM = [NSMutableString string];
    
    for (int i = 0; i < length; i++) {
        [strM appendFormat:@"%02x", bytes[i]];
    }
    
    return [strM copy];
}


@end
