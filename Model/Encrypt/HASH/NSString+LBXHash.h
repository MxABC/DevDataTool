//
//  NSString+LBXHash.h
//  EncryptionDeciphering
//
//  Created by lbxia on 16/9/2.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (LBXHash)


#pragma mark --散列算法

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
 *  SHA256,结果为48个字节
 *
 *  @return sha256
 */
- (NSData*)sha2_384;

/**
 *  SHA256,结果为64个字节
 *
 *  @return sha512
 */
- (NSData*)sha2_512;


#pragma mark - HMAC 散列函数


/**
 *  HMAC是密钥相关的哈希运算消息认证码（Hash-based Message Authentication Code）,
 *  HMAC运算利用哈希算法，以一个密钥和一个消息为输入，生成一个消息摘要作为输出。
 */

/**
 *  HMAC,MD5散列，结果为16字节
 *
 *  @param key 密钥
 *
 *  @return MD5
 */
- (NSData *)hMAC_MD5WithKey:(NSString *)key;

/**
 *  HMAC,SHA1散列，结果为20字节
 *
 *  @param key 密钥
 *
 *  @return SHA1
 */
- (NSData *)hMAC_SHA1WithKey:(NSString *)key;


#pragma mark - 文件散列函数

/**
 *  当前为文件路径，计算文件的MD5
 *
 *  @return 文件MD5
 */
- (NSData *)fileMD5Hash;

/**
 *  当前为文件路径，计算文件的SHA1，结果20字节
 *
 *  @return 文件SHA1
 */
- (NSData *)fileSHA1Hash;

@end
