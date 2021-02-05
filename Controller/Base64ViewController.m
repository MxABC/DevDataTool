//
//  Base64ViewController.m
//  DataHandler
//
//  Created by lbxia on 2017/5/8.
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "Base64ViewController.h"
#import "NSString+LBXBase64.h"
#import "NSString+LBXConverter.h"
#import "NSData+LBXConverter.h"
#import "NSData+LBXBase64.h"
#import "LBXCustomBase64.h"

@interface Base64ViewController ()
@property (weak) IBOutlet NSPopUpButton *base64EnOptions;
@property (weak) IBOutlet NSButton *base64InsertCR;
@property (weak) IBOutlet NSButton *base64InsertLF;
@property (weak) IBOutlet NSButton *deIgnoreUnkown;

@property (weak) IBOutlet NSScrollView *custom64ScrollView;

@property (unsafe_unretained) IBOutlet NSTextView *custom64;
@property (weak) IBOutlet NSTextField *customPaddingChar;
@property (weak) IBOutlet NSButton *supportCustomBase64;

//待base64转换原文类型：原文或hex码
@property (weak) IBOutlet NSPopUpButton *plainType;
@property (weak) IBOutlet NSPopUpButton *dstDataType;

@property (unsafe_unretained) IBOutlet NSTextView *srcTextView;
@property (unsafe_unretained) IBOutlet NSTextView *dstTextView;
@end

@implementation Base64ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[[NSColor grayColor] CGColor]];
    
    [self.view.layer setBackgroundColor:[[NSColor colorWithRed:253/255. green:253/255. blue:250./255.0 alpha:1.0] CGColor]];
    
    //NSPopUpButton默认3个选项，xib上删除不了多余的选项
    [_plainType removeItemAtIndex:2];
    [_dstDataType removeItemAtIndex:2];
    
    [self LineEndingsOptionAction:nil];
    
    
    _customPaddingChar.stringValue = @"=";
    _customPaddingChar.placeholderString = @"不足3字节补位字符";
    _custom64.string = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
//    _custom64.string = @"efghijklmnopqrstuvwxyz0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcd";

}

- (void)refreshCustomStatus
{
    _customPaddingChar.enabled = _supportCustomBase64.state;
    _custom64.editable = _supportCustomBase64.state;
}

- (IBAction)customCheck:(id)sender {
    
    [self refreshCustomStatus];
}

- (IBAction)LineEndingsOptionAction:(id)sender {
    
    NSLog(@"index:%ld",_base64EnOptions.indexOfSelectedItem);
    
    NSLog(@"state:%ld",_base64InsertCR.state);
    NSLog(@"state:%ld",_base64InsertLF.state);
    
    NSLog(@"%@",_srcTextView.string);
}



- (IBAction)enBase64:(id)sender
{
    
    if (_supportCustomBase64.state) {
        
        //自定义
        //初始化自定义
        if(_custom64.string.length != 64)
        {
            [self showAlertWithMessage:@"替换字符不是64个"];
            return;
        }
        if(_customPaddingChar.stringValue.length != 1)
        {
            [self showAlertWithMessage:@"补位字符必须是一个字符"];
            return;
        }
        
        //自定义64字符，最好是可见字符
//        char customBase64EncodeChars[] = {57, 121, 81, 67, 53, 70, 116, 104, 72, 73, 106, 74, 109, 56, 75, 52, 50, 77, 100, 95, 78, 54, 65, 80, 83, 85, 112, 86, 88, 120, 82, 84, 90, 97, 66, 101, 102, 103, 105, 99, 107, 45, 48, 108, 89, 110, 71, 113, 114, 69, 49, 115, 79, 117, 118, 68, 119, 122, 51, 98, 76, 55, 87, 111};
//
//        char customBase64EncodeChars[] = "M#QO&RS%$VWXY?abcABCDEFGHIJKLdefg~ijklmnopqrstuvwxyz0123456789-_";
//
//        char customBase64EncodeChars[] = "efghijklmnopqrstuvwxyz0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcd";

        
        NSData *encodeData = _custom64.string.utf8Data;
        NSData *paddingData = _customPaddingChar.stringValue.utf8Data;
        [LBXCustomBase64 initCustomEncodeChars:(char*)encodeData.bytes paddingChar:((char*)paddingData.bytes)[0]];
        
        
        NSData *plainData = [self dataFromSrcTextView];
        if (!plainData) {
            return;
        }
        NSData *dstdata = [LBXCustomBase64 encodeData:plainData];
        _dstTextView.string = dstdata.utf8String;

    }
    else
    {
        //标准
        
        NSDataBase64EncodingOptions options = 0;
        
        switch (_base64EnOptions.indexOfSelectedItem) {
            case 0:
                options = 0;
                break;
            case 1:
                options = NSDataBase64Encoding64CharacterLineLength;
                break;
            case 2:
                options = NSDataBase64Encoding64CharacterLineLength;
                break;
                
            default:
                break;
        }
        
        if (_base64InsertCR.state) {
            options |= NSDataBase64EncodingEndLineWithCarriageReturn;
        }
        
        if (_base64InsertLF.state) {
            options |= NSDataBase64EncodingEndLineWithLineFeed;
        }
        
        NSData *plainData = [self dataFromSrcTextView];
        if (!plainData) {
            return;
        }
        _dstTextView.string = [plainData base64EncodedDataWithOptions:options].utf8String;
    }

}



//获取输入文本内容
- (NSData*)dataFromSrcTextView
{
    NSString *srcString = _srcTextView.string;
    NSData *data = nil;
  
    switch (_plainType.indexOfSelectedItem) {
        case 0:
            data = srcString.utf8Data;
            break;
        case 1:
        {
            if (_srcTextView.string.length % 2 != 0) {
                
                [self showAlertWithMessage:@"hex code length is not correct!"];
                return nil;
            }
            
            if ( ![_srcTextView.string isHexString] ) {
                
                [self showAlertWithMessage:@"src is not hex code!"];
                return nil;
            }
            
            data  = [_srcTextView.string hexString2Data];
            
            if (!data) {
                
                [self showAlertWithMessage:@"转换失败，确认hex码正常!"];
                return nil;
            }
            
        }
            break;
        default:
            break;
    }
    
    return data;
}


- (IBAction)deBase64:(id)sender {
    
    if (_supportCustomBase64.state) {
        
        //自定义
        //初始化自定义
        if(_custom64.string.length != 64)
        {
            [self showAlertWithMessage:@"替换字符不是64个"];
            return;
        }
        if(_customPaddingChar.stringValue.length != 1)
        {
            [self showAlertWithMessage:@"补位字符必须是一个字符"];
            return;
        }
        
        

        NSData *encodeData = _custom64.string.utf8Data;
        NSData *paddingData = _customPaddingChar.stringValue.utf8Data;
        [LBXCustomBase64 initCustomEncodeChars:(char*)encodeData.bytes paddingChar:((char*)paddingData.bytes)[0]];
        
        
        NSData *plainData = [self dataFromSrcTextView];
        if (!plainData) {
            return;
        }
        
        NSData* data = [LBXCustomBase64 decodeData:plainData];

        if  (_dstDataType.indexOfSelectedItem == 0) {
            _dstTextView.string = data.utf8String;
            
        }else{
            _dstTextView.string = data.hexString;
        }
        
    }
    else{
        
        NSDataBase64DecodingOptions options = 0;
        
        if (_deIgnoreUnkown.state) {
            options = NSDataBase64DecodingIgnoreUnknownCharacters;
        }
        
        NSData *plainData = [self dataFromSrcTextView];
        if (!plainData) {
            return;
        }
        
        if (_dstDataType.indexOfSelectedItem == 0) {
            _dstTextView.string = [plainData.utf8String decodeBase64StringWithOptions:0].utf8String;
            
        }else{
            _dstTextView.string = [plainData.utf8String decodeBase64StringWithOptions:0].hexString;
        }
    }
}

- (void)showAlertWithMessage:(NSString*)message
{
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = message;
    [alert addButtonWithTitle:@"确定"];
    
    NSUInteger action = [alert runModal];
    //响应window的按钮事件
    if(action == NSAlertDefaultReturn)
    {
        NSLog(@"defaultButton clicked!");
    }
    else if(action == NSAlertAlternateReturn )
    {
        NSLog(@"alternateButton clicked!");
    }
    else if(action == NSAlertOtherReturn)
    {
        NSLog(@"otherButton clicked!");
    }
}

@end
