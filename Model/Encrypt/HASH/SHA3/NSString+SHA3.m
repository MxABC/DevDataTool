//
//  NSString+SHA3.h
//
//  Created by Jaeggerr on 14/04/2014.
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/jaeggerr/NSString-SHA3
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "NSString+SHA3.h"
#import "keccak.h"

@implementation NSString (SHA3)

-(NSString*) sha3:(NSUInteger)bitsLength
{
    int bytes = (int)(bitsLength/8);
    const char * string = [self cStringUsingEncoding:NSUTF8StringEncoding];
    int size=(int)strlen(string);
    uint8_t md[bytes];
    keccak((uint8_t*)string, size, md, bytes);
    NSMutableString *sha3 = [[NSMutableString alloc] initWithCapacity:bitsLength/4];
    
    for(int32_t i=0;i<bytes;i++)
        [sha3 appendFormat:@"%02X", md[i]];
    return sha3;
}


@end
