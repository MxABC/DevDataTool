//
//  CryptViewController.h
//  DataHandler
//
//  Created by lbxia on 2017/5/10.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSData+LBXCrypt.h"

@interface CryptViewController : NSViewController
- (void)setWithAlgorithm:(LBXAlgorithm)alg;
@end
