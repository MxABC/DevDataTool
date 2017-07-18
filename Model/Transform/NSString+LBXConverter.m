//
//  NSString+LBXConverter.m
//  
//
//  Created by lbxia on 16/9/2.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "NSString+LBXConverter.h"

@implementation NSString (LBXConverter)

- (NSString*)hexString
{
    NSMutableString* hexString = [[NSMutableString alloc]initWithCapacity:self.length * 2];
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    const unsigned char *p = [data bytes];
    
    for (int i=0; i < [data length]; i++) {
        [hexString appendFormat:@"%02x", *p++];
    }
    return hexString.uppercaseString;
}

- (NSString*)disperseHexString
{
    NSMutableString *disperseString = [[NSMutableString alloc]initWithCapacity:self.length + self.length/2];
    for( int i = 0; i < self.length; i = i+2 )
    {
        NSString *s = [self substringWithRange:NSMakeRange(i, 2)];
        [disperseString appendString:s];
        [disperseString appendString:@" "];
    }
    return disperseString;
}


- (NSString*)shiftJIStringToUtf8
{
    const char* tmp = [self cStringUsingEncoding:NSShiftJISStringEncoding];
    if (tmp) {
        
        return  [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (NSString*)shiftJIStringToGBK
{
    const char* tmp = [self cStringUsingEncoding:NSShiftJISStringEncoding];
    if (tmp) {
        
        return  [NSString stringWithCString:tmp encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    }
    return nil;
}

- (NSString*)utf8ToGBK
{
    const char* tmp = [self cStringUsingEncoding:NSUTF8StringEncoding];
    if (tmp) {
        
        return  [NSString stringWithCString:tmp encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    }
    
    return nil;
}

- (NSString*)gbkToUtf8
{
    const char* tmp = [self cStringUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    if (tmp) {
        
        return  [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (void)unicode2Utf8_Test
{
    NSString *desc = @"\\U8be5\\U624b\\U673a\\U53f7\\U7684\\U7528\\U6237\\U5df2\\U88ab\\U7ed1\\U5b9a\\U4e3a\\U624b\\U673a\\U94f6\\U884c\\U7528\\U6237";
    
    //unicode to utf8
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    
    NSLog(@"%@",desc);
    
    //utf8->unicode
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSNonLossyASCIIStringEncoding] encoding:NSUTF8StringEncoding];

}

- (NSString*)unicodeToUtf8
{
    const char* tmp = [self cStringUsingEncoding:NSUTF8StringEncoding];
    if (tmp) {
        
        return  [NSString stringWithCString:tmp encoding:NSNonLossyASCIIStringEncoding];
    }
    
    return nil;
}

- (NSString*)utf8ToUnicode
{
    const char* tmp = [self cStringUsingEncoding:NSNonLossyASCIIStringEncoding];
    if (tmp) {
        
        return  [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (NSString*)latin1ToUtf8
{
    const char* tmp = [self cStringUsingEncoding:NSISOLatin1StringEncoding];
    if (tmp) {
        
        return  [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
    }
    
    return nil;
}


//iso8859-1 单字节，且8位全部使用，所以其他字符均可以使用latin1来表示，或者说均可以转换成latin1编码，然后转换回来
- (NSString*)utf8ToLatin1
{
    //判断是否可以无损化转码
//        if(![self canBeConvertedToEncoding:NSISOLatin1StringEncoding])//有问题，本身就是
//        {
//            const char* tmp = [self cStringUsingEncoding:NSISOLatin1StringEncoding];
//            NSLog(@"[self canBeConvertedToEncoding:NSUTF8StringEncoding]");
//        }
  
    
    const char* tmp = [self cStringUsingEncoding:NSUTF8StringEncoding];
    if (tmp) {
        
        return  [NSString stringWithCString:tmp encoding:NSISOLatin1StringEncoding];
    }
    
    return nil;
}

- (NSString*)latin1ToGBK
{
    if([self canBeConvertedToEncoding:NSISOLatin1StringEncoding])
    {
        NSLog(@"[self canBeConvertedToEncoding:NSISOLatin1StringEncoding]");
    }
    
    const char* tmp = [self cStringUsingEncoding:NSISOLatin1StringEncoding];
    if (tmp) {
        return  [NSString stringWithCString:tmp encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    }
    return nil;
}

- (NSString*)GBKToLatin1
{
    const char* tmp = [self cStringUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    if (tmp) {
        return  [NSString stringWithCString:tmp encoding:NSISOLatin1StringEncoding];
    }
    return nil;
}


/**
 *  json字符串转NSDictionary
 *
 *  @return 返回NSDictionary
 */
- (NSDictionary*)json
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *jsonObject=[NSJSONSerialization
                              JSONObjectWithData:data
                              options:NSJSONReadingMutableLeaves
                              error:nil];
    
    return jsonObject;
}

- (NSData*)hexString2Data
{
    const char* ch = [[self lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* data = [NSMutableData data];
    while (*ch) {
        char byte = 0;
        if ('0' <= *ch && *ch <= '9') {
            byte = *ch - '0';
        } else if ('a' <= *ch && *ch <= 'f') {
            byte = *ch - 'a' + 10;
        }
        ch++;
        byte = byte << 4;
        if (*ch) {
            if ('0' <= *ch && *ch <= '9') {
                byte += *ch - '0';
            } else if ('a' <= *ch && *ch <= 'f') {
                byte += *ch - 'a' + 10;
            }
            ch++;
        }
        [data appendBytes:&byte length:1];
    }
    return data;
    
}
- (BOOL)isHexString
{
    NSString *lowerString = self.lowercaseString;
    
    BOOL ishex = YES;
    
    for (int i = 0; i < self.length; i++) {
        
        unichar ch = [lowerString characterAtIndex:i];
        
        if ( !( '0' <= ch && ch <= '9' ) && !('a' <= ch && ch <= 'f') ) {
            
            ishex = NO;
            break;
        }
    }

    return ishex;
}

- (NSData*)utf8Data
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData*)gbkData
{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [self dataUsingEncoding:gbkEncoding];
}

#pragma mark --URL特殊字符处理

- (NSString*)encodeURLString
{
    
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

- (NSString*)encodeURLString2
{
    
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";

    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

//URLDEcode
-(NSString *)decodeURLString

{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)self,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

//URLDEcode
-(NSString *)decodeURLString2

{
   return [self stringByRemovingPercentEncoding];
}




//截取2个子字符串之间的字符串
- (NSString*)trimBetween:(NSString*)beginSubString and:(NSString*)endSubString
{
    NSRange spos = [self rangeOfString:beginSubString];
    NSRange epos = [self rangeOfString:endSubString];
    
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        return [self substringWithRange:range];
    }
    
    return nil;
}

#pragma mark ---日期转换
- (NSDate *)date
{
    //需要转换的字符串
    //NSString *dateString = @"2015-06-26 08:08:08";
    //设置转换格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString转NSDate
    NSDate *date=[formatter dateFromString:self];
    return date;
}

- (NSDate *)dateWithFormat:(NSString*)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:format];
    return [formatter dateFromString:self];
}


@end




