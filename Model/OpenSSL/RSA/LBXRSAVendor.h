//
//  LBXRSAVendor.h
//  DataHandler
//
//  Created by lbxia on 2016/11/9.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 动态创建RSA密钥对(利用ios钥匙串)
 加载证书转换公私钥
 */
@interface LBXRSAVendor : NSObject

@property (nonatomic,readonly) NSData   *publicKeyBits;
@property (nonatomic,readonly) NSData   *privateKeyBits;


//测试代码
+ (void)test;

+ (instancetype)sharedManager;

#pragma mark ---   代码创建公私钥对  -----


- (void)generateWithKeyLength:(NSUInteger)keyLength result:(void(^)(BOOL isSuccess))result;


#pragma mark --- 加载证书文件，生成公私钥对对象 ----



/**
 加载公私钥文件

 @param publicData 公钥数据
 @param privateData 私钥数据
 @param pwd 私钥文件密码
 @return YES if success,NO if fail
 */
- (BOOL)loadRSAPairWithPublicData:(NSData*)publicData privateData:(NSData*)privateData privatePwd:(NSString*)pwd;


/**
 加载公钥证书,生成公钥对象

 @param publicData 证书数据
 @return YES if success,NO if fail
 */
- (BOOL)loadPublicData:(NSData*)publicData;


/**
 加载私钥证书，生成私钥对象
 
 @param privateData 证书数据
 @param pwd 证书密码
 @return YES if success,NO if fail
 */
- (BOOL)loadWithPrivateData:(NSData*)privateData privatePwd:(NSString*)pwd;


#pragma mark ---  加解密 ------
/**
 RSA加密，目前代码私钥加密会返回 -50 错误
 
 @param data 待加密数据
 @param secPaddingType 填充方式
 @param isPublickey YES:公钥加密，NO:表示采用私钥加密
 @return 返回加密后的数据
 */
- (NSData*)encryptWithData:(NSData*)data padding:(SecPadding)secPaddingType keyMode:(BOOL)isPublickey;

/**
 RSA解密
 
 @param data 待解密数据
 @param secPaddingType 填充方式
 @param isPublickey YES:公钥解密，NO:表示采用私钥解密
 @return 返回加密后的数据
 */
- (NSData*)decryptWithData:(NSData*)data padding:(SecPadding)secPaddingType keyMode:(BOOL)isPublickey;


#pragma mark -----  签名、验证签名  -------
/**
 签名

 @param rawData 待签名数据，调用者可以先对数据进行摘要后输入
 @param padding 填充方式
 @return 返回签名数据
 */
- (NSData *)signData:(NSData *)rawData withPadding:(SecPadding)padding;



/**
 验证签名数据

 @param rawData 签名原始数据，需要与签名时的数据保持一致
 @param signature 签名数据
 @param padding 填充方式
 @return 成功 if YES,失败 if NO
 */
- (BOOL)verifyData:(NSData *)rawData withSignature:(NSData *)signature  withPadding:(SecPadding)padding;

@end
