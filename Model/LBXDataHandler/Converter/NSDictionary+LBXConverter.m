//
//  NSDictionary+LBXConverter.m
//  DataHandler
//
//  Created by lbxia on 2021/1/18.
//  Copyright © 2021 LBX. All rights reserved.
//

#import "NSDictionary+LBXConverter.h"

@implementation NSDictionary (LBXConverter)

- (NSData*)data
{
    return  [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
}

- (NSData*)formatData
{
    //NSJSONWritingPrettyPrinted 输出增加了换行，方便阅读，但是增加了内存，网络传输不不要使用当前方法
    return  [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSString*)string
{
    return [[NSString alloc]initWithData:self.data encoding:NSUTF8StringEncoding];
}


- (NSString*)formatString
{
    //方便阅读
    return [[NSString alloc]initWithData:self.formatData encoding:NSUTF8StringEncoding];
}

@end
