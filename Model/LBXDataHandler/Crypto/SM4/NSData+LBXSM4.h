//
//  NSData+LBXSM4.h
//  DataHandler
//
//  Created by lbxia on 2017/5/11.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBXCryptDefines.h"


@interface NSData (LBXSM4)


/**
 sm4加解密

 @param op 加密or解密
 @param om 加密模式，本接口目前仅支持ECB、CBC模式，其他模式可通过ECB模式组合完成
 @param keyData key
 @param ivData iv
 @return result
 */
- (NSData*)sm4WithOp:(LBXOperaton)op
          optionMode:(LBXOptionMode)om
                 key:(NSData*)keyData
                  iv:(NSData*)ivData;

@end
