//
//  NSData+LBXBase64.h
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (LBXBase64)


/**
 base64 encode

 @param options options,不需要换行，传值0即可，实际应用中，大部分都是传值0
 @return base64Code
 */
- (NSString*)encodeBase64WithOptions:(NSDataBase64EncodingOptions)options;

@end
