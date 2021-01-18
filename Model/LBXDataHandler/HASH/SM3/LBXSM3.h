//
//  LBXSM3.h
//  DataHandler
//
//  Created by lbxia on 2021/1/18.
//  Copyright © 2021 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface LBXSM3 : NSObject


+ (NSData*)sm3WithData:(NSData*)data;

+ (NSData*)HMACSM3WithKey:(NSData*)key data:(NSData*)data;

+ (NSData*)sm3WithFilePath:(NSString*)filePath;

@end


