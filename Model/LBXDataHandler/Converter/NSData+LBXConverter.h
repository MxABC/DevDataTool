//
//  NSData+LBXConverter.h
//  DataHandler
//
//  Created by lbxia on 16/9/2.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (LBXConverter)

//转换成NSString,utf8编码
- (NSString*)utf8String;

//转换成NSString,gbk编码
- (NSString*)gbkString;

//转成成NSString,ASCII编码
- (NSString*)asciiString;

/**
 * 转换成十六进制字符串
 */
- (NSString*)hexString;

/**
 *  转换成NSDictionary
 */
- (NSDictionary*)dictionary;

@end
