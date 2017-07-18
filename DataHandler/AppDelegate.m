//
//  AppDelegate.m
//  DataHandler
//
//  Created by lbxia on 2017/3/1.
//  Copyright © 2017年 LBX. All rights reserved.
//


#import "AppDelegate.h"
#import <PXSourceList.h>
#import <Masonry.h>
#import <objc/message.h>

#import "WorkingOnItViewController.h"

#import "Base64ViewController.h"
#import "HashViewController.h"
#import "CryptViewController.h"
#import "ParseCertifiationController.h"
#import "NSData+LBXCrypt.h"
#import "NSString+LBXConverter.h"

@interface AppDelegate ()<NSWindowDelegate>


@property (weak, nonatomic) IBOutlet PXSourceList *sourceList;
@property (weak, nonatomic) IBOutlet NSTextField *selectedItemLabel;

@property (strong, nonatomic) NSMutableArray *sourceListItems;
@property (nonatomic, strong) NSArray *modelObjects;


@property (nonatomic, strong) WorkingOnItViewController *workingOnItVC;

@property (nonatomic, strong) Base64ViewController *base64VC;
@property (nonatomic, strong) HashViewController *hashVC;
@property (nonatomic, strong) CryptViewController *cryptVC;
@property (nonatomic, strong) ParseCertifiationController *parseCerVC;
@end

@implementation AppDelegate

#pragma mark -
#pragma mark Init/Dealloc

- (void)awakeFromNib
{
	[self.selectedItemLabel setStringValue:@"(none)"];
	
	self.sourceListItems = [[NSMutableArray alloc] init];
    
    [self setUpDataModel];
	
	[self.sourceList reloadData];
    
    [self performSelector:@selector(setDelayDelegate) withObject:nil afterDelay:0.5];
    
//    [self saveFile];
}

- (void)saveFile
{
      NSString *sm2hex = @"30820237308201DBA003020102020600E49AE190C4300C06082A811CCF550183750500303E310B300906035504061302434E31133011060355040A0C0A4E5859534D3254455354311A301806035504030C114E5859534D3243414348494C4454455354301E170D3137303531383037313130335A170D3232303431333038323230345A3051310B300906035504061302636E3110300E060355040A0C076E78797465737431123010060355040B0C09437573746F6D657273311C301A06035504030C13303633403833333339313030303030303030313059301306072A8648CE3D020106082A811CCF5501822D0342000450DE241AE4FDD5FB8DEF3866DFFD8A33B6F0B8452A129B1EDC0C43B35A15AFFC54606FC33C68A7CEF8AAE05B6CD6661970AFF79DEFC85657FD944E9847967544A381AF3081AC301F0603551D230418301680149EC74479206FED304A2A1D5C7F09C71A6400686430090603551D130402300030520603551D1F044B30493047A045A043A441303F310D300B06035504030C0463726C34310C300A060355040B0C0363726C31133011060355040A0C0A4E5859534D3254455354310B300906035504061302434E300B0603551D0F040403020780301D0603551D0E04160414BD7350586966FDAEC6D2F6C2019269144541D7CA300C06082A811CCF5501837505000348003045022030734AFFDC0BC0999B462B2FAEC6CC122F063E8F0B8E4C9B097C2F340F373F5A022100CAE635F400E530A4C3F0A368DFAAF58403B90C4D49D779BFDFEC1A7B287C04D4";
    
    NSData *data = sm2hex.utf8Data;
    
    [data writeToFile:@"sm2.cer" atomically:YES];
}

- (void)setDelayDelegate
{
     [NSApplication sharedApplication].keyWindow.delegate = self;
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    NSSize size = frameSize;
    if (size.width < 1000) {
        size.width = 1000;
    }
    
    if (size.height < 700)
    {
        size.height = 700;
    }
    
    return size;
}

- (void)setUpDataModel
{
    
    //格式校验  json: https://github.com/youknowone/VisualJSON
    NSArray *item0 = @[
                       @{@"title":@"Json",@"identifer":@"json"},
                       @{@"title":@"Xml",@"identifer":@"xml"}
                       ];
    
    //编码转换,位操作保持 异或，与，移位等，循环移位等
    NSArray *item1 = @[
                       @{@"title":@"Base64",@"identifer":@"base64"},
                       @{@"title":@"Hex",@"identifer":@"hex"},
                       @{@"title":@"bit operation",@"identifer":@"bit"}
                       ];
    
    //散列函数
    //MD5,SHA1,SHA2,SHA3,SM3,HMAC通过界面下拉选择
    NSArray *item2 = @[
                       @{@"title":@"MD5",@"identifer":@"md5"},
                       @{@"title":@"SHA",@"identifer":@"sha"},
                       @{@"title":@"SM3",@"identifer":@"sm3"},
                       @{@"title":@"HMAC",@"identifer":@"hmac"},
                       ];
    
    //对称加解密
    NSArray *item3 = @[
                       @{@"title":@"DES",@"identifer":@"des"},
                       @{@"title":@"3DES",@"identifer":@"desede"},
                       @{@"title":@"AES",@"identifer":@"aes"},
                       @{@"title":@"SM4",@"identifer":@"sm4"},
                       ];
    
    //非对称加解密:私钥签名，公钥验证签名，密钥协商
    NSArray *item4 = @[
                       @{@"title":@"RSA2048",@"identifer":@"rsa2048"},
                       @{@"title":@"DH",@"identifer":@"dh"},
                       @{@"title":@"ECDH",@"identifer":@"ecdh"},
                       @{@"title":@"SM2",@"identifer":@"sm2"}
                       ];
    
    
    
    //证书操作:读取显示，证书链怎么验证的?
    NSArray *item5 = @[@{@"title":@"证书",@"identifer":@"cer"}];
    
    //关于内写作者，项目介绍，邮箱，blog,github，下载地址等,打赏二维码
    //注意事项：比如内容的 plain,hex,hex为了方便复制、粘贴
    NSArray *item6 = @[
                       @{@"title":@"About",@"identifer":@"about"},
                       @{@"title":@"注意事项",@"identifer":@"attention"}
                       ];
    
    //分组
    NSArray *arrayItem = @[@"格式检验",@"转换",@"散列算法",@"对称加解密",@"非对称加解密",@"证书",@"关于"];
    //每组包含的项
    NSArray *arraySubItem = @[item0,item1,item2,item3,item4,item5,item6];

    
    for (int i = 0; i < arrayItem.count; i++)
    {
        PXSourceListItem *listItem = [PXSourceListItem itemWithTitle:arrayItem[i] identifier:nil];
        NSArray *subItems = arraySubItem[i];
        
        for (int j = 0; j < subItems.count; j++)
        {
            NSDictionary *dic = subItems[j];
            
            PXSourceListItem *subItem = [PXSourceListItem itemWithTitle:dic[@"title"] identifier:dic[@"identifer"]];
            
            [listItem addChildItem:subItem];
        }
        [self.sourceListItems addObject:listItem];
    }
    
   
}

#pragma mark -
#pragma mark Source List Data Source Methods

- (NSUInteger)sourceList:(PXSourceList*)sourceList numberOfChildrenOfItem:(id)item
{
	//Works the same way as the NSOutlineView data source: `nil` means a parent item
	if(item==nil) {
		return [self.sourceListItems count];
	}
	else {
		return [[item children] count];
	}
}


- (id)sourceList:(PXSourceList*)aSourceList child:(NSUInteger)index ofItem:(id)item
{
	//Works the same way as the NSOutlineView data source: `nil` means a parent item
	if(item==nil) {
		return [self.sourceListItems objectAtIndex:index];
	}
	else {
		return [[item children] objectAtIndex:index];
	}
}


- (id)sourceList:(PXSourceList*)aSourceList objectValueForItem:(id)item
{
	return [item title];
}


- (void)sourceList:(PXSourceList*)aSourceList setObjectValue:(id)object forItem:(id)item
{
	[item setTitle:object];
}


- (BOOL)sourceList:(PXSourceList*)aSourceList isItemExpandable:(id)item
{
	return [item hasChildren];
}


- (BOOL)sourceList:(PXSourceList*)aSourceList itemHasBadge:(id)item
{
	return !![(PXSourceListItem *)item badgeValue];
}


- (NSInteger)sourceList:(PXSourceList*)aSourceList badgeValueForItem:(id)item
{
	return [(PXSourceListItem *)item badgeValue].integerValue;
}


- (BOOL)sourceList:(PXSourceList*)aSourceList itemHasIcon:(id)item
{
	return !![item icon];
}


- (NSImage*)sourceList:(PXSourceList*)aSourceList iconForItem:(id)item
{
	return [item icon];
}

- (NSMenu*)sourceList:(PXSourceList*)aSourceList menuForEvent:(NSEvent*)theEvent item:(id)item
{
	if ([theEvent type] == NSRightMouseDown || ([theEvent type] == NSLeftMouseDown && ([theEvent modifierFlags] & NSControlKeyMask) == NSControlKeyMask)) {
		NSMenu * m = [[NSMenu alloc] init];
		if (item != nil) {
			[m addItemWithTitle:[item title] action:nil keyEquivalent:@""];
		} else {
			[m addItemWithTitle:@"clicked outside" action:nil keyEquivalent:@""];
		}
		return m;
	}
	return nil;
}

#pragma mark -
#pragma mark Source List Delegate Methods

- (BOOL)sourceList:(PXSourceList*)aSourceList isGroupAlwaysExpanded:(id)group
{
//	if([[group identifier] isEqualToString:@"library"])
//		return YES;
//	
//	return NO;
    
    return YES;
}


- (void)sourceListSelectionDidChange:(NSNotification *)notification
{
	NSIndexSet *selectedIndexes = [self.sourceList selectedRowIndexes];
	
	//Set the label text to represent the new selection
	if([selectedIndexes count]>1)
		[self.selectedItemLabel setStringValue:@"(multiple)"];
	else if([selectedIndexes count]==1) {
		NSString *identifier = [[self.sourceList itemAtRow:[selectedIndexes firstIndex]] identifier];
		
		[self.selectedItemLabel setStringValue:identifier];
        
        [self removeElseViews];
        
        SEL op = NSSelectorFromString(identifier);
        if ([self respondsToSelector:op]) {
            ( (void (*)(id,SEL)) objc_msgSend)(self,op);
        }else{

            [self workingOnItView];
        }
        
	}
	else {
		[self.selectedItemLabel setStringValue:@"(none)"];
	}    
    
}

- (void)workingOnItView
{
    if (!_workingOnItVC) {
        self.workingOnItVC = [[WorkingOnItViewController alloc]init];
        
        NSView* superview = [NSApplication sharedApplication].keyWindow.contentView;
        [superview addSubview:_workingOnItVC.view];
        
        [_workingOnItVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(superview.mas_top);
            make.left.equalTo(superview.mas_left).with.offset(200);
            make.right.equalTo(superview.mas_right);
            make.bottom.equalTo(superview.mas_bottom);
        }];
    }
    _workingOnItVC.view.hidden = NO;
}

- (void)removeElseViews
{
    if (_base64VC) {
        _base64VC.view.hidden = YES;
    }
    if (_hashVC) {
        _hashVC.view.hidden = YES;
    }
    if (_cryptVC) {
        _cryptVC.view.hidden = YES;
    }
    
    if (_workingOnItVC) {
        _workingOnItVC.view.hidden = YES;
    }
    if (_parseCerVC) {
        _parseCerVC.view.hidden = YES;
    }
    
    _selectedItemLabel.hidden = YES;
}

#pragma mark ---- base64 -----
- (void)base64
{
    if (!_base64VC) {
        self.base64VC = [[Base64ViewController alloc]init];
        
        NSView* superview = [NSApplication sharedApplication].keyWindow.contentView;
        [superview addSubview:_base64VC.view];
        
        [_base64VC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(superview.mas_top);
            make.left.equalTo(superview.mas_left).with.offset(200);
            make.right.equalTo(superview.mas_right);
            make.bottom.equalTo(superview.mas_bottom);
        }];
    }
    
    _selectedItemLabel.hidden = YES;
    _base64VC.view.hidden = NO;
    
   
}

#pragma mark --- hash ----
- (void)hashWithType:(HASHType)type
{
    if (!_hashVC) {
        
        self.hashVC = [[HashViewController alloc]init];
        NSView* superview = [NSApplication sharedApplication].keyWindow.contentView;
        [superview addSubview:_hashVC.view];
        
        
        [_hashVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(superview.mas_top);
            make.left.equalTo(superview.mas_left).with.offset(200);
            make.right.equalTo(superview.mas_right);
            make.bottom.equalTo(superview.mas_bottom);
        }];
    }
    
    _selectedItemLabel.hidden = YES;
    _hashVC.view.hidden = NO;
    
    [_hashVC setHashType:type];
}


- (void)md5
{
    [self hashWithType:HASHType_MD5];
}
- (void)sha
{
    [self hashWithType:HASHType_SHA];
}
- (void)sm3
{
    [self hashWithType:HASHType_SM3];
}
- (void)hmac
{
    [self hashWithType:HASHType_HMAC];
}


#pragma mark ---- crypt ----



- (void)des
{
    [self cryptWithAlgorithm:LBXAlgorithm_DES];
}
- (void)desede
{
     [self cryptWithAlgorithm:LBXAlgorithm_3DES];
}
- (void)aes
{
     [self cryptWithAlgorithm:LBXAlgorithm_AES128];
}

- (void)sm4
{
     [self cryptWithAlgorithm:LBXAlgorithm_SM4];
}

- (void)cryptWithAlgorithm:(LBXAlgorithm)alg
{
    if (!_cryptVC) {
        
        self.cryptVC = [[CryptViewController alloc]init];
        NSView* superview = [NSApplication sharedApplication].keyWindow.contentView;
        [superview addSubview:_cryptVC.view];
        
        
        [_cryptVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(superview.mas_top);
            make.left.equalTo(superview.mas_left).with.offset(200);
            make.right.equalTo(superview.mas_right);
            make.bottom.equalTo(superview.mas_bottom);
        }];
    }
    
     _selectedItemLabel.hidden = YES;
    _cryptVC.view.hidden = NO;
    [_cryptVC setWithAlgorithm:alg];
    

}

- (void)parseCer
{
    if (!_parseCerVC) {
        
        self.parseCerVC = [[ParseCertifiationController alloc]init];
        NSView* superview = [NSApplication sharedApplication].keyWindow.contentView;
        [superview addSubview:_parseCerVC.view];
        
        
        [_parseCerVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(superview.mas_top);
            make.left.equalTo(superview.mas_left).with.offset(200);
            make.right.equalTo(superview.mas_right);
            make.bottom.equalTo(superview.mas_bottom);
        }];
    }
    
    _parseCerVC.view.hidden = NO;
    
}

- (void)cer
{
    [self parseCer];
}

- (void)sourceListDeleteKeyPressedOnRows:(NSNotification *)notification
{
	NSIndexSet *rows = [[notification userInfo] objectForKey:@"rows"];
	
	NSLog(@"Delete key pressed on rows %@", rows);
	
	//Do something here
}

@end
