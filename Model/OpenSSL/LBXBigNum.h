//
//  LBXBigNum.h
//  DataHandler
//
//  Created by lbxia on 2017/5/15.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LBXBigNum_File_Exist

@interface LBXBigNum : NSObject


+ (NSArray<NSData*>*)nonceWithIv:(NSData*)ivData nums:(NSInteger)nums;

@end
