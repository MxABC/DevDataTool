//
//  HashViewController.m
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  Copyright © 2017年 LBX. All rights reserved.
//

#import "HashViewController.h"
#import "NSString+LBXConverter.h"
#import "NSData+LBXConverter.h"
#import "NSString+LBXBase64.h"
#import "NSData+LBXBase64.h"
#import "NSString+LBXHash.h"
#import "NSData+SHA3.h"
#import "NSString+SHA3.h"
#import "NSData+LBXHash.h"
#import "NSData+LBXCommonCrypto.h"



@interface HashViewController ()
//原数据类型
@property (weak) IBOutlet NSPopUpButton *srcDataType;

//转换后数据类型
@property (weak) IBOutlet NSPopUpButton *dstDataType;
//在转换后的数据为hex形式时，显示该按钮
@property (weak) IBOutlet NSButton *dstStringLowercaseButton;

//hash 类型
@property (weak) IBOutlet NSPopUpButton *popHashType;

//hmac
@property (weak) IBOutlet NSPopUpButton *hmacKeyDataType;
@property (weak) IBOutlet NSTextField *hmacTip;
@property (weak) IBOutlet NSTextField *hmacKey;
@property (weak) IBOutlet NSTextField *hmacKeySize;


@property (unsafe_unretained) IBOutlet NSTextView *srcTextView;
@property (unsafe_unretained) IBOutlet NSTextView *dstTextView;


@property (nonatomic, assign,getter=isHmacMode) BOOL hmacMode;

@end

@implementation HashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[[NSColor colorWithRed:253/255. green:253/255. blue:250./255.0 alpha:1.0] CGColor]];
    
    _hmacTip.hidden = YES;
    _hmacKey.hidden = YES;
    _hmacKeyDataType.hidden = YES;
    _hmacKeySize.hidden = YES;
    
    [_dstDataType removeItemAtIndex:2];
    
    [_popHashType removeAllItems];
    
    
//    [NSMenuItem separatorItem];
    
  
    
    NSArray *array = @[@"MD5",@"SHA1",@"SHA2-256",@"SHA2-384",@"SHA2-512",@"SHA3-256",@"SHA3-384",@"SHA3-512",@"SM3"];
    for (int i = 0; i < array.count; i++) {
        [_popHashType addItemWithTitle:array[i]];
    }
    
//    _dstTextView.string = @"fdsajl";
}

- (IBAction)HashAction:(id)sender {

    
    if (_hmacMode) {
        
        [self hmacAction];
        return;
    }
    
    NSString *srcString = _srcTextView.string;

    NSData *dataString = [_srcTextView.string dataUsingEncoding:NSUTF8StringEncoding];
    if (_srcDataType.indexOfSelectedItem == 1) {
        
        dataString = [srcString hexString2Data];
    }
    else if (_srcDataType.indexOfSelectedItem == 2)
    {
        dataString = [srcString decodeBase64StringWithOptions:0];
    }
    
    NSData *dst = nil;
    
    switch (_popHashType.indexOfSelectedItem) {
        case 0:
            //MD5
            dst = [dataString md5];
            break;
        case 1:
            //SHA1
            dst = [dataString sha1];
            break;
        case 2:
            //SHA2-256
            dst = [dataString sha2_256];
            break;
        case 3:
            //SHA2-384
            dst = [dataString sha2_384];
            break;
        case 4:
            //SHA2-512
            dst = [dataString sha2_512];
            break;
        case 5:
            //SHA3-256
            dst = [dataString sha3:256];
            break;
        case 6:
            //SHA3-384
            dst = [dataString sha3:384];
            break;
        case 7:
            //SHA3-512
            dst = [dataString sha3:512];
            break;
        case 8:
            //SM3
            dst = [dataString sm3];
            break;
            
        default:
            break;
    }
    
    //在线hash
//    http://www.atool.org/hash.php
    
    NSString *dstString = nil;
    switch (_dstDataType.indexOfSelectedItem) {
        case 0:
            dstString = dst.hexString;
            break;
        case 1:
            dstString = [dst base64EncodedDataWithOptions:0].utf8String;
            break;
        default:
            break;
    }
    
    if (dstString) {
        _dstTextView.string = dstString;
    }
   
}

- (void)hmacAction
{
    NSString *srcString = _srcTextView.string;
    
    
    //除SM3以外，密钥长度不限制，内部算法会自动处理
    NSString *hmacKey = _hmacKey.stringValue;
    
    if (_hmacKeyDataType.indexOfSelectedItem == 1) {
        hmacKey = [hmacKey hexString2Data].utf8String;
    }
    else if (_hmacKeyDataType.indexOfSelectedItem == 2)
    {
        hmacKey = [hmacKey decodeBase64WithOptions:0];
    }
    
    
    NSData *dst = nil;
    
    switch (_popHashType.indexOfSelectedItem) {
        case 0:
            //MD5
            dst = [srcString.utf8Data lbxHmacWithKey:hmacKey algorithm:LBXHmacAlgMD5];
            break;
        case 1:
            //SHA1
//            dst = [srcString.utf8Data HMACWithAlgorithm:kCCHmacAlgSHA1 key:hmacKey];
            dst = [srcString.utf8Data lbxHmacWithKey:hmacKey algorithm:LBXHmacAlgSHA1];
            break;
        case 2:
            //SHA2-256
            dst = [srcString.utf8Data HMACWithAlgorithm:kCCHmacAlgSHA256 key:hmacKey];
            break;
        case 3:
            //SHA2-384
            dst = [srcString.utf8Data HMACWithAlgorithm:kCCHmacAlgSHA384 key:hmacKey];
            break;
        case 4:
            //SHA2-512
            dst = [srcString.utf8Data HMACWithAlgorithm:kCCHmacAlgSHA512 key:hmacKey];
            break;
        case 5:
            //SHA3-256
            dst = [srcString.utf8Data lbxHmacWithKey:hmacKey algorithm:LBXHmacAlgSHA3_256];
            break;
        case 6:
            //SHA3-384
            dst = [srcString.utf8Data lbxHmacWithKey:hmacKey algorithm:LBXHmacAlgSHA3_384];
            break;
        case 7:
            //SHA3-512
            dst = [srcString.utf8Data lbxHmacWithKey:hmacKey algorithm:LBXHmacAlgSHA3_512];
            break;
        case 8:
            //SM3
//            if (hmacKey.length != 16) {
//                
//                [self showAlertWithMessage:@"sm3hmac key must be 16 bytes!"];
//                return;
//            }
//            dst = [srcString.utf8Data sm3_hmacWithKey:hmacKey];
            dst = [srcString.utf8Data lbxHmacWithKey:hmacKey algorithm:LBXHmacAlgSM3];
            break;
            
        default:
            break;
    }
    
    //在线hash
    //    http://www.atool.org/hash.php
    
    NSString *dstString = nil;
    switch (_dstDataType.indexOfSelectedItem) {
        case 0:
            dstString = dst.hexString;
            break;
        case 1:
            dstString = [dst base64EncodedDataWithOptions:0].utf8String;
            break;
        default:
            break;
    }
    
    if (dstString) {
        _dstTextView.string = dstString;
    }

}

- (IBAction)lowercaseStringAction:(id)sender {
    
    _dstTextView.string = _dstTextView.string.lowercaseString;
}

- (IBAction)dstStringTypeAction:(id)sender {
    
    switch (_dstDataType.indexOfSelectedItem ) {
        case 0:
            _dstStringLowercaseButton.hidden = NO;
            break;
        case 1:
            _dstStringLowercaseButton.hidden = YES;
            break;
        default:
            break;
    }
}

- (void)setHashType:(HASHType)type
{
    self.hmacMode = NO;
    
    switch (type) {
        case HASHType_MD5:
            [_popHashType selectItemAtIndex:0];
            break;
        case HASHType_SHA:
            
            if ( !(_popHashType.indexOfSelectedItem >= 1 && _popHashType.indexOfSelectedItem <=5) ) {
                 [_popHashType selectItemAtIndex:1];
            }
           
            break;
        case HASHType_SM3:
            [_popHashType selectItemAtIndex:8];
            break;
        case HASHType_HMAC:
            self.hmacMode = YES;
            break;
        default:
            break;
    }
    
    [self hmacSettingShowOrHidden];
}

- (void)hmacSettingShowOrHidden
{
    _hmacTip.hidden = YES;
    _hmacKey.hidden = YES;
    _hmacKeyDataType.hidden = YES;
    _hmacKeySize.hidden = YES;
    
    if ( _hmacMode ) {
        
        _hmacTip.hidden = NO;
        _hmacKey.hidden = NO;
        _hmacKeyDataType.hidden = NO;
//        _hmacKeySize.hidden = NO;
    }

}

- (void)showHashKeySize
{
    //hash密钥长度不超过64bytes即可
    
    switch (_popHashType.indexOfSelectedItem) {
        case 0:
            
            break;
            
        default:
            break;
    }
}


- (void)showAlertWithMessage:(NSString*)message
{
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = message;
    [alert addButtonWithTitle:@"确定"];
    [alert runModal];
}

@end
