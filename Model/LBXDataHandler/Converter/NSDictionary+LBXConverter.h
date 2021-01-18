//
//  NSDictionary+LBXConverter.h
//  DataHandler
//
//  Created by lbxia on 2021/1/18.
//  Copyright © 2021 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (LBXConverter)
- (NSData*)data;
- (NSString*)string;

//如果仅仅是输出日志显示，可以使用下面2个方法，更方便阅读
- (NSData*)formatData;
- (NSString*)formatString;
@end


