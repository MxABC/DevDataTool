//
//  NSData+LBXDES.m
//  DataHandler
//
//  Created by lbxia on 2016/10/28.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "NSData+LBXCrypt.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+LBXSM4.h"
#import "NSData+LBXConverter.h"

#ifdef LBXBigNum_File_Exist
//不需要CTR功能，可以不需要LBXBigNum,使用了openssl的大数
#import "LBXBigNum.h"
#endif



NSString * const LBXCryptErrorDomain = @"LBXCryptErrorDomain";

/**
 iOS/OSX 提供的加解密方法
 
 @param op encrpyt or decrpyt
 @param alg algorithm
 @param keyBytes key
 @param keylen keylen
 @param iv init vector
 @param plainBytes plain bytes
 @param plainLen plain len
 @param bufferPtr result buffer
 @param bufferPtrSize result bufferlen
 @param error err Info
 @return encrypt or decrpt datalen
 */
static inline size_t LBXCryptECB(LBXOperaton op,
                                 LBXAlgorithm alg,
                                 const void* keyBytes,
                                 uint8_t keylen,
                                 const void *iv,
                                 const void* plainBytes,
                                 size_t plainLen,
                                 void* bufferPtr,
                                 size_t bufferPtrSize,
                                 NSError **error);

/**
 XOR
 
 @param input data1
 @param output data2 and store result
 */
static void XOR( uint8_t *input,uint8_t *output,uint32_t datalen );



static bool errorCCCryptorStatus(CCCryptorStatus status,NSError **error)
{
    NSString * description = nil, * reason = nil;
    
    switch ( status )
    {
        case kCCSuccess:
            description = NSLocalizedString(@"Success", @"Error description");
            return true;
            break;
            
        case kCCParamError:
            description = NSLocalizedString(@"Parameter Error", @"Error description");
            reason = NSLocalizedString(@"Illegal parameter supplied to encryption/decryption algorithm", @"Error reason");
            break;
            
        case kCCBufferTooSmall:
            description = NSLocalizedString(@"Buffer Too Small", @"Error description");
            reason = NSLocalizedString(@"Insufficient buffer provided for specified operation", @"Error reason");
            break;
            
        case kCCMemoryFailure:
            description = NSLocalizedString(@"Memory Failure", @"Error description");
            reason = NSLocalizedString(@"Failed to allocate memory", @"Error reason");
            break;
            
        case kCCAlignmentError:
            description = NSLocalizedString(@"Alignment Error", @"Error description");
            reason = NSLocalizedString(@"Input size to encryption algorithm was not aligned correctly", @"Error reason");
            break;
            
        case kCCDecodeError:
            description = NSLocalizedString(@"Decode Error", @"Error description");
            reason = NSLocalizedString(@"Input data did not decode or decrypt correctly", @"Error reason");
            break;
            
        case kCCUnimplemented:
            description = NSLocalizedString(@"Unimplemented Function", @"Error description");
            reason = NSLocalizedString(@"Function not implemented for the current algorithm", @"Error reason");
            break;
            
        default:
            description = NSLocalizedString(@"Unknown Error", @"Error description");
            break;
    }
    
    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject: description forKey: NSLocalizedDescriptionKey];
    
    if ( reason != nil )
        [userInfo setObject: reason forKey: NSLocalizedFailureReasonErrorKey];
    
    if (error) {
        *error = [NSError errorWithDomain: LBXCryptErrorDomain code: status userInfo: userInfo];
    }
    return false;
}


/**
 iOS/OSX 提供的加解密方法
 
 @param op encrpyt or decrpyt
 @param alg algorithm
 @param keyBytes key
 @param keylen keylen
 @param iv init vector
 @param plainBytes plain bytes
 @param plainLen plain len
 @param bufferPtr result buffer
 @param bufferPtrSize result bufferlen
 @param error err Info
 @return encrypt or decrpt datalen
 */
static inline size_t LBXCryptECB(LBXOperaton op,
                                 LBXAlgorithm alg,
                                 const void* keyBytes,
                                 uint8_t keylen,
                                 const void *iv,
                                 const void* plainBytes,
                                 size_t plainLen,
                                 void* bufferPtr,
                                 size_t bufferPtrSize,
                                 NSError **error)
{
    
    
    size_t numBytesCrypted = 0;
    
    CCCryptorStatus ccStatus = CCCrypt(op,
                                       alg,
                                       kCCOptionECBMode,
                                       keyBytes,
                                       keylen,
                                       NULL,
                                       plainBytes,
                                       plainLen,
                                       bufferPtr,
                                       bufferPtrSize,
                                       &numBytesCrypted);
    
    
    if (ccStatus != kCCSuccess) {
        
        errorCCCryptorStatus(ccStatus, error);
        
        return 0;
    }
    return numBytesCrypted;
}


/**
 XOR

 @param input data1
 @param output data2 and store result
 */
void XOR( uint8_t *input,uint8_t *output,uint32_t datalen )
{
//    uint8_t *src = input;
//    uint8_t *dst = output;
//    
//    while (datalen > 0) {
//        
//        *dst ^= *src;
//        dst++;
//        src++;
//        --datalen;
//    }
    
    for (int i = 0; i < datalen; i++) {
        
        output[i] ^= input[i];
    }
    
}



@implementation NSData (LBXCrypt)




#pragma mark ------  自实现padding、 CBC、CFB

/**
 encrypt interface
 
 @param op encryt or decrypt
 @param alg encryt algorithm
 @param om ECB、CBC、CFB、OFB
 @param padding padding type
 @param key key
 @param iv init vector
 @param error return err info
 @return  result,fail if return nil
 */
- (NSData*)LBXCryptWithOp:(LBXOperaton)op
                algorithm:(LBXAlgorithm)alg
               optionMode:(LBXOptionMode)om
                  padding:(LBXPaddingMode)padding
                      key:(id)key
                       iv:(id)iv
                    error:(NSError**)error
{
    //密钥、iv检查设置
    NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
    NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
    
    NSMutableData *keyData = nil,*ivData = nil;
    if ( [key isKindOfClass: [NSData class]] )
        keyData = (NSMutableData *) [key mutableCopy];
    else
        keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    
    if ( [iv isKindOfClass: [NSString class]] )
        ivData = [[iv dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    else if ([iv isKindOfClass: [NSData class]])
        ivData = (NSMutableData *) [iv mutableCopy];	// data or nil
    
    
    if (![self LBXFixKeyLength:alg key:keyData iv:ivData]) {
        NSLog(@"密钥与iv长度不正确");
        
        if (error) {
            *error  = [NSError errorWithDomain:@"DataHandler" code:-1 userInfo:@{@"message":@"密钥或iv长度不正确"}];
        }
        
        return nil;
    }

    //加密或解密前数据
    NSData *plainData = self;
    NSLog(@"hex:%@",plainData.hexString);

    
    if (op == LBXOperaton_Encrypt) {
        
        //加密补位
        uint8_t blockSize = [self LBXBlockSize:alg];
        plainData = [plainData LBXPaddingWithMode:padding blockSize:blockSize];
        
        
        //如果plainData不是blockSize的整数倍，则不正确
        if (plainData.length % blockSize != 0) {
            
            if (error) {
                *error  = [NSError errorWithDomain:@"DataHandler" code:-1 userInfo:@{@"message":@"加密前数据分组后长度不正确"}];
            }
            return nil;
        }
    }
    
    NSLog(@"hex:%@",plainData.hexString);
    
    //加密或解密后的数据
    NSData *cryptData = nil;
    
    //加密或解密
    switch (om) {
        case LBXOptionMode_ECB:
            cryptData = [plainData LBXCryptECBWithOp:op algorithm:alg key:keyData iv:ivData error:error];
            break;
        case LBXOptionMode_CBC:
            cryptData = [plainData LBXCryptCBCWithOp:op algorithm:alg key:keyData iv:ivData error:error];
            break;
        case LBXOptionMode_PCBC:
            cryptData = [plainData LBXCryptPCBCWithOp:op algorithm:alg key:keyData iv:ivData error:error];
            break;
        case LBXOptionMode_CFB:
            cryptData = [plainData LBXCryptCFBWithOp:op algorithm:alg key:keyData iv:ivData error:error];
            break;
        case LBXOptionMode_OFB:
            cryptData = [plainData LBXCryptOFBWithOp:op algorithm:alg key:keyData iv:ivData error:error];
            break;
        case LBXOptionMode_CTR:
            cryptData = [plainData LBXCryptCTRWithOp:op algorithm:alg key:keyData iv:ivData error:error];
            break;
            
        default:
            break;
    }

    if (op == LBXOperaton_Decrypt) {
        
        NSLog(@"hex:%@",cryptData.hexString);
        
        //解密后除去补位数据
        cryptData = [cryptData LBXUnPaddingWithMode:padding];
    }
    
    return cryptData;
}

/**
 crypt ECB opertion
 
 @param op encryt or decrypt
 @param alg encryt algorithm
 @param key key
 @param iv init vector
 @param error return err info
 @return  result,fail if return nil
 */
- (NSData*)LBXCryptECBWithOp:(LBXOperaton)op
                algorithm:(LBXAlgorithm)alg
                      key:(NSData*)key
                       iv:(NSData*)iv
                    error:(NSError**)error
{
    
    NSData *cryptData = nil;
    switch (alg) {
        case LBXAlgorithm_DES:
        case LBXAlgorithm_3DES:
        case LBXAlgorithm_AES128:
        case LBXAlgorithm_RC2:
        case LBXAlgorithm_RC4:
        case LBXAlgorithm_CAST:
        case LBXAlgorithm_Blowfish:
        {
            uint8_t tmp[1024];
            void *bufferPtr = NULL;
            NSInteger bufferPtrSize = self.length;
            
            if (self.length > 1024) {
                bufferPtr = (void*)malloc(self.length);
            }else{
                bufferPtr = tmp;
            }
            
            NSInteger datalen = LBXCryptECB(op, alg, key.bytes, key.length, iv.bytes, self.bytes, self.length, bufferPtr, bufferPtrSize, error);
            if (datalen > 0) {
                cryptData = [NSData dataWithBytes:(const void*)bufferPtr length:datalen];
            }
            
            if (bufferPtr != tmp) {
                free(bufferPtr);
                bufferPtr = NULL;
            }
            
        }
            break;
        case LBXAlgorithm_SM4:
        {//调用C方法
            
            cryptData = [self sm4WithOp:op optionMode:LBXOptionMode_ECB key:key iv:iv];
            
        }
            break;
            
        default:
            break;
    }

   
    return cryptData;
}




/**
 crypt CBC opertion
 
 @param op encryt or decrypt
 @param alg encryt algorithm
 @param key key
 @param iv init vector
 @param error return err info
 @return  result,fail if return nil
 */
- (NSData*)LBXCryptCBCWithOp:(LBXOperaton)op
                   algorithm:(LBXAlgorithm)alg
                         key:(NSData*)key
                          iv:(NSData*)iv
                       error:(NSError**)error
{
    NSData *cryptData = nil;
    switch (alg) {
        case LBXAlgorithm_DES:
        case LBXAlgorithm_3DES:
        case LBXAlgorithm_AES128:
//        case LBXAlgorithm_RC2:
//        case LBXAlgorithm_RC4:
        case LBXAlgorithm_CAST:
        case LBXAlgorithm_Blowfish:
        {
            //利用ECB算法加密每个分组，然后
            uint8_t tmp[512];
            void *bufferPtr = tmp;
            uint32_t blockSize = [self LBXBlockSize:alg];
            NSInteger bufferPtrSize = blockSize;
            
            uint8_t blockData[512];
            
            
            uint8_t preData[512]={0x00};
            if (iv) {
                memcpy(preData, iv.bytes, blockSize);
            }else{
                memset(preData, 0x00, blockSize);
            }
            
            //CBC
            NSMutableData *cbcData = [[NSMutableData alloc]initWithCapacity:bufferPtrSize];
            NSInteger len = self.length / blockSize;
            
            unsigned char* pBytes = (unsigned char*)self.bytes;
            
//            NSLog(@"src:%@",self.hexString);
            
            if (op == LBXOperaton_Encrypt) {
                //encrypt
                for (int i = 0; i < len; i++)
                {
                    memcpy(blockData, pBytes + i * blockSize, blockSize);
                    
                    XOR(preData, blockData, blockSize);
                    
                    NSInteger datalen = LBXCryptECB(op, alg,key.bytes, key.length, NULL, blockData, blockSize, bufferPtr, bufferPtrSize, error);
                    
                    if (datalen != blockSize) {
                        
                        NSLog(@"    LBXCryptECB faile     ");
                    }
                    
                    //存储结果作为下一个分组的iv
                    memcpy(preData, bufferPtr, bufferPtrSize);
                    //存储分组数据
                    [cbcData appendBytes:bufferPtr length:bufferPtrSize];
                }
            }else{
                
                //decrypt
                for (int i = 0; i < len; i++)
                {
                    memcpy(blockData, pBytes + i * blockSize, blockSize);
                    
                    NSInteger datalen = LBXCryptECB(op, alg,key.bytes, key.length, NULL, blockData, blockSize, bufferPtr, bufferPtrSize, error);
                    
                    if (datalen != blockSize) {
                        
                        NSLog(@"    LBXCryptECB faile     ");
                    }
                    
                    //XOR
                    XOR(preData, bufferPtr, blockSize);
                    
                    //存储上一次的密文结果作为下一个分组的iv
                    memcpy(preData, pBytes + i * blockSize, blockSize);
        
                    //存储分组数据
                    [cbcData appendBytes:bufferPtr length:bufferPtrSize];
                    
                    NSLog(@"cbc hex:%@",cbcData.hexString);

                }
                
            }
            
            NSLog(@"cbc hex:%@",cbcData.hexString);
            
            cryptData = cbcData;
            
        }
            break;
        case LBXAlgorithm_SM4:
        {//调用C方法
            if (iv == nil || iv.length != 16) {
                
                uint8_t zero[16] = {0};
                iv = [NSData dataWithBytes:zero length:16];
            }
            cryptData = [self sm4WithOp:op optionMode:LBXOptionMode_CBC key:key iv:iv];
        }
            break;
            
        default:
            break;
    }
    
    
    return cryptData;
   
}

/**
 crypt PCBC opertion
 
 @param op encryt or decrypt
 @param alg encryt algorithm
 @param key key
 @param iv init vector
 @param error return err info
 @return  result,fail if return nil
 */
- (NSData*)LBXCryptPCBCWithOp:(LBXOperaton)op
                   algorithm:(LBXAlgorithm)alg
                         key:(NSData*)key
                          iv:(NSData*)iv
                       error:(NSError**)error
{
    NSData *cryptData = nil;
    switch (alg) {
        case LBXAlgorithm_DES:
        case LBXAlgorithm_3DES:
        case LBXAlgorithm_AES128:
            //        case LBXAlgorithm_RC2:
            //        case LBXAlgorithm_RC4:
        case LBXAlgorithm_CAST:
        case LBXAlgorithm_Blowfish:
        case LBXAlgorithm_SM4:
        {
            //利用ECB算法加密每个分组，然后
            uint8_t tmp[512];
            void *bufferPtr = tmp;
            uint32_t blockSize = [self LBXBlockSize:alg];
            NSInteger bufferPtrSize = blockSize;
            
            uint8_t blockData[512];
            
            
            uint8_t preData[512]={0x00};
            if (iv) {
                memcpy(preData, iv.bytes, blockSize);
            }else{
                memset(preData, 0x00, blockSize);
            }
            
            //CBC
            NSMutableData *cbcData = [[NSMutableData alloc]initWithCapacity:bufferPtrSize];
            NSInteger len = self.length / blockSize;
            
            unsigned char* pBytes = (unsigned char*)self.bytes;
            
            //            NSLog(@"src:%@",self.hexString);
            
            if (op == LBXOperaton_Encrypt) {
                //encrypt
                for (int i = 0; i < len; i++)
                {
                    memcpy(blockData, pBytes + i * blockSize, blockSize);
                    
                    XOR(preData,blockData, blockSize);
                    
            
                    
                    if (alg == LBXAlgorithm_SM4) {
                        
                        NSData *preNSData = [NSData dataWithBytes:blockData length:blockSize];
                        
                        NSData *resultData = [preNSData sm4WithOp:LBXOperaton_Encrypt optionMode:LBXOptionMode_ECB key:key iv:nil];
                        
                        memcpy(bufferPtr, resultData.bytes, blockSize);
                    }else{
                        
                        NSInteger datalen = LBXCryptECB(op, alg,key.bytes, key.length, NULL, blockData, blockSize, bufferPtr, bufferPtrSize, error);
                        
                        if (datalen != blockSize) {
                            
                            NSLog(@"    LBXCryptECB faile     ");
                        }
                    }
                    
                    
                    
                    //存储结果作为下一个分组的iv
                    memcpy(preData, bufferPtr, bufferPtrSize);
                    XOR(blockData, preData, blockSize);
                    
                    //存储分组数据
                    [cbcData appendBytes:bufferPtr length:bufferPtrSize];
                }
            }else{
                
                //decrypt
                for (int i = 0; i < len; i++)
                {
                    memcpy(blockData, pBytes + i * blockSize, blockSize);
                    
                    if (alg == LBXAlgorithm_SM4) {
                        
                        NSData *preNSData = [NSData dataWithBytes:blockData length:blockSize];
                        
                        NSData *resultData = [preNSData sm4WithOp:op optionMode:LBXOptionMode_ECB key:key iv:nil];
                        
                        memcpy(bufferPtr, resultData.bytes, blockSize);
                    }else{
                        
                    NSInteger datalen = LBXCryptECB(op, alg,key.bytes, key.length, NULL, blockData, blockSize, bufferPtr, bufferPtrSize, error);
                        
                        if (datalen != blockSize) {
                            
                            NSLog(@"    LBXCryptECB faile     ");
                        }
                    }
                    //XOR
                    XOR(preData, bufferPtr, blockSize);
                    
                    //存储分组数据
                    [cbcData appendBytes:bufferPtr length:bufferPtrSize];
                
                    //存储加密结果与明文异或，作为下一组的iv
                    XOR(bufferPtr, blockData, blockSize);
                    memcpy(preData, blockData, blockSize);
                }
                
            }
            
            cryptData = cbcData;
            
        }
            break;
        
            
        default:
            break;
    }
    
    
    return cryptData;
    
}




/**
 crypt CFB opertion
 
 @param op encryt or decrypt
 @param alg encryt algorithm
 @param key key
 @param iv init vector
 @param error return err info
 @return  result,fail if return nil
 */
- (NSData*)LBXCryptCFBWithOp:(LBXOperaton)op
                   algorithm:(LBXAlgorithm)alg
                         key:(NSData*)key
                          iv:(NSData*)iv
                       error:(NSError**)error
{
    NSData *cryptData = nil;
    switch (alg) {
        case LBXAlgorithm_DES:
        case LBXAlgorithm_3DES:
        case LBXAlgorithm_AES128:
//        case LBXAlgorithm_RC2:
//        case LBXAlgorithm_RC4:
        case LBXAlgorithm_CAST:
        case LBXAlgorithm_Blowfish:
        case LBXAlgorithm_SM4:
        {
            //利用ECB算法加密每个分组，然后
            uint8_t tmp[512];
            void *bufferPtr = tmp;
            uint32_t blockSize = [self LBXBlockSize:alg];
            uint32_t bufferPtrSize = blockSize;
            
            uint8_t blockData[512];
            
            
            uint8_t preData[512]={0x00};
            if (iv) {
                memcpy(preData, iv.bytes, blockSize);
            }else{
                memset(preData, 0x00, blockSize);
            }
            
            //CBC
            NSMutableData *cbcData = [[NSMutableData alloc]initWithCapacity:bufferPtrSize];
            NSInteger len = self.length / blockSize;
            
            unsigned char* pBytes = (unsigned char*)self.bytes;
            
            //            NSLog(@"src:%@",self.hexString);
            
            if (op == LBXOperaton_Encrypt) {
                //encrypt
                for (int i = 0; i < len; i++)
                {
                    if (alg == LBXAlgorithm_SM4) {
                        
                        NSData *preNSData = [NSData dataWithBytes:preData length:blockSize];
                        
                        NSData *resultData = [preNSData sm4WithOp:LBXOperaton_Encrypt optionMode:LBXOptionMode_ECB key:key iv:nil];
                        
                        memcpy(bufferPtr, resultData.bytes, blockSize);
                    }else{
                        NSInteger datalen = LBXCryptECB(LBXOperaton_Encrypt, alg,key.bytes, key.length, NULL, preData, blockSize, bufferPtr, bufferPtrSize, error);
                        
                        if (datalen != blockSize) {
                            NSLog(@"    LBXCryptECB faile     ");
                        }
                    }
                    
                    //原文作为加密结果的iv
                    memcpy(blockData, pBytes + i * blockSize, blockSize);
                    
                    //原文与加密结果异或
                    XOR(blockData, bufferPtr, blockSize);
                    
                    //存储结果作为下一个分组的加密数据
                    memcpy(preData, bufferPtr, bufferPtrSize);
                    //存储分组数据
                    [cbcData appendBytes:bufferPtr length:bufferPtrSize];
                }
            }else{
                
                //decrypt
                for (int i = 0; i < len; i++)
                {
//                    NSInteger datalen = LBXCryptECB(LBXOperaton_Encrypt, alg,key.bytes, key.length, NULL, preData, blockSize, bufferPtr, bufferPtrSize, error);
//                    
//                    if (datalen != blockSize) {
//                        
//                        NSLog(@"    LBXCryptECB faile     ");
//                    }
                    if (alg == LBXAlgorithm_SM4) {
                        
                        NSData *preNSData = [NSData dataWithBytes:preData length:blockSize];
                        
                        NSData *resultData = [preNSData sm4WithOp:LBXOperaton_Encrypt optionMode:LBXOptionMode_ECB key:key iv:nil];
                        
                        memcpy(bufferPtr, resultData.bytes, blockSize);
                    }else{
                        NSInteger datalen = LBXCryptECB(LBXOperaton_Encrypt, alg,key.bytes, key.length, NULL, preData, blockSize, bufferPtr, bufferPtrSize, error);
                        
                        if (datalen != blockSize) {
                            NSLog(@"    LBXCryptECB faile     ");
                        }
                    }
                    
                    //原文(这里其实为待解密的密文)作为加密结果的iv
                    memcpy(preData, pBytes + i * blockSize, blockSize);
                    
                    //原文与加密结果异或
                    XOR(preData, bufferPtr, blockSize);
                    
                    //存储分组数据
                    [cbcData appendBytes:bufferPtr length:bufferPtrSize];
                }
            }
            cryptData = cbcData;
        }
            break;
      
            
        default:
            break;
    }
    return cryptData;
}

/**
 crypt OFB opertion
 
 @param op encryt or decrypt
 @param alg encryt algorithm
 @param key key
 @param iv init vector
 @param error return err info
 @return  result,fail if return nil
 */
- (NSData*)LBXCryptOFBWithOp:(LBXOperaton)op
                   algorithm:(LBXAlgorithm)alg
                         key:(NSData*)key
                          iv:(NSData*)iv
                       error:(NSError**)error
{
    NSData *cryptData = nil;
    switch (alg) {
        case LBXAlgorithm_DES:
        case LBXAlgorithm_3DES:
        case LBXAlgorithm_AES128:
//        case LBXAlgorithm_RC2:
//        case LBXAlgorithm_RC4:
        case LBXAlgorithm_CAST:
        case LBXAlgorithm_Blowfish:
        case LBXAlgorithm_SM4:
        {
            //利用ECB算法加密每个分组，然后根据OFB算法组装分组数据
            uint8_t tmp[512];
            void *bufferPtr = tmp;
            uint32_t blockSize = [self LBXBlockSize:alg];
            uint32_t bufferPtrSize = blockSize;
            
            uint8_t blockData[512];
            
            
            uint8_t preData[512]={0x00};
            if (iv) {
                memcpy(preData, iv.bytes, blockSize);
            }else{
                memset(preData, 0x00, blockSize);
            }
            
            //CBC
            NSMutableData *cbcData = [[NSMutableData alloc]initWithCapacity:bufferPtrSize];
            NSInteger len = self.length / blockSize;
            
            unsigned char* pBytes = (unsigned char*)self.bytes;
            
            
            //encrypt
            for (int i = 0; i < len; i++)
            {
                if (alg == LBXAlgorithm_SM4) {
                    
                    NSData *preNSData = [NSData dataWithBytes:preData length:blockSize];
                    
                    NSData *resultData = [preNSData sm4WithOp:LBXOperaton_Encrypt optionMode:LBXOptionMode_ECB key:key iv:nil];
                    
                    memcpy(bufferPtr, resultData.bytes, blockSize);
                }else{
                    NSInteger datalen = LBXCryptECB(LBXOperaton_Encrypt, alg,key.bytes, key.length, NULL, preData, blockSize, bufferPtr, bufferPtrSize, error);
                    
                    if (datalen != blockSize) {
                        NSLog(@"    LBXCryptECB faile     ");
                    }
                }
                
                //原文作为加密结果的iv
                memcpy(blockData, pBytes + i * blockSize, blockSize);
                
                //存储加密结果作为下一个分组的待加密数据
                memcpy(preData, bufferPtr, bufferPtrSize);
                
                //原文与加密结果异或
                XOR(blockData, bufferPtr, blockSize);
                
                
                //存储分组数据
                [cbcData appendBytes:bufferPtr length:bufferPtrSize];
            }
            
            cryptData = cbcData;
            
        }
            break;
      
            
        default:
            break;
    }
    return cryptData;
}


/**
 crypt CTR opertion
 
 @param op encryt or decrypt
 @param alg encryt algorithm
 @param key key
 @param iv init vector
 @param error return err info
 @return  result,fail if return nil
 */
- (NSData*)LBXCryptCTRWithOp:(LBXOperaton)op
                   algorithm:(LBXAlgorithm)alg
                         key:(NSData*)key
                          iv:(NSData*)iv
                       error:(NSError**)error
{
    NSData *cryptData = nil;
    switch (alg) {
        case LBXAlgorithm_DES:
        case LBXAlgorithm_3DES:
        case LBXAlgorithm_AES128:
            //        case LBXAlgorithm_RC2:
            //        case LBXAlgorithm_RC4:
        case LBXAlgorithm_CAST:
        case LBXAlgorithm_Blowfish:
        case LBXAlgorithm_SM4:
        {
            //利用ECB算法加密每个分组，然后根据OFB算法组装分组数据
            uint8_t tmp[512];
            void *bufferPtr = tmp;
            uint32_t blockSize = [self LBXBlockSize:alg];
            uint32_t bufferPtrSize = blockSize;
            
            uint8_t blockData[512];
            
            
            uint8_t preData[512]={0x00};
            if (iv) {
                memcpy(preData, iv.bytes, blockSize);
            }else{
                memset(preData, 0x00, blockSize);
            }
            
            //CBC
            NSMutableData *cbcData = [[NSMutableData alloc]initWithCapacity:bufferPtrSize];
            NSInteger len = self.length / blockSize;
            
            unsigned char* pBytes = (unsigned char*)self.bytes;
            
         
            NSArray<NSData*> *arrayBounce = nil;
#ifdef LBXBigNum_File_Exist

         arrayBounce   = [LBXBigNum nonceWithIv:[NSData dataWithBytes:preData length:blockSize] nums:self.length / blockSize];
#endif
            
            
            
            //encrypt
            for (int i = 0; i < len; i++)
            {
                if (alg == LBXAlgorithm_SM4) {
                    
                    NSData *preNSData = arrayBounce[i];
                    
                    NSData *resultData = [preNSData sm4WithOp:LBXOperaton_Encrypt optionMode:LBXOptionMode_ECB key:key iv:nil];
                    
                    memcpy(bufferPtr, resultData.bytes, blockSize);
                }else{
                    
                    memcpy(preData, arrayBounce[i].bytes, blockSize);
                    NSInteger datalen = LBXCryptECB(LBXOperaton_Encrypt, alg,key.bytes, key.length, NULL, preData, blockSize, bufferPtr, bufferPtrSize, error);
                    
                    if (datalen != blockSize) {
                        NSLog(@"    LBXCryptECB faile     ");
                    }
                }
                //原文作为加密结果的iv
                memcpy(blockData, pBytes + i * blockSize, blockSize);
                
                //原文与加密结果异或
                XOR(blockData, bufferPtr, blockSize);
                
                //存储分组数据
                [cbcData appendBytes:bufferPtr length:bufferPtrSize];
            }
            
            cryptData = cbcData;
            
        }
            break;
            
            
        default:
            break;
    }
    return cryptData;
}




/**
 get block size with algorithm

 @param algorithm algorithm
 @return block size
 */
- (uint8_t)LBXBlockSize:(LBXAlgorithm)algorithm
{
    uint8_t blockSize = 0;
    switch (algorithm) {
        case LBXAlgorithm_AES128:
            blockSize = LBXBlockSize_AES128;
            break;
        case LBXAlgorithm_DES:
            blockSize = LBXBlockSize_DES;
            break;
        case LBXAlgorithm_3DES:
            blockSize = LBXBlockSize_3DES;
            break;
        case LBXAlgorithm_SM4:
            blockSize = LBXBlockSize_SM4;
            break;
            
        case LBXAlgorithm_CAST:
            blockSize = LBXBlockSize_CAST;
            break;
        case LBXAlgorithm_RC4:
            blockSize = LBXBlockSize_RC2;
            break;
        case LBXAlgorithm_RC2:
            blockSize = LBXBlockSize_RC2;
            break;
        case LBXAlgorithm_Blowfish:
            blockSize = LBXBlockSize_Blowfish;
            break;
        
        default:
            break;
    }
    
    return blockSize;
}


/**
 check and set key and iv  with algorithm

 @param algorithm algorithm
 @param keyData key
 @param ivData iv
 @return success if return YES, fail if return NO
 */
- (BOOL) LBXFixKeyLength:(LBXAlgorithm) algorithm key:(NSMutableData*) keyData iv:(NSMutableData *) ivData
{
    BOOL isSuccess = YES;
    
    NSUInteger keyLength = [keyData length];
    switch ( algorithm )
    {
        case LBXAlgorithm_AES128:
        {
            if (keyLength != LBXKeySize_AES128 && keyLength != LBXKeySize_AES256_24 && keyLength != LBXKeySize_AES256_32) {
                isSuccess = NO;
            }
        }
            break;
        case LBXAlgorithm_SM4:
        {
            if (keyLength != LBXKeySize_SM4) {
                isSuccess = NO;
            }
        }
            break;
       
        case LBXAlgorithm_3DES:
        {
            switch (keyLength) {
                case LBXKeySize_3DES_EDE2:
                {
                    NSData *Key3 = [NSData dataWithBytes:keyData.bytes + LBXKeySize_DES length:LBXKeySize_DES];
                    [keyData appendData:Key3];
                    keyLength = keyData.length;
                }
                    break;
                case LBXKeySize_3DES_EDE3:
                    break;
                    
                default:
                    isSuccess = NO;
                    break;
            }
        }
            break;
        case LBXAlgorithm_DES:
        {
            if (keyLength != LBXKeySize_DES) {
                isSuccess = NO;
            }
        }
            break;
        case LBXAlgorithm_CAST:
        {
            if (keyLength != LBXKeySize_CAST_5 && keyLength != LBXKeySize_CAST_16 ) {
                isSuccess = NO;
            }
        }
            break;
        case LBXAlgorithm_RC4:
        {
            if (keyLength != LBXKeySize_RC4) {
                isSuccess = NO;
            }
        }
            break;
        case LBXAlgorithm_RC2:
        {
            if (keyLength != LBXKeySize_RC2) {
                isSuccess = NO;
            }
        }
            break;
        case LBXAlgorithm_Blowfish:
            if (keyLength != LBXKeySize_Blowfish) {
                isSuccess = NO;
            }
            break;
       
        default:
            isSuccess = NO;
            break;
    }
    
    if (isSuccess && ivData) {
//        if (ivData.length != keyLength) {
//            isSuccess = NO;
//        }
        [ivData setLength:keyLength];
    }
    
    return isSuccess;
}


- (NSString*)logWithStatus:(CCCryptorStatus)ccStatus
{
    NSString *status = @"Success";
    switch (ccStatus) {
        case kCCSuccess:
        {
            NSLog(@"SUCCESS");
        }
            break;
        case kCCParamError:
            NSLog(@"PARAM ERROR");
            status = @"PARAM ERROR";
            break;
        case kCCBufferTooSmall:
            NSLog(@"BUFFER TOO SMALL");
            status = @"BUFFER TOO SMALL";
            break;
        case kCCMemoryFailure:
            NSLog(@"MEMORY FAILURE");
            status = @"MEMORY FAILURE";
            break;
        case kCCAlignmentError:
            //填充报错
            NSLog(@"ALIGNMENT ERROR");
            status = @"ALIGNMENT ERROR";
            break;
        case kCCDecodeError:
            NSLog(@"DECODE ERROR");
            status = @"DECODE ERROR";
            break;
        case kCCUnimplemented:
            NSLog(@"UNIMPLEMENTED");
            status = @"UNIMPLEMENTED";
            break;
        default:
            status = @"unknown";
            break;
    }
    return status;
}



@end






