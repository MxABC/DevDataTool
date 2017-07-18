//
//  NSString+LBXBase64.h
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LBXBase64)



/**
 encodebase64

 @param options options,NO line endings if options set 0
 @return return encodebase64 string, fail if return nil
 */
- (NSString*)encodeBase64WithOptions:(NSDataBase64EncodingOptions)options;


/**
 decodebase64

 @param options IgnoreUnknownCharacters,if set options 0,will not ignore unkonwn characters
 @return return decodeBase64 string,fail if return nil
 */
- (NSString*)decodeBase64WithOptions:(NSDataBase64DecodingOptions)options;

//- (NSData*)dataFromDecodeBase64WithOptions:(NSDataBase64DecodingOptions)options;

- (NSData*)decodeBase64StringWithOptions:(NSDataBase64DecodingOptions)options;

@end
