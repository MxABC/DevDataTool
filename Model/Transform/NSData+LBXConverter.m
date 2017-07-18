//
//  NSData+LBXConverter.m
//  EncryptionDeciphering
//
//  Created by lbxia on 16/9/2.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "NSData+LBXConverter.h"

@implementation NSData (LBXConverter)

- (NSString*)utf8String
{
    return [[NSString alloc]initWithData:self encoding:NSUTF8StringEncoding];
}

- (NSString*)gbkString
{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [[NSString alloc] initWithBytes:[self bytes] length:[self length] encoding:gbkEncoding];
}

- (NSString*)asciiString
{
   return [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding];
}





/**
 * 数组转换成十六进制字符串
 */
- (NSString*)hexString
{
    NSMutableString *arrayString = [[NSMutableString alloc]initWithCapacity:self.length * 2];
    int len = (int)self.length;
    unsigned char* bytes = (unsigned char*)self.bytes;
    
    for (int i = 0; i < len; i++)
    {
        unsigned char cValue = bytes[i];
        
//        int iValue = cValue;
//        iValue = iValue & 0x000000FF;
        
        NSString *str = [NSString stringWithFormat:@"%02x",cValue];
        
        [arrayString appendString:str];
    }
    
    return arrayString.uppercaseString;
}

- (NSDictionary*)json
{
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:self
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    
    return jsonObject;    
}




@end
