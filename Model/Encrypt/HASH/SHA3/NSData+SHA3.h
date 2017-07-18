//
//  NSData+SHA3.h
//  DataHandler
//
//  Created by lbxia on 2017/5/9.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SHA3)



/**
 sha3

 @param bitsLength digest len, 256、384、512
 @return digest data
 */
- (NSData*) sha3:(NSUInteger)bitsLength;



@end
