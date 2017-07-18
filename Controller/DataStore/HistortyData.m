//
//  HistortyData.m
//  DataHandler
//
//  Created by lbxia on 2017/5/25.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import "HistortyData.h"

@implementation HistortyData


+ (instancetype)sharedManager
{
    static HistortyData* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HistortyData alloc] init];
        
    });
    
    return _sharedInstance;
}

@end
