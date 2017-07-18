//
//  NSString+LBXConverter.h
//  
//
//  Created by lbxia on 16/9/2.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (LBXConverter)


#pragma mark --16进制字符串转换



- (NSString*)hexString;

- (NSString*)disperseHexString;



#pragma mark --编码转换

/**
 *  假设当前编码为NSShiftJISStringEncoding，转换为NSUTF8StringEncoding
 *
 *  @return 返回UTF8编码，nil则表示转换失败
 */
- (NSString*)shiftJIStringToUtf8;

/**
 *  假设当前编码为NSShiftJISStringEncoding，转换为kCFStringEncodingGB_18030_2000
 *
 *  @return 返回GBK编码，nil则表示转换失败
 */
- (NSString*)shiftJIStringToGBK;



- (NSString*)utf8ToGBK;

- (NSString*)gbkToUtf8;

- (NSString*)unicodeToUtf8;

/**
 *  假设当前编码为NSISOLatin1StringEncoding(ISO8859-1编码)，转换为NSUTF8StringEncoding
 *
 *  @return 返回utf8编码，nil则表示转换失败
 */
- (NSString*)latin1ToUtf8;


/**
 *  假设当前编码为NSUTF8StringEncoding ，转换为NSISOLatin1StringEncoding(ISO8859-1编码)
 *
 *  @return 返回utf8编码，nil则表示转换失败
 */
- (NSString*)utf8ToLatin1;

/**
 *  假设当前编码为NSISOLatin1StringEncoding，转换为kCFStringEncodingGB_18030_2000
 *
 *  @return 返回GBK编码，nil则表示转换失败
 */
- (NSString*)latin1ToGBK;

- (NSString*)GBKToLatin1;


#pragma mark ---转字典
/**
 *  json字符串转NSDictionary
 *
 *  @return 返回NSDictionary
 */
- (NSDictionary*)json;


#pragma mark ---日期转换

/**
 *  默认格式日期,如 @"2015-06-26 08:08:08"
 *
 *  @return NSDate
 */
- (NSDate *)date;

/**
 *  按指定格式转换日期NSDate
 *
 *  @param format 格式，按时间的原来格式输入，否则会报错,如：@"2015-06-26 08:08:08"
 *
 *  @return NSDate
 */
- (NSDate *)dateWithFormat:(NSString*)format;


#pragma mark --URL特殊字符处理

/**
 *  URL字符串特殊处理
 *
 *  @return 处理过的字符串
 */
- (NSString*)encodeURLString;

//系统方法
- (NSString*)encodeURLString2;

/**
 *  URL字符串处理过的反处理
 *
 *  @return 解析后的字符串
 */
-(NSString *)decodeURLString;

//系统方法
-(NSString *)decodeURLString2;


#pragma mark --转换成NSData
/**
 *  16进制表示的字符串转换成实际值
 */
- (NSData*)hexString2Data;


/**
 判断是否符合hexString的范围

 @return yes if conform to
 */
- (BOOL)isHexString;

/**
 *  UTF-8编码
 */
- (NSData*)utf8Data;

/**
 *  GBK编码
 */
- (NSData*)gbkData;


#pragma mark --截取
/**
 *  截取2个子字符串之间的字符串
 *
 *  @param beginSubString 开始字符串
 *  @param endSubString   结束字符串
 *
 *  @return 返回截取的字符串，如果为nil,表示截取失败
 */
- (NSString*)trimBetween:(NSString*)beginSubString and:(NSString*)endSubString;


@end
