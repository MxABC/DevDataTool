//
//
//
//
//  Created by lbxia on 16/9/9.
//  https://github.com/MxABC/DevDataTool
//  https://github.com/MxABC/DevDataTool
//  Copyright © 2016年 lbx. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 证书版本号
 证书序列号
 颁发者信息
 有效期范围
 公钥信息
 */
@interface LBXCertificationModel : NSObject

//证书序列号
@property (nonatomic, strong) NSString* hexSerialNumber;

//大数表示的证书序列号
@property (nonatomic, strong) NSString* bigNumSerialNumber;

//证书版本号
@property (nonatomic, strong) NSString* cerVersion;

//密钥用途，加密 or 签名
@property (nonatomic, strong) NSString* keyUsage;

//签名算法
@property (nonatomic, strong) NSString* signAlgorithm;

//有效期开始日期
@property (nonatomic, strong) NSString* enableCerFrom;

//有效截止日期
@property (nonatomic, strong) NSString* disableCerTo;

//公钥数据,hex表示
@property (nonatomic, strong) NSString* publicKey;

//证书的签名值,hex表示
@property (nonatomic, strong) NSString *signature;

//SHA1指纹
@property (nonatomic, strong) NSString* fingerprint_SHA1;
//MD5指纹
@property (nonatomic, strong) NSString* fingerprint_MD5;

@end


/**
 签名者、主题信息、持有者内容，部分内容格式如下(可以包含很多其他信息)，具体可以看代码
 */
@interface LBXCertificateIssuerModel : NSObject
//国家、地区
@property (nonatomic, strong) NSString* country;
//省、市、自治区
@property (nonatomic, strong) NSString* province;

//所在地,地区
@property (nonatomic, strong) NSString* localPlace;


//组织
@property (nonatomic, strong) NSString* organization;
//组织单位
@property (nonatomic, strong) NSString* organizationUnit;


//常用名称
@property (nonatomic, strong) NSString* commonName;
//序列号
@property (nonatomic, strong) NSString* serialNumber;
//电子邮件
@property (nonatomic, strong) NSString* email;

@end


@interface LBXCertificate : NSObject

@property (nonatomic, strong) LBXCertificationModel *cerInfoModel;

+ (instancetype)sharedManager;

+ (void)test;


//加载hex字符串证书数据
- (BOOL)loadCerHexString:(NSString*)hexString;


/**
 *  加载证书
 *
 *  @param data 证书数据
 *
 *  @return 返回加载成功或失败
 */
- (BOOL)loadCerData:(NSData*)data;



/**
 获取证书相关信息

 @return 证书信息
 */
- (LBXCertificationModel*)certficationBaseInfo;


/**
 获取签名者信息

 @return 返回信息
 */
- (LBXCertificateIssuerModel*)certificationIssuerInfo;


/**
 获取主题信息
 
 @return 返回信息
 */
- (LBXCertificateIssuerModel*)certificationSubjectInfo;


/**
 持有者信息(使用者)
 
 @return 返回信息
 */
- (LBXCertificateIssuerModel*)certificationWhoHave;


#pragma mark --验证签名

- (BOOL)rsa_check_sign:(NSString*)srcString signString:(NSString*)signString;


+ (NSString*)hexString:(Byte*)data len:(int)len;


+ (NSString*)SHA1:(NSString*)src;

@end
