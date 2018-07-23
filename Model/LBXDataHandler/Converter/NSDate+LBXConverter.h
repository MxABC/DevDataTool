//
//  NSDate+LBXConverter.h
//  DataHandler
//
//  Created by lbxia on 2018/7/23.
//  Copyright © 2018年 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (LBXConverter)



/**
 字符串格式日期为: yyyy-MM-dd HH:mm:ss

 @return 日期字符串
 */
- (NSString*)string;


/**
 指定格式日期

 @param formate 日期格式
 @return 日期字符串
 */
- (NSString*)stringWithFormate:(NSString*)formate;



/**
 获取当前时间戳，以毫秒为单位

 @return 时间戳
 */
+ (long long)currentTimeStamp;

@end
