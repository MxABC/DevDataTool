//
//  NSString+LBXFileHash.h
//  DataHandler
//
//  Created by lbxia on 16/9/2.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (LBXFileHash)

#pragma mark - 文件散列函数

/**
 *  当前为文件路径，计算文件的MD5,结果16字节
 *
 *  @return 文件MD5
 */
- (NSData *)fileMD5Hash;

/**
 *  当前为文件路径，计算文件的SHA1，结果20字节
 *
 *  @return 文件SHA1
 */
- (NSData *)fileSHA1Hash;


/**
 *  当前为文件路径，计算文件的SHA256，结果32字节
 *
 *  @return 文件SHA256
 */
- (NSData *)fileSHA256Hash;



/**
 *  当前为文件路径，计算文件的SM3，结果32字节
 *
 *  @return 文件SM3
 */
- (NSData*)fileSM3Hash;

@end
