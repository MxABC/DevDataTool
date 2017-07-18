//
//  NSData+SHA3.m
//  DataHandler
//
//  Created by lbxia on 2017/5/9.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import "NSData+SHA3.h"
#import "keccak.h"

@implementation NSData (SHA3)


- (NSData*) sha3:(NSUInteger)bitsLength
{
    int bytes = (int)(bitsLength/8);
    const char * string = (const char*)self.bytes;
    int size=(int)strlen(string);
    uint8_t md[bytes];
    keccak((uint8_t*)string, size, md, bytes);
    
    return [NSData dataWithBytes:md length:bytes];
}


@end
