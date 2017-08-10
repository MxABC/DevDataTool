//
//  NSData+LBXHash.m
//  DataHandler
//
//  Created by lbxia on 2017/5/9.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import "NSData+LBXHash.h"
#include "sm3.h"
#import "NSData+SHA3.h"
#import "NSData+LBXCommonCrypto.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>


//64 bytes 512bits
#define LBX_MD5_BLOCK_BYTES CC_MD5_BLOCK_BYTES

//64 bytes 512bits
#define LBX_SHA1_BLOCK_BYTES CC_SHA1_BLOCK_BYTES

//64 bytes 512bits
#define LBX_SHA2_224_BLOCK_BYTES CC_SHA224_BLOCK_BYTES

//64 bytes 512bits
#define LBX_SHA2_256_BLOCK_BYTES CC_SHA256_BLOCK_BYTES

//128 bytes 1024bits
#define LBX_SHA2_384_BLOCK_BYTES CC_SHA384_BLOCK_BYTES

//128 bytes 1024bits
#define LBX_SHA2_512_BLOCK_BYTES CC_SHA512_BLOCK_BYTES


//wiki看SHA3分组长度越来越小，应该与算法有关
//144 bytes/  1152bits
#define LBX_SHA3_224_BLOCK_BYTES 144

//136 bytes / 1088bits
#define LBX_SHA3_256_BLOCK_BYTES 136

//104 bytes / 832bits
#define LBX_SHA3_384_BLOCK_BYTES 104

//72 bytes / 576bits
#define LBX_SHA3_512_BLOCK_BYTES 72

//64 bytes 512bits
#define LBX_SM3_BLOCK_BYTES CC_SHA256_BLOCK_BYTES

//当前分组还没有超过256 bytes
#define LBX_MAX_BLOCK_BYTES 256

@implementation NSData (LBXHash)


/**
 *  MD5,结果为16字节
 *
 *  @return md5
 */
- (NSData*)md5
{
   return  [self MD5Sum];
}



/**
 *  SHA1,结果为20个字节
 *
 *  @return sha1
 */
- (NSData *)sha1;
{
    return [self SHA1Hash];
}
//
/**
 *  SHA256,结果为32个字节
 *
 *  @return sha256
 */
- (NSData*)sha2_256
{
    return [self SHA256Hash];
}

/**
 *  SHA256,结果为48个字节
 *
 *  @return sha256
 */
- (NSData*)sha2_384
{
    return [self SHA384Hash];
}

/**
 *  SHA256,结果为64个字节
 *
 *  @return sha512
 */
- (NSData*)sha2_512
{
    return [self SHA512Hash];
}


- (NSData*)sm3
{
    uint8_t sm3_hashes[32] = {0};
    
    sm3((uint8_t*)self.bytes, (uint32_t)self.length, sm3_hashes);
    
    return [NSData dataWithBytes:sm3_hashes length:32];
}



/**
 sm3 hmac

 @param key 16 bytes,NSString or NSData
 @return 32 bytes hmac
 */
- (NSData*)sm3_hmacWithKey:(id)key
{
    NSData *dataKey = nil;
    if ([key isKindOfClass:[NSData class]]) {
    
        dataKey = key;
        if (dataKey.length != 16) {
            return nil;
        }
       
    }else if ([key isKindOfClass:[NSString class]])
    {
        dataKey = [key dataUsingEncoding:NSUTF8StringEncoding];
        if (dataKey.length != 16) {
            return nil;
        }
    }else{
        return nil;
    }

    uint8_t hmac[LEN_OF_SM3_HASHES];
    sm3_hmac((uint8_t*)self.bytes, (uint32_t)self.length, (uint8_t*)dataKey.bytes, hmac);
    return [NSData dataWithBytes:hmac length:LEN_OF_SM3_HASHES];
}



//typedef uint32_t CCHmacAlgorithm;
//
- (NSData*)lbxHmacWithKey:(id)key algorithm:(LBXHmacAlgorithm)alg
{
    NSData *dataKey = nil;
    if ([key isKindOfClass:[NSData class]]) {
        
        dataKey = key;
        
    }else if ([key isKindOfClass:[NSString class]])
    {
        dataKey = [key dataUsingEncoding:NSUTF8StringEncoding];
       
    }else{
        return nil;
    }
    
    
    //密钥长度
    uint8_t keylength = (uint8)dataKey.length;
    
    //分组长度
    uint8_t blocksize = [self blockSizeWithAlg:alg];
    
    
    if (keylength > blocksize) {
        
        dataKey = [dataKey hashWithAlgorithm:alg];
    }
    
    if (keylength < blocksize) {
        
        //补0x00
        uint8_t zeroPadding[LBX_MAX_BLOCK_BYTES] = {0x00};
        
        NSMutableData *newKeyData = [[NSMutableData alloc]initWithCapacity:blocksize];
        [newKeyData appendData:dataKey];
        [newKeyData appendBytes:zeroPadding length:blocksize-keylength];
        
        dataKey = newKeyData;
    }
    
    //
    uint8_t o_key_pad[LBX_MAX_BLOCK_BYTES]={0};
    uint8_t i_key_pad[LBX_MAX_BLOCK_BYTES]={0};
    
    
    uint8_t *cKey = (uint8_t*)dataKey.bytes;
    for (int i = 0; i < blocksize; i++) {
        
        o_key_pad[i] = 0x5c ^ cKey[i];
        i_key_pad[i] = 0x36 ^ cKey[i];
    }
    
    //最后一步公式
//    hash(o_key_pad || hash(i_key_pad || message))
    NSData *rightPartData = [self concatWithArrayData:@[[NSData dataWithBytes:i_key_pad length:blocksize],self]];
    rightPartData = [rightPartData hashWithAlgorithm:alg];
    
    NSData *leftPartData = [NSData dataWithBytes:o_key_pad length:blocksize];
    
    NSData *hmacData = [self concatWithArrayData:@[leftPartData,rightPartData]];
    hmacData = [hmacData hashWithAlgorithm:alg];
    
    return hmacData;
}

- (NSData*)concatWithArrayData:(NSArray<NSData*>*)arrData
{
    NSMutableData *concatdata = [[NSMutableData alloc]init];
    for (NSData *data in arrData) {
        
        [concatdata appendData:data];
    }
    
    return concatdata;
}



- (uint8_t)blockSizeWithAlg:(LBXHmacAlgorithm)alg
{
    uint8_t blocksize = 0;
    switch (alg) {
            
        case LBXHmacAlgMD5:
            blocksize = LBX_MD5_BLOCK_BYTES;
            break;
            
        case LBXHmacAlgSHA1:
            blocksize = LBX_SHA1_BLOCK_BYTES;
            break;
        case LBXHmacAlgSHA224:
            blocksize = LBX_SHA2_224_BLOCK_BYTES;
            break;
        case LBXHmacAlgSHA256:
            blocksize = LBX_SHA2_256_BLOCK_BYTES;
            break;
        case LBXHmacAlgSHA384:
            blocksize = LBX_SHA2_384_BLOCK_BYTES;
            break;
        case LBXHmacAlgSHA512:
            blocksize = LBX_SHA2_512_BLOCK_BYTES;
            break;
        case LBXHmacAlgSHA3_224:
            blocksize = LBX_SHA3_224_BLOCK_BYTES;
            break;
        case LBXHmacAlgSHA3_256:
            blocksize = LBX_SHA3_256_BLOCK_BYTES;
            break;
        case LBXHmacAlgSHA3_384:
            blocksize = LBX_SHA3_384_BLOCK_BYTES;
            break;
        case LBXHmacAlgSHA3_512:
            blocksize = LBX_SHA3_512_BLOCK_BYTES;
            break;
        case LBXHmacAlgSM3:
            blocksize = LBX_SM3_BLOCK_BYTES;
            break;
            
            
        default:
            break;
    }
    
    return blocksize;
}



- (NSData*)hashWithAlgorithm:(LBXHmacAlgorithm)alg
{
    NSData *hashData = nil;
    switch (alg) {
            
        case LBXHmacAlgMD5:
            hashData = self.MD5Sum;
            break;
        case LBXHmacAlgSHA1:
            hashData = self.SHA1Hash;
            break;

        case LBXHmacAlgSHA224:
            hashData = self.SHA224Hash;
            break;

        case LBXHmacAlgSHA256:
            hashData = self.SHA224Hash;
            break;

        case LBXHmacAlgSHA384:
            hashData = self.SHA384Hash;
            break;

        case LBXHmacAlgSHA512:
            hashData = self.SHA512Hash;
            break;

        case LBXHmacAlgSHA3_256:
            hashData = [self sha3:256];
            break;
        case LBXHmacAlgSHA3_384:
            hashData = [self sha3:384];
            break;
        case LBXHmacAlgSHA3_512:
            hashData = [self sha3:512];
            break;
        case LBXHmacAlgSM3:
            hashData = [self sm3];
            break;
        default:
            break;
    }
    return hashData;
}




@end
