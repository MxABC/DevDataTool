//
//  NSData+LBXSM4.h
//  DataHandler
//
//  Created by lbxia on 2017/5/11.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBXCrypt.h"



@interface NSData (LBXSM4)


- (NSData*)sm4WithOp:(LBXOperaton)op
          optionMode:(LBXOptionMode)om
                 key:(NSData*)keyData
                  iv:(NSData*)ivData;

@end
