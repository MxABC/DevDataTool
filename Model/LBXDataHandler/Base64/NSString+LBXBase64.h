//
//  NSString+LBXBase64.h
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LBXBase64)

/**
 decodeBase64

 @param options options,NO line endings if options set 0
 @return return encodebase64 string, fail if return nil
 */
- (NSData*)decodeBase64StringWithOptions:(NSDataBase64DecodingOptions)options;

@end
