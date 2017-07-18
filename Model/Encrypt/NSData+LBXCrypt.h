//
//  NSData+LBXDES.h
//  EncryptionDeciphering
//
//  Created by lbxia on 2016/10/28.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+LBXPadding.h"

#import "LBXCrypt.h"



extern NSString * const LBXCryptErrorDomain;




@interface NSData (LBXCrypt)

/**
 encrypt interface

 @param op encryt or decrypt
 @param alg encryt algorithm
 @param om ECB、CBC、CFB、OFB
 @param padding padding type
 @param key key
 @param iv init vector
 @param error return err info
 @return  result,fail if return nil
 */
- (NSData*)LBXCryptWithOp:(LBXOperaton)op
                algorithm:(LBXAlgorithm)alg
               optionMode:(LBXOptionMode)om
                  padding:(LBXPaddingMode)padding
                      key:(id)key
                       iv:(id)iv
                    error:(NSError**)error;



@end








