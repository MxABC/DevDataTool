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
#import <CoreLocation/CoreLocation.h>

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
    
    
    //wifi 二维码
    
    /*
     
     https://www.chenyudong.com/archives/wifi-qrcode-in-home-android-and-ios.html
     
     WIFI:T:WPA;S:wifiname;P:wifipasswd;
     
     说明一下：

     WIFI 表示这个是一个连接 WiFi 的协议
     S 表示后面是 WiFi 的 SSID，wifiname 也就是 WiFi 的名称
     P 表示后面是 WiFi 的密码，wifipasswd 是 WiFi 的密码
     T 表示后面是密码的加密方式，WPA/WPA2 大部分都是这个加密方式，也使用WPA。如果写WPA/WPA2我的小米手机无法识别。
     H 表示这个WiFi是否是隐藏的，直接打开 WiFi 扫不到这个信号。苹果还不支持隐藏模式
     
     iOS11 使用系统相机或二维码扫码功能均可扫描 会提示是否需要加入 xx wifi
     
     Android大部分手机自带相机均支持扫码加入wifi
     
     */
    
    str = @"WIFI:T:WPA;S:TP-LINK_B8E9;P:12345678;";
    str = @"WIFI:T:WPA/WPA2;S:TP-LINK_B8E9;P:handkoo123456;";

    data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
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
        
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                                       pixelsWide:256
                                                                       pixelsHigh:256
                                                                    bitsPerSample:8
                                                                  samplesPerPixel:4
                                                                         hasAlpha:YES
                                                                         isPlanar:NO
                                                                   colorSpaceName:NSDeviceRGBColorSpace
                                                                      bytesPerRow:4 * 256
                                                                     bitsPerPixel:32];
    NSGraphicsContext *g = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    CGContextRef context = [g graphicsPort];
    
    CIContext *ciContext = [CIContext contextWithCGContext:context options:nil];
    CGImageRef img = [ciContext createCGImage:[qrFilter outputImage] fromRect:[[qrFilter outputImage] extent]];
    
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGRectMake(0, 0, 256, 256), img);
    CGImageRef output_image = CGBitmapContextCreateImage(context);
    
    
    //画像保存
//    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/hoge.png"];
//    
//    NSBitmapImageRep* rep2 = [[NSBitmapImageRep alloc] initWithCGImage:output_image];
//    NSData* PNGData = [rep2 representationUsingType:NSPNGFileType properties:nil];
//    [PNGData writeToFile:path atomically:NO];
//    //関連するアプリ（プレビューなど）で表示
//    [[NSWorkspace sharedWorkspace] openFile:path];
//    
    
    NSImage *codeImage = [self imageFromCGImageRef:output_image];

    
    return codeImage;
}

- (NSImage*)createQRWithData2:(NSData*)data QRSize:(CGSize)size
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
    
//    codeImage = [self resizeImage2:codeImage forSize:CGSizeMake(200, 200)];
    
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
    
    newImage = [[NSImage alloc]initWithSize:imageRect.size];
    
    [newImage lockFocus];
        
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext]
                                  graphicsPort];
    
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image);
    
    [newImage unlockFocus];

    return newImage;
    
}
@end
