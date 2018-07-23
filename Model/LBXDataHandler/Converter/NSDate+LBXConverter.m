//
//  NSDate+LBXConverter.m
//  DataHandler
//
//  Created by lbxia on 2018/7/23.
//  Copyright © 2018年 LBX. All rights reserved.
//

#import "NSDate+LBXConverter.h"

@implementation NSDate (LBXConverter)


/**
 字符串格式日期为: yyyy-MM-dd HH:mm:ss
 
 @return 日期字符串
 */
- (NSString*)string
{
    return [self stringWithFormate:@"yyyy-MM-dd HH:mm:ss"];
}


/**
 指定格式日期
 
 @param formate 日期格式
 @return 日期字符串
 */
- (NSString*)stringWithFormate:(NSString*)formate
{
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:formate];
    //NSDate转NSString
    return  [dateFormatter stringFromDate:self];
}


// 以毫秒为单位
+ (long long)currentTimeStamp
{
    NSTimeInterval localTime = [[NSDate date] timeIntervalSince1970];
    return (long long)(localTime * 1000);
}

@end
