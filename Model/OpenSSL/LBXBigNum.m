//
//  LBXBigNum.m
//  DataHandler
//
//  Created by lbxia on 2017/5/15.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "LBXBigNum.h"
#import <openssl/bn.h>

@implementation LBXBigNum


//- (NSArray<NSData*>*)counterWithBounce

- (void)testBigNum
{
    char *cbigNum = "1234567890123456";
    
    
    BIGNUM *bignum = NULL;
    
    int ret = BN_dec2bn(&bignum, cbigNum);
    //返回转换的长度,这里为16
    printf("ret=%d",ret);
    
    BN_add_word(bignum, 1);
    
    char *pBigNum = BN_bn2dec(bignum);
    
    printf("%s",pBigNum);
    
    
    OPENSSL_free(pBigNum);
    
    BN_free(bignum);
    
    
    
    //    ASN1_INTEGER *serialNumber = _cert_X509->cert_info->serialNumber;
    //
    //    BIGNUM *bignum = ASN1_INTEGER_to_BN(serialNumber, NULL);
    //
    //    char *pDec =  BN_bn2dec(bignum);//转化为10进制字符串
    //
    //    //    BN_dec2bn(<#BIGNUM **a#>, <#const char *str#>)
    //
    //    NSString *strDec = [NSString stringWithUTF8String:pDec];
    //
    //    OPENSSL_free(pDec);
    //    
    //    BN_free(bignum);
    
    
}

+ (NSArray<NSData*>*)nonceWithIv:(NSData*)ivData nums:(NSInteger)nums
{
    char iv[512]={0};
    memcpy(iv, ivData.bytes, ivData.length);
    
    NSMutableArray<NSData*>* arrayData = [[NSMutableArray alloc]initWithCapacity:nums];
    
    for (int i = 0; i < nums; i++) {
        
        BIGNUM *bignum = NULL;
        
        int ret = BN_dec2bn(&bignum, iv);
        //返回转换的长度,一般为iv实际数据长度
        printf("ret=%d",ret);
        
        BN_add_word(bignum, i);
        
        char *pBigNum = BN_bn2dec(bignum);
        
        printf("%s",pBigNum);
        
        NSData *nonceData = [NSData dataWithBytes:pBigNum length:ret];
        
        [arrayData addObject:nonceData];
        
        OPENSSL_free(pBigNum);
        
        BN_free(bignum);
    }
    
    return arrayData;
}


@end
