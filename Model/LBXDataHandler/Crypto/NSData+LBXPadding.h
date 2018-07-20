//
//  NSData+LBXPadding.h
//  DataHandler
//
//  Created by lbxia on 2017/5/10.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBXCryptDefines.h"



/**
 补位和除补位
 */
@interface NSData (LBXPadding)

/**
 padding function,根据填充模式，补位数据
 @param padding padding type
 @param blockSize block size
 @return padded data
 */
- (NSData*)LBXPaddingWithMode:(LBXPaddingMode)padding blockSize:(uint8_t)blockSize;

/**
 unpadding function,根据填充模式，除去填充的数据
 @param padding padding type
 @return padded data
 */
- (NSData*)LBXUnPaddingWithMode:(LBXPaddingMode)padding;

@end
