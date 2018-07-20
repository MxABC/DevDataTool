//
//  NSData+LBXSM3.h
//  DataHandler
//
//  Created by lbxia on 2017/4/18.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (LBXSM3)

- (NSData*)SM3;

- (NSData*)HMACSM3WithKey:(NSData*)key;

@end
