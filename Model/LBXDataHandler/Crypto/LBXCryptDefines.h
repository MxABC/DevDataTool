//
//  LBXCryptDefines.h
//  DataHandler
//
//  Created by lbxia on 2017/5/11.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#ifndef LBXCryptDefines_h
#define LBXCryptDefines_h




//encrypt algorithm
typedef NS_ENUM(uint32_t,LBXAlgorithm)
{
    LBXAlgorithm_AES128 = 0,
    LBXAlgorithm_AES256 = 0,
    LBXAlgorithm_DES,
    LBXAlgorithm_3DES,
    LBXAlgorithm_CAST,
    LBXAlgorithm_RC4,
    LBXAlgorithm_RC2,
    LBXAlgorithm_Blowfish,
    LBXAlgorithm_SM4
};

//algorithm block size bytes,iv size == block size
typedef NS_ENUM(uint16_t,LBXBlockSize)
{
    /*AES*/
    LBXBlockSize_AES128 = 16,
    LBXBlockSize_AES256 = 16,
    
    /*DES*/
    LBXBlockSize_DES = 8,
    
    /*3DES*/
    LBXBlockSize_3DES = 8,
    
    /*SM4*/
    LBXBlockSize_SM4 = 16,
    
    //流式加密，没有固定长度
    /*CAST*/
    LBXBlockSize_CAST = 8,
    LBXBlockSize_RC2 = 8,
    LBXBlockSize_Blowfish = 8,
    LBXBlockSize_RC4 = 1
};
//RC4一个字节一个字节加解密

//encrypt key size bytes
typedef NS_ENUM(uint16_t,LBXKeySize)
{
    /*DES*/
    LBXKeySize_DES = 8,
    
    /*3DES*/
    LBXKeySize_3DES_EDE2 = 16,
    LBXKeySize_3DES_EDE3 = 24,
    
    /*AES*/
    LBXKeySize_AES128 = 16,
    LBXKeySize_AES256_24 = 24,
    LBXKeySize_AES256_32 = 32,
    
    /*SM4*/
    LBXKeySize_SM4 = 16,
    
    /*CAST*/
    LBXKeySize_CAST_5 = 5,
    LBXKeySize_CAST_16 = 16,
    LBXKeySize_RC2 = 8,
    LBXKeySize_RC4 = 512,
    LBXKeySize_Blowfish = 8
};


//encrypt operation
typedef NS_ENUM(uint8_t,LBXOperaton)
{
    LBXOperaton_Encrypt = 0,
    LBXOperaton_Decrypt = 1
};

//encrypt padding type
typedef NS_ENUM(NSInteger,LBXPaddingMode)
{
    LBXPaddingMode_NONE,
    LBXPaddingMode_PKCS7,
    LBXPaddingMode_PKCS5,
    LBXPaddingMode_Zero,
    LBXPaddingMode_0x80,
    LBXPaddingMode_ANSIX923,
    LBXPaddingMode_ISO10126
};

//encrypt option mode
typedef NS_ENUM(NSInteger, LBXOptionMode)
{
    LBXOptionMode_ECB,
    LBXOptionMode_CBC,
    LBXOptionMode_PCBC,
    LBXOptionMode_CFB,
    LBXOptionMode_OFB,
    LBXOptionMode_CTR
};



#endif /* LBXCrypt_h */
