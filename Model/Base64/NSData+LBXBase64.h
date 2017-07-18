//
//  NSData+LBXBase64.h
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (LBXBase64)


/**
 base64 encode

 @param options options
 @return base64Code
 */
- (NSString*)encodeBase64WithOptions:(NSDataBase64EncodingOptions)options;


/**
  base64 decode

 @param options options
 @return deBase64Code
 */
- (NSString*)decodeBase64WithOptions:(NSDataBase64DecodingOptions)options;

@end
