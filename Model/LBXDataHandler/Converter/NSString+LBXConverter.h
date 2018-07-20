//
//  NSString+LBXConverter.h
//  
//
//  Created by lbxia on 16/9/2.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NSString (LBXConverter)

#pragma mark-
#pragma mark- 字符串加空格
#pragma mark-



/**
 每2个字符之间加一个空格

 @return disperseString
 */
- (NSString*)disperseString;


#pragma mark-
#pragma mark- 编码转换
#pragma mark-


/**     -----  注意  ----
 NSString提供了是否可以转换编码的方法：
 
 - (BOOL)canBeConvertedToEncoding:(NSStringEncoding)encoding;
 */


/**
 *  当前编码为NSShiftJISStringEncoding，转换为NSUTF8StringEncoding
 *  有时候二维码编码为NSShiftJISStringEncoding编码的,客户端一般需要使用UTF-8显示
 *  @return 返回UTF8编码，nil则表示转换失败
 */
- (NSString*)shiftJIStringToUtf8;

/**
 *  当前编码为NSShiftJISStringEncoding，转换为kCFStringEncodingGB_18030_2000
 *
 *  @return 返回GBK编码，nil则表示转换失败
 */
- (NSString*)shiftJIStringToGBK;



/**
 当前编码为UTF-8编码，转换为GBK编码

 @return 返回GBK编码，nil则表示转换失败
 */
- (NSString*)utf8ToGBK;


/**
 当前编码为GBK编码，转换为UTF-8编码
 
 @return 返回UTF-8编码，nil则表示转换失败
 */
- (NSString*)gbkToUtf8;

/**
 当前编码为unicode编码，转换为UTF-8编码
 
 eg:
 
 unicode string:
 
 @"\\U8be5\\U624b\\U673a\\U53f7\\U7684\\U7528\\U6237\\U5df2\\U88ab\\U7ed1\\U5b9a\\U4e3a\\U624b\\U673a\\U94f6\\U884c\\U7528\\U6237";

 
 @return 返回UTF-8编码，nil则表示转换失败
 */
- (NSString*)unicodeToUtf8;

/**
 *  当前编码为NSISOLatin1StringEncoding(ISO8859-1编码)，转换为NSUTF8StringEncoding
 *
 *  @return 返回utf8编码，nil则表示转换失败
 */
- (NSString*)latin1ToUtf8;


/**
 *  当前编码为NSUTF8StringEncoding ，转换为NSISOLatin1StringEncoding(ISO8859-1编码)
 *
 *  @return 返回latin1编码，nil则表示转换失败
 */
- (NSString*)utf8ToLatin1;

/**
 *  当前编码为NSISOLatin1StringEncoding，转换为kCFStringEncodingGB_18030_2000
 *
 *  @return 返回GBK编码，nil则表示转换失败
 */
- (NSString*)latin1ToGBK;


/**
 *  当前编码为GBK，转换为latin1
 *
 *  @return 返回latin1编码，nil则表示转换失败
 */
- (NSString*)GBKToLatin1;


#pragma mark-
#pragma mark- 转换成NSData
#pragma mark-

/**
 *  16进制表示的字符串转换成实际字节流
 */
- (NSData*)hexString2Data;


/**
 判断是否符合hexString的范围
 
 @return yes if conform to
 */
- (BOOL)isHexString;

/**
 *  UTF-8编码NSData，转换前String可以为任意编码格式
 */


/**
 转换成NSData，转换前String可以为任意编码格式
 如果String非UTF-8,不能成功转换成UTF-8则返回nil
 @return NSData
 */
- (NSData*)utf8Data;


/**
 *  GBK编码NSData,转换前String可能为任意编码格式
 */

/**
 转换成NSData，转换前String可以为任意编码格式
 如果String非GBK编码,不能成功转换成GBK则返回nil
 @return NSData
 */
- (NSData*)gbkData;


#pragma mark-
#pragma mark- 转字典
#pragma mark-
/**
 *  json字符串(UTF-8编码)转NSDictionary
 *
 *  @return 返回NSDictionary
 */
- (NSDictionary*)dictionary;


#pragma mark-
#pragma mark- 日期转换
#pragma mark-

/**
 *  字符串格式日期为: yyyy-MM-dd HH:mm:ss
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


#pragma mark-
#pragma mark- URL特殊字符处理
#pragma mark-

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
- (NSString *)decodeURLString;

//系统方法
- (NSString *)decodeURLString2;


#pragma mark-
#pragma mark- 截取
#pragma mark-
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
