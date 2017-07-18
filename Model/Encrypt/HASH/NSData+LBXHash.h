//
//  NSData+LBXHash.h
//  DataHandler
//
//  Created by lbxia on 2017/5/9.
//  Copyright © 2017年 LBX. All rights reserved.
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



/**
 sm3 hash，security equal to sha2_256

 @return 256 bits digest
 */
- (NSData*)sm3;


/**
 sm3 hmac
 
 @param key 16 bytes,NSString or NSData
 @return 32 bytes hmac
 */
- (NSData*)sm3_hmacWithKey:(id)key;


/**
 hmac,SHA3 every time result is diff

 @param key key,NSString or NSData
 @param alg algorith
 @return hmac
 */
- (NSData*)lbxHmacWithKey:(id)key algorithm:(LBXHmacAlgorithm)alg;

@end
