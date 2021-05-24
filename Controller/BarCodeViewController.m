//
//  BarCodeViewController.m
//  DataHandler
//
//  Created by lbxia on 2021/5/24.
//  Copyright © 2021 LBX. All rights reserved.
//

#import "BarCodeViewController.h"
#import <CoreImage/CoreImage.h>
#import "NSString+LBXConverter.h"

@interface BarCodeViewController ()
@property (weak) IBOutlet NSImageView *barImageView;

@end

@implementation BarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSString *str = @"数据库连接正常";
    
    NSString *gbk = str.utf8ToGBK;
    
//    gbk = @"123涓枃";
//
//    str = gbk.gbkToUtf8;
    
    //CAFDBEDDBFE2C1AC BD D3 D5 FD B3 A3 C5
    unsigned char t[] = {0xCA,0xFD,0xBE,0xDD,0xBF,0xE2,0xC1,0xAC,0xBD,0xD3,0xD5,0xFD,0xB3,0xA3};
    NSData *data = [NSData dataWithBytes:t length:sizeof(t)];

//    - (nullable const char *)cStringUsingEncoding:(NSStringEncoding)encoding
    
//    const char *p = [gbk cStringUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    
//    char buffer[1024]={0};
//
//    [gbk getCString:buffer maxLength:1024 encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
//
//    NSData *data = [NSData dataWithBytes:buffer length:strlen(buffer)];
//    NSLog( @"hex:%@",[self hexString:data] );
    
    NSImage *img = [self createQRWithData:data QRSize:CGSizeMake(200, 200)];
    self.barImageView.image = [self resizeImage2:img forSize:CGSizeMake(200, 200)];
    
}

- (NSString*)hexString:(NSData*)data
{
    NSMutableString *arrayString = [[NSMutableString alloc]initWithCapacity:data.length * 2];
    int len = (int)data.length;
    unsigned char* bytes = (unsigned char*)data.bytes;
    
    for (int i = 0; i < len; i++)
    {
        unsigned char cValue = bytes[i];
        
//        int iValue = cValue;
//        iValue = iValue & 0x000000FF;
        
        NSString *str = [NSString stringWithFormat:@"%02x",cValue];
        
        [arrayString appendString:str];
    }
    
    return arrayString.uppercaseString;
}

- (NSImage*)createQRWithData:(NSData*)data QRSize:(CGSize)size
{
    NSData *stringData = data;
    
    //生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    
    //绘制
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
   
    NSImage *codeImage = [self imageFromCGImageRef:cgImage];
    
    return codeImage;
}


// 等比缩放
- (NSImage*)resizeImage2:(NSImage*)sourceImage forSize:(CGSize)targetSize {

    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;

        // scale to fit the longer
        scaleFactor = (widthFactor>heightFactor)?widthFactor:heightFactor;
        scaledWidth  = ceil(width * scaleFactor);
        scaledHeight = ceil(height * scaleFactor);

        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }

    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(scaledWidth, scaledHeight)];
    CGRect thumbnailRect = {thumbnailPoint, {scaledWidth, scaledHeight}};
    NSRect imageRect = NSMakeRect(0.0, 0.0, width, height);

    [newImage lockFocus];
    [sourceImage drawInRect:thumbnailRect fromRect:imageRect operation:NSCompositeCopy fraction:1.0];
    [newImage unlockFocus];

//     UIGraphicsBeginImageContext(targetSize); // this will crop
//
//     CGRect thumbnailRect = CGRectZero;
//     thumbnailRect.origin = thumbnailPoint;
//     thumbnailRect.size.width  = scaledWidth;
//     thumbnailRect.size.height = scaledHeight;
//     [sourceImage drawInRect:thumbnailRect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
//     //[sourceImage drawInRect:thumbnailRect];
//
//     newImage = UIGraphicsGetImageFromCurrentImageContext();
//     if(newImage == nil)
//     NSLog(@"could not scale image");
//
//     //pop the context to get back to the default
//     UIGraphicsEndImageContext();


    return newImage;
}



//CGImageRef 转换为 NSImage
- (NSImage*)imageFromCGImageRef:(CGImageRef)image
{

    
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    
    CGContextRef imageContext = nil;
    
    NSImage* newImage = nil;
    
    imageRect.size.height = CGImageGetHeight(image);

    imageRect.size.width = CGImageGetWidth(image);
    
//    imageRect.size.height = 200;
//
//    imageRect.size.width = 200;
    
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    
    [newImage lockFocus];
        
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext]
                                  
                                  graphicsPort];
    
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    
    [newImage unlockFocus];

    return newImage;
    
}
@end
