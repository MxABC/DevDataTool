//
//  NSData+LBXHash.h
//  DataHandler
//
//  Created by lbxia on 2017/5/9.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>


//自实现hmac计算方法
typedef NS_ENUM(uint32_t,LBXHmacAlgorithm)
{
    LBXHmacAlgSHA1,
    LBXHmacAlgMD5,
    LBXHmacAlgSHA256,
    LBXHmacAlgSHA384,
    LBXHmacAlgSHA512,
    LBXHmacAlgSHA224,
    LBXHmacAlgSHA3_224,
    LBXHmacAlgSHA3_256,
    LBXHmacAlgSHA3_384,
    LBXHmacAlgSHA3_512,
    LBXHmacAlgSM3
};


@interface NSData (LBXHash)


#pragma mark --散列算法

/*
 单位 字节
 md5:摘要长度16字节(128位)分组长度64字节

 SHA1:摘要长度 20字节(160位) 分组长度64字节

 SHA256:摘要长度 32字节(256位) 分组长度64字节

 SHA512:摘要长度 64字节(512位) 分组长度128字节

 SM3:摘要长度 32字节(128位) 分组长度64字节

 SM3强度与SHA256 一个级别

 hmac密钥需要与分组长度一致，实际不足，默认都是内部补0
 */

/**
 *  MD5,结果为16字节
 *
 *  @return md5
 */
- (NSData*)md5;

/**
 *  SHA1,结果为20个字节
 *
 *  @return sha1
 */
- (NSData *)sha1;

/**
 *  SHA256,结果为32个字节
 *
 *  @return sha256
 */
- (NSData*)sha2_256;

/**
 *  SHA384,结果为48个字节
 *
 *  @return sha384
 */
- (NSData*)sha2_384;

/**
 *  SHA512,结果为64个字节
 *
 *  @return sha512
 */
- (NSData*)sha2_512;


/**
 sha3  keccak digest algorithm
 
 @param bitsLength digest len, 256、384、512
 @return keccak digest data
 */
- (NSData*)sha3:(NSUInteger)bitsLength;



/**
 sm3 hash，security equal to sha2_256

 @return 256 bits digest
 */
- (NSData*)sm3;


/**
 hmac

 @param key key, will padding zero if key length less than block size,
 @param alg algorithm
 @return hmac
 */
- (NSData*)hmacWithKey:(NSData*)key algorithm:(LBXHmacAlgorithm)alg;

@end
