//
//  NSData+LBXPadding.m
//  DataHandler
//
//  Created by lbxia on 2017/5/10.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "NSData+LBXPadding.h"
#import "NSData+LBXConverter.h"

@implementation NSData (LBXPadding)


/**
 padding function,根据填充模式，补位数据
 @param padding padding type
 @param blockSize block size
 @return padded data
 */
- (NSData*)LBXPaddingWithMode:(LBXPaddingMode)padding blockSize:(uint8_t)blockSize
{
    //补位存储数据
    uint8_t cPaddingData[512]={0};
    //获取需要补位长度 bytes
    uint8_t paddingLen =  blockSize - self.length % blockSize;
    
    //fill padding
    NSData *paddedData = nil;
    switch (padding) {
        case LBXPaddingMode_NONE:
            paddedData = self;
            break;
        case LBXPaddingMode_PKCS5:
        case LBXPaddingMode_PKCS7:
        {
            //PKCS5:只支持分组长度为8bytes的, PKCS7:支持分组长度1-128bytes,这里当作同一个算法处理了
            
            memset(cPaddingData, paddingLen, paddingLen);
            NSMutableData *data = [[NSMutableData alloc]initWithCapacity:self.length + paddingLen];
            [data appendData:self];
            [data appendBytes:cPaddingData length:paddingLen];
            paddedData = data;
            
            NSLog(@"paddedData hex:%@",paddedData.hexString);
        }
            break;
        
        case LBXPaddingMode_Zero:
        {
            memset(cPaddingData, 0x00, paddingLen);
            NSMutableData *data = [[NSMutableData alloc]initWithCapacity:self.length + paddingLen];
            [data appendData:self];
            [data appendBytes:cPaddingData length:paddingLen];
            paddedData = data;
        }
            break;
        case LBXPaddingMode_0x80:
        {
            NSInteger diffBits = (self.length + 1) % blockSize;
            if (diffBits == 0) {
                //仅仅添加0x80一个字节即可
                paddingLen = 1;
                memset(cPaddingData, 0x80, paddingLen);
                NSMutableData *data = [[NSMutableData alloc]initWithCapacity:self.length + paddingLen];
                [data appendData:self];
                [data appendBytes:cPaddingData length:paddingLen];
                paddedData = data;
                
            }else{
                paddingLen = blockSize - diffBits;
                
                memset(cPaddingData, 0x80, 1);
                memset(cPaddingData+1, 0x00, paddingLen);
                NSMutableData *data = [[NSMutableData alloc]initWithCapacity:self.length + paddingLen + 1];
                [data appendData:self];
                [data appendBytes:cPaddingData length:paddingLen+1];
                paddedData = data;
            }
            
        }
            break;
        case LBXPaddingMode_ANSIX923:
        {
            //最后一位表示补位的长度，其他位置0x00
            memset(cPaddingData, 0x00, paddingLen);
            cPaddingData[paddingLen-1] = paddingLen;
            NSMutableData *data = [[NSMutableData alloc]initWithCapacity:self.length + paddingLen];
            [data appendData:self];
            [data appendBytes:cPaddingData length:paddingLen];
            paddedData = data;
        }
            break;
        case LBXPaddingMode_ISO10126:
        {
            //最后一位表示填充的长度，其他字节随机
            for (int i = 0; i < paddingLen-1; i++) {
                cPaddingData[i] = arc4random() % 256;
            }
            cPaddingData[paddingLen-1] = paddingLen;
            NSMutableData *data = [[NSMutableData alloc]initWithCapacity:self.length + paddingLen];
            [data appendData:self];
            [data appendBytes:cPaddingData length:paddingLen];
            paddedData = data;
        }
            break;
            
        default:
            break;
    }
    
    return paddedData;
}


/**
 padding function,根据填充模式，除去填充的数据
 @param padding padding type
 @return padded data
 */
- (NSData*)LBXUnPaddingWithMode:(LBXPaddingMode)padding
{
   //unPad data
    NSData *unPaddedData = nil;
    
    //补位长度 bytes
    uint16_t paddingLen =  0;
    
    //解密后的数据
    uint8_t *bytes = (uint8_t*)self.bytes;

    
    
    switch (padding) {
        case LBXPaddingMode_NONE:
            unPaddedData = self;
            break;
        case LBXPaddingMode_PKCS5:
        case LBXPaddingMode_PKCS7:
        case LBXPaddingMode_ANSIX923:
        case LBXPaddingMode_ISO10126:
        {
            //都是最后一个字节表示补位的长度
            NSInteger datalen = self.length;
            NSLog(@"datalen:%ld",datalen);
            paddingLen = bytes[datalen-1];
            
//            NSLog(@"%@",self.hexString);
            
            if (paddingLen >= self.length ) {
                
                return nil;
            }
            unPaddedData = [NSData dataWithBytes:self.bytes length:self.length - paddingLen];
        }
            break;
        case LBXPaddingMode_Zero:
        {
            uint8_t *pBytes = bytes+self.length-1;
            paddingLen = 0;
            do {
                if ( *pBytes != 0x00 )
                    break;
            
                pBytes -= 1;
                paddingLen += 1;
            } while (paddingLen < self.length);
            
            unPaddedData = [NSData dataWithBytes:self.bytes length:self.length - paddingLen];
        }
            break;
        case LBXPaddingMode_0x80:
        {
            uint8_t *pBytes = bytes+self.length-1;
            paddingLen = 0;
            do {
                if ( *pBytes == 0x80 )
                    break;
            
                pBytes -= 1;
                paddingLen += 1;
            } while (paddingLen < self.length);
            paddingLen += 1;
            
            unPaddedData = [NSData dataWithBytes:self.bytes length:self.length - paddingLen];
        }
            break;
        default:
            break;
    }
    
    return unPaddedData;
}


@end
