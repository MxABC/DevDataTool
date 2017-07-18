//
//  NSData+LBXPadding.h
//  DataHandler
//
//  Created by lbxia on 2017/5/10.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBXCrypt.h"


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
