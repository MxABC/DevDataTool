//
//  CryptViewController.m
//  DataHandler
//
//  Created by lbxia on 2017/5/10.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "CryptViewController.h"
#import "NSData+LBXCrypt.h"
#import "NSData+LBXPadding.h"

#import "NSString+LBXConverter.h"
#import "NSString+LBXBase64.h"
#import "NSData+LBXConverter.h"
#import "NSData+LBXBase64.h"

@interface CryptViewController ()

//src
@property (weak) IBOutlet NSPopUpButton *srcDataType;
@property (unsafe_unretained) IBOutlet NSTextView *srcTextView;

//dst
@property (weak) IBOutlet NSPopUpButton *dstDataType;
@property (unsafe_unretained) IBOutlet NSTextView *dstTextView;

//crypt algorithm
@property (weak) IBOutlet NSPopUpButton *cryptAlgorithmList;

//crypt key data type
@property (weak) IBOutlet NSPopUpButton *cryptKeyDataType;

//crypt key data textview
@property (unsafe_unretained) IBOutlet NSTextView *cryptKeyTextView;

//crypt key data size tip,加解密密钥合理的长度提示
@property (weak) IBOutlet NSTextField *cryptKeySizeLabel;

//crypt work option list
@property (weak) IBOutlet NSPopUpButton *cryptOptionList;

//crypt padding list
@property (weak) IBOutlet NSPopUpButton *paddingModeList;


//init vector
@property (weak) IBOutlet NSPopUpButton *ivDataType;

//iv text view
@property (unsafe_unretained) IBOutlet NSTextView *ivTextView;

@end

@implementation CryptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    //删除dst数据类型的第三项
    [_dstDataType removeItemAtIndex:2];
    
    //加解密类型list
    [_cryptAlgorithmList removeAllItems];
    NSArray *arrayAlgorithm = @[@"DES",@"3DES",@"AES",@"SM4"];
    for (NSString *alg in arrayAlgorithm) {
        
        [_cryptAlgorithmList addItemWithTitle:alg];
    }
    
    //padding
    [_paddingModeList removeAllItems];
    NSArray *arrayPadding = @[@"NONE",@"PKCS7",@"PKCS5",@"Zero",@"0x80",@"ANSIX923",@"ISO10126"];
    for (NSString *padding in arrayPadding) {
        
        [_paddingModeList addItemWithTitle:padding];
    }
    
    [_cryptOptionList addItemWithTitle:@"CFB"];
    [_cryptOptionList addItemWithTitle:@"OFB"];
    [_cryptOptionList addItemWithTitle:@"CTR"];
    
    _ivTextView.string = @"0000000000000000";
    
    [self chooseAlgorithmAction:nil];
    
    
    _srcTextView.string = @"12345678";
    _cryptKeyTextView.string = @"12345678";
  
}

- (void)setWithAlgorithm:(LBXAlgorithm)alg
{
    //    NSArray *arrayAlgorithm = @[@"DES",@"3DES",@"AES",@"SM4"];
    switch (alg) {
        case LBXAlgorithm_DES:
            [_cryptAlgorithmList selectItemAtIndex:0];
            break;
        case LBXAlgorithm_3DES:
            [_cryptAlgorithmList selectItemAtIndex:1];
            break;
        case LBXAlgorithm_AES128:
            [_cryptAlgorithmList selectItemAtIndex:2];
            break;
        case LBXAlgorithm_SM4:
            [_cryptAlgorithmList selectItemAtIndex:3];
            break;
            
        default:
            break;
    }
    
    [self chooseAlgorithmAction:nil];
}

- (IBAction)chooseAlgorithmAction:(id)sender {
    
//    NSArray *arrayAlgorithm = @[@"DES",@"3DES",@"AES",@"SM4"];
    NSInteger blockSize = 0;
    NSInteger keySize = 0;
    NSString *blockSizeString = nil;
    NSString* keySizeString = nil;
    switch (_cryptAlgorithmList.indexOfSelectedItem) {
        case 0:
        {
            blockSize = LBXBlockSize_DES;
            keySize = LBXKeySize_DES;
            
            blockSizeString = [NSString stringWithFormat:@"%ld",blockSize];
            keySizeString = [NSString stringWithFormat:@"%ld",keySize];
        }
            break;
        case 1:
        {
            blockSize = LBXBlockSize_3DES;
            keySize = LBXKeySize_3DES_EDE2;
            
            blockSizeString = [NSString stringWithFormat:@"%ld",blockSize];
            
            keySizeString = [NSString stringWithFormat:@"%ld",keySize];
            keySize = LBXKeySize_3DES_EDE3;
            keySizeString = [NSString stringWithFormat:@"%@、%ld",keySizeString,keySize];
        }
            break;
        case 2:
        {
            blockSize = LBXBlockSize_AES128;
            keySize = LBXKeySize_AES128;
            
            blockSizeString = [NSString stringWithFormat:@"%ld",blockSize];
            
            keySizeString = [NSString stringWithFormat:@"%ld",keySize];
            keySize = LBXKeySize_AES256_24;
            keySizeString = [NSString stringWithFormat:@"%@、%ld",keySizeString,keySize];
            
            keySize = LBXKeySize_AES256_32;
            keySizeString = [NSString stringWithFormat:@"%@、%ld",keySizeString,keySize];
        }
            break;
        case 3:
        {
            blockSize = LBXBlockSize_SM4;
            keySize = LBXKeySize_SM4;
            
            blockSizeString = [NSString stringWithFormat:@"%ld",blockSize];
            keySizeString = [NSString stringWithFormat:@"%ld",keySize];

        }
            break;
            
        default:
            break;
    }
    _cryptKeySizeLabel.stringValue = [NSString stringWithFormat:@"crypt key size: %@ bytes\r\nblock size: %@ bytes",keySizeString,blockSizeString];
    
}

- (LBXAlgorithm)algorithmSelected
{
    //    NSArray *arrayAlgorithm = @[@"DES",@"3DES",@"AES",@"SM4"];
    LBXAlgorithm  alg = LBXAlgorithm_DES;
    switch (_cryptAlgorithmList.indexOfSelectedItem) {
        case 0:
            alg = LBXAlgorithm_DES;
            break;
        case 1:
            alg = LBXAlgorithm_3DES;
            break;
        case 2:
            alg = LBXAlgorithm_AES128;
            break;
        case 3:
            alg = LBXAlgorithm_SM4;
            break;
    }
    return alg;
}


- (IBAction)dstStringLowerCase:(id)sender {
    
    _dstTextView.string = _dstTextView.string.lowercaseString;
}

//获取输入文本内容
- (NSData*)dataFromSrcTextView
{
    NSString *srcString = _srcTextView.string;
    NSData *data = nil;
    
    switch (_srcDataType.indexOfSelectedItem) {
        case 0:
            data = srcString.utf8Data;
            break;
        case 1:
            data = [srcString hexString2Data];
            break;
        case 2:
//            data = [srcString dataFromDecodeBase64WithOptions:0];
            data = [srcString decodeBase64StringWithOptions:0];
            break;
        default:
            break;
    }
    
    return data;
}

- (LBXOptionMode)optionMode
{
    //ECB、CBC、CFB
    LBXOptionMode mode = LBXOptionMode_ECB;
    switch (_cryptOptionList.indexOfSelectedItem) {
        case 0:
            mode = LBXOptionMode_ECB;
            break;
        case 1:
            mode = LBXOptionMode_CBC;
            break;
        case 2:
            mode = LBXOptionMode_PCBC;
            break;
        case 3:
            mode = LBXOptionMode_CFB;
            break;
        case 4:
            mode = LBXOptionMode_OFB;
            break;
        case 5:
            mode = LBXOptionMode_CTR;
            break;
            
        default:
            break;
    }

    return mode;
}

- (LBXPaddingMode)paddingMode
{
    //    NSArray *arrayPadding = @[@"NONE",@"PKCS7",@"PKCS5",@"Zero",@"0x80",@"ANSIX923",@"ISO10126"];
    //padding
    LBXPaddingMode padding = LBXPaddingMode_NONE;
    switch (_paddingModeList.indexOfSelectedItem) {
        case 0:
            padding = LBXPaddingMode_NONE;
            break;
        case 1:
            padding = LBXPaddingMode_PKCS7;
            break;
        case 2:
            padding = LBXPaddingMode_PKCS5;
            break;
        case 3:
            padding = LBXPaddingMode_Zero;
            break;
        case 4:
            padding = LBXPaddingMode_0x80;
            break;
        case 5:
            padding = LBXPaddingMode_ANSIX923;
            break;
        case 6:
            padding = LBXPaddingMode_ISO10126;
            break;
            
        default:
            break;
    }
    return padding;
}


- (NSData*)keyStringFromTextView
{
    NSData *keyString = nil;
    
    if (_cryptKeyTextView.string) {
        
        keyString = [_cryptKeyTextView.string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (_cryptKeyDataType.indexOfSelectedItem == 1) {
        
        keyString = [_cryptKeyTextView.string hexString2Data];
    }
    else if (_cryptKeyDataType.indexOfSelectedItem == 2)
    {
        keyString = [_cryptKeyTextView.string decodeBase64StringWithOptions:0];
    }
    
    NSLog(@"hex:%@",keyString.hexString);
    
    return keyString;
}

- (BOOL)isKeySizeCorrectWithDataKey:(NSData*)keyData
{
    BOOL isCorrect = YES;
    NSInteger keySize = keyData.length;
    switch (_cryptAlgorithmList.indexOfSelectedItem) {
        case 0:
        {
            if (LBXKeySize_DES != keySize)
                isCorrect = NO;
        }
            break;
        case 1:
        {
            if( keySize != LBXKeySize_3DES_EDE2 && keySize != LBXKeySize_3DES_EDE3 )
                isCorrect = NO;
        }
            break;
        case 2:
        {
            if (keySize != LBXKeySize_AES128
                && keySize != LBXKeySize_AES256_24
                && keySize != LBXKeySize_AES256_32 )
                isCorrect = NO;
        }
            break;
        case 3:
        {
            if (keySize != LBXKeySize_SM4)
                isCorrect = NO;
        }
            break;
            
        default:
            break;
    }
    
    return  isCorrect;
}


- (BOOL)isKeySizeCorrectWithKey:(NSString*)keyString
{
    BOOL isCorrect = YES;
    NSInteger keySize = keyString.length;
    switch (_cryptAlgorithmList.indexOfSelectedItem) {
        case 0:
        {
            if (LBXKeySize_DES != keySize)
                isCorrect = NO;
        }
            break;
        case 1:
        {
           if( keySize != LBXKeySize_3DES_EDE2 && keySize != LBXKeySize_3DES_EDE3 )
               isCorrect = NO;
        }
            break;
        case 2:
        {
            if (keySize != LBXKeySize_AES128
                && keySize != LBXKeySize_AES256_24
                && keySize != LBXKeySize_AES256_32 )
                isCorrect = NO;
        }
            break;
        case 3:
        {
            if (keySize != LBXKeySize_SM4)
                isCorrect = NO;
        }
            break;
            
        default:
            break;
    }

    return  isCorrect;
}


- (NSString*)ivStringFromTextView
{
    NSString *ivString = _ivTextView.string;
    
    if (ivString == nil || [ivString isEqualToString:@""]) {
        return nil;
    }
    
    if (_ivDataType.indexOfSelectedItem == 1) {
        
        ivString = [ivString hexString2Data].utf8String;
    }
    else if (_ivDataType.indexOfSelectedItem == 2)
    {
        ivString = [ivString decodeBase64StringWithOptions:0].utf8String;
    }
    return ivString;
}

- (void)cryptWithOperation:(LBXOperaton)op
{
    NSData *srcData = [self dataFromSrcTextView];
    
    if (!srcData) {
        
        return;
    }
    
    //ECB,CBC,CFB,...
    LBXOptionMode mode = [self optionMode];
    
    //padding
    LBXPaddingMode padding = [self paddingMode];
    
    //Key
    NSData *keyData = [self keyStringFromTextView];
    //判断key长度是否正确
    if (![self isKeySizeCorrectWithDataKey:keyData]) {
        
        [self showAlertWithMessage:@"密钥长度不正确"];
        return;
    }
    
    //iv 长度与算法分组长度一致，如果输入少于分组长度或者没有输入，默认补0，补足长度为止
    //如果iv长度超过分组长度，直接截取分组长度的数据作为iv
    NSString *ivString = [self ivStringFromTextView];
    
    //算法
    LBXAlgorithm alg = [self algorithmSelected];
    
    //调用
    NSError *error = nil;
    NSData *enData = [srcData LBXCryptWithOp:op algorithm:alg optionMode:mode padding:padding key:keyData iv:ivString error:&error];
    
    if (enData) {
        
        NSLog(@"%@",enData.hexString);
        
        switch (_dstDataType.indexOfSelectedItem) {
            case 0:
                //hex
                _dstTextView.string = enData.hexString;
                break;
            case 1:
                //base64
                _dstTextView.string = [enData encodeBase64WithOptions:0];
                break;
            default:
                break;
        }
    }else
    {
        _dstTextView.string = @"";
        if (error) {
            
            if (error.userInfo && error.userInfo[@"message"] ) {
                
                _dstTextView.string = error.userInfo[@"message"];
            }
            
        }
    }

}

- (IBAction)encryptAction:(id)sender {
    
    [self cryptWithOperation:LBXOperaton_Encrypt];
}

- (IBAction)decryptAction:(id)sender {
    
    [self cryptWithOperation:LBXOperaton_Decrypt];
}

- (void)showAlertWithMessage:(NSString*)message
{
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = message;
    [alert addButtonWithTitle:@"确定"];
    [alert runModal];
}

@end



