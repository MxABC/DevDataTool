//
//  NSData+LBXSM4.m
//  DataHandler
//
//  Created by lbxia on 2017/5/11.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "NSData+LBXSM4.h"
#import "sm4.h"

@implementation NSData (LBXSM4)





- (NSData*)sm4WithOp:(LBXOperaton)op
          optionMode:(LBXOptionMode)om
                 key:(NSData*)keyData
                  iv:(NSData*)ivData
{
    
    //encrypt or decrypt
    int mode = 1 - op;
    
    unsigned char key[16] = {0x00};
    memcpy(key, keyData.bytes, 16);
    
    int length = (int)self.length;
    
    unsigned char output[1024]={0};
    unsigned char input[1024]={0};
    
    unsigned char* cInput = input;
    unsigned char* cOutput = output;
    
    
    if (length > 1024) {
        cInput = (unsigned char*)malloc(length);
        cOutput = (unsigned char*)malloc(length);
    }
    
    //sm4算法内部使用了input，貌似也没有影响?，待测试
    memcpy(cInput, self.bytes, length);
    
    
    NSData *cryptData = nil;
    sm4_2_context ctx;
    if (mode == 1) {
        sm4_2_setkey_enc(&ctx,key);
    }else{
        sm4_2_setkey_dec(&ctx,key);
    }
    
    if (om == LBXOptionMode_ECB) {
        sm4_2_crypt_ecb(&ctx, mode, length, cInput, cOutput);
        cryptData = [NSData dataWithBytes:cOutput length:length];
    }else{
        unsigned char iv[16];
        memcpy(iv, ivData.bytes, 16);
        // CBC
        sm4_2_crypt_cbc(&ctx, mode, length,iv, cInput, cOutput);
        cryptData = [NSData dataWithBytes:cOutput length:length];
    }
    
//    sm4_2_setkey_enc(&ctx,key);
//    sm4_2_crypt_cbc(&ctx,1,(int)encryptLen,iv,input,output);
    
    if (cInput != input) {
        free(cInput);
        free(cOutput);
        cInput = NULL;
        cOutput = NULL;
    }
    
    return cryptData;
}

@end
