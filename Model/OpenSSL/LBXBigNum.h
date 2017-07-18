//
//  LBXBigNum.h
//  DataHandler
//
//  Created by lbxia on 2017/5/15.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LBXBigNum : NSObject


+ (NSArray<NSData*>*)nonceWithIv:(NSData*)ivData nums:(NSInteger)nums;

@end
