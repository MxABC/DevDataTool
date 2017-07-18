//
//  NSUserDefaults+LBXExtensions
//
//
//  Created by lbxia on 16/9/5.
//  Copyright © 2016年 LBX. All rights reserved.
//

#import "NSUserDefaults+LBXExtensions.h"

@implementation NSUserDefaults (LBXExtensions)


////////////////////////   NSUserDefaults  程序内存取共用信息   /////////////////////////////////
+ (void)save:(id)strMsg forKey:(NSString *)strKey
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    //清空
    [ud removeObjectForKey:strKey];
    
    [ud setObject:strMsg forKey:strKey];
    
    [ud synchronize];
}

+ (void)remove:(NSString*)strKey
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    //清空
    [ud removeObjectForKey:strKey];
    [ud synchronize];
}

+ (id)get:(NSString *)strKey
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:strKey];
}

+ (void)saveBOOL:(BOOL)status forKey:(NSString*)strKey
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    //清空
    [ud removeObjectForKey:strKey];
    
    [ud setBool:status forKey:strKey];
    [ud synchronize];
}

+ (BOOL)getBOOLWithKey:(NSString*)strKey
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    return [ud boolForKey:strKey];
}


@end
