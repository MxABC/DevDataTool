//
//  CryptViewController.h
//  DataHandler
//
//  Created by lbxia on 2017/5/10.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSData+LBXCrypt.h"

@interface CryptViewController : NSViewController
- (void)setWithAlgorithm:(LBXAlgorithm)alg;
@end
