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

@interface Base64ViewController ()
@property (weak) IBOutlet NSPopUpButton *base64EnOptions;
@property (weak) IBOutlet NSButton *base64InsertCR;
@property (weak) IBOutlet NSButton *base64InsertLF;
@property (weak) IBOutlet NSButton *deIgnoreUnkown;

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
}

- (IBAction)LineEndingsOptionAction:(id)sender {
    
    NSLog(@"index:%ld",_base64EnOptions.indexOfSelectedItem);
    
    NSLog(@"state:%ld",_base64InsertCR.state);
    NSLog(@"state:%ld",_base64InsertLF.state);
    
    NSLog(@"%@",_srcTextView.string);
}



- (IBAction)enBase64:(id)sender
{
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
