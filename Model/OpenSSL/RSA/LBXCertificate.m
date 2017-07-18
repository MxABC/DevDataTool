//
//  FFTEShieldSDKCertificate.m
//  eCardDemo
//
//  Created by lbxia on 16/9/9.
//  Copyright © 2016年 FFT. All rights reserved.
//

#import "LBXCertificate.h"
#import <openssl/pem.h>
#import <openssl/md5.h>
#import <openssl/evp.h>
#import <openssl/rsa.h>
#import <openssl/x509.h>
#import <openssl/x509v3.h>
#import <openssl/x509_vfy.h>
#import <openssl/pkcs7.h>
#import "NSData+LBXConverter.h"
#import <openssl/ec.h>
#include <stdio.h>
#include <Foundation/Foundation.h>



@implementation LBXCertificateIssuerModel
@end

#pragma mark ---对象实现
@implementation LBXCertificationModel

- (id)init
{
    if (self = [super init])
    {
        self.hexSerialNumber = @"";
        self.bigNumSerialNumber = @"";
        self.cerVersion = @"";
//        self.publisherInfo = @"";
//        self.whoHave = @"";
        self.enableCerFrom = @"";
        self.disableCerTo = @"";
        self.publicKey = @"";
        self.fingerprint_MD5 = @"";
        self.fingerprint_SHA1 = @"";
    }
    return  self;
}
@end


@interface LBXCertificate()

//X509证书结构体，保存证书
@property (nonatomic, assign)  X509 *cert_X509;

//公钥-EVP
@property (nonatomic, assign) EVP_PKEY *pubKey_EVP;
//公钥-RSA
@property (nonatomic, assign) RSA *pubKey_RSA;

@end

@implementation LBXCertificate


+ (instancetype)sharedManager
{
    static LBXCertificate* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LBXCertificate alloc] init];
        
    });
    
    return _sharedInstance;
}

+ (void)test
{
    NSData *publicData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Certificate.bundle/root" ofType:@"cer"]];
//    NSData *privateData =  [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Certificate.bundle/private_key1" ofType:@"p12"]];
//    NSString *pwd = @"123456";
    
//    [[LBXCertificate sharedManager]loadCerData:publicData];
    
    NSString *sm2hexString = @"30820237308201DBA003020102020600E49AE190C4300C06082A811CCF550183750500303E310B300906035504061302434E31133011060355040A0C0A4E5859534D3254455354311A301806035504030C114E5859534D3243414348494C4454455354301E170D3137303531383037313130335A170D3232303431333038323230345A3051310B300906035504061302636E3110300E060355040A0C076E78797465737431123010060355040B0C09437573746F6D657273311C301A06035504030C13303633403833333339313030303030303030313059301306072A8648CE3D020106082A811CCF5501822D0342000450DE241AE4FDD5FB8DEF3866DFFD8A33B6F0B8452A129B1EDC0C43B35A15AFFC54606FC33C68A7CEF8AAE05B6CD6661970AFF79DEFC85657FD944E9847967544A381AF3081AC301F0603551D230418301680149EC74479206FED304A2A1D5C7F09C71A6400686430090603551D130402300030520603551D1F044B30493047A045A043A441303F310D300B06035504030C0463726C34310C300A060355040B0C0363726C31133011060355040A0C0A4E5859534D3254455354310B300906035504061302434E300B0603551D0F040403020780301D0603551D0E04160414BD7350586966FDAEC6D2F6C2019269144541D7CA300C06082A811CCF5501837505000348003045022030734AFFDC0BC0999B462B2FAEC6CC122F063E8F0B8E4C9B097C2F340F373F5A022100CAE635F400E530A4C3F0A368DFAAF58403B90C4D49D779BFDFEC1A7B287C04D4";
    

    [[LBXCertificate sharedManager]loadCerHexString:sm2hexString];
    
    
    
    
    [[LBXCertificate sharedManager]certificationWhoHave];
    
    [[LBXCertificate sharedManager]certificationIssuerInfo];
}

- (BOOL)loadCerHexString:(NSString*)hexString
{
    
    //X509证书结构体，保存证书
    NSData *dataCer = [[self class]hexString2Data:hexString];
    
    return [self loadCerData:dataCer];
}

- (void)logInfo
{
    //公钥加密算法类型
    if (EVP_PKEY_RSA == _pubKey_EVP->type)
    {
        NSLog(@"CERT_KEY_ALG_RSA");
    }
    else if (EVP_PKEY_EC == _pubKey_EVP->type)
    {
        NSLog(@"CERT_KEY_ALG_ECC");
    }
    else if (EVP_PKEY_DSA == _pubKey_EVP->type)
    {
        NSLog(@"CERT_KEY_ALG_DSA");
    }
    else if (EVP_PKEY_DH == _pubKey_EVP->type)
    {
        NSLog(@"CERT_KEY_ALG_DH");
    }
    else
    {
        NSLog(@"CERT_KEY_ALG_UNKNOWN");
    }
    

    
    //签名算法 OID
    //#define CERT_SIGNATURE_ALG_RSA_RSA          "1.2.840.113549.1.1.1"
    //#define CERT_SIGNATURE_ALG_MD2RSA           "1.2.840.113549.1.1.2"
    //#define CERT_SIGNATURE_ALG_MD4RSA           "1.2.840.113549.1.1.3"
    //#define CERT_SIGNATURE_ALG_MD5RSA           "1.2.840.113549.1.1.4"
    //#define CERT_SIGNATURE_ALG_SHA1RSA          "1.2.840.113549.1.1.5"
    //#define CERT_SIGNATURE_ALG_SM3SM2           "1.2.156.10197.1.501"
    //
    
    //签名算法
    char oid[128] = {0};
    ASN1_OBJECT* salg  = _cert_X509->sig_alg->algorithm;
    OBJ_obj2txt(oid, 128, salg, 1);
    NSString *str = [NSString stringWithUTF8String:oid];
    NSLog(@"oid:%@",str);

}

/**
 *  加载证书
 *
 *  @param data 证书数据
 *
 *  @return 返回加载成功或失败
 */
- (BOOL)loadCerData:(NSData*)data
{
    if (!data) {
        return NO;
    }
    
    [self releaseCer];
    
    
    //证书数据
    const unsigned char *pTmp = [data bytes];
    
    //证书长度
    unsigned long usrCertificateLen = [data length];
    
    // 判断是否为DER格式的数字证书
    _cert_X509 = d2i_X509(NULL,&pTmp,usrCertificateLen);
    

    if (!_cert_X509) {
    
        NSLog(@"证书加载失败");
        return NO;
    }
    
    
    //获取公钥
    _pubKey_EVP = X509_get_pubkey(_cert_X509);

    if (_pubKey_EVP) {
     
        _pubKey_RSA = EVP_PKEY_get1_RSA(_pubKey_EVP);

        [self logInfo];

    }

    
    return YES;
}

//释放相关资源
- (void)releaseCer
{
    if (_pubKey_EVP)
    {
        EVP_PKEY_free(_pubKey_EVP);
        _pubKey_EVP = NULL;
    }
    
    if (_pubKey_RSA)
    {
        RSA_free(_pubKey_RSA);
        _pubKey_RSA = NULL;
    }
    
    if (_cert_X509)
    {
        X509_free(_cert_X509);
        _cert_X509 = NULL;
    }
    
    if (_cerInfoModel) {
        
        self.cerInfoModel = nil;
    }
}


#pragma mark --公钥加密

- (BOOL)evp_public_encrypt:(NSData*)plainData result:(NSData**)enData
{
    
    Byte* result = NULL;/*加密结果*/
    unsigned int cOut = 0;/*加密结果大小*/
    const Byte* plain = plainData.bytes;/*明文*/
    unsigned int cIn = (unsigned int)plainData.length;/*明文大小*/
    
    OpenSSL_add_all_algorithms();
    bool hasErr = true;
    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new(_pubKey_EVP,NULL);
    if(!ctx)
        goto err;
    if(EVP_PKEY_encrypt_init(ctx)<=0)
        goto err;
    if (EVP_PKEY_CTX_set_rsa_padding(ctx, RSA_PKCS1_PADDING) <= 0)//设置补齐方式
        goto err;
    
    if( EVP_PKEY_encrypt( ctx,NULL,(size_t*)&cOut,plain,cIn) <= 0 )//得到加密的长度,一般都是跟密钥一样长,1024位的RSA密钥就是128字节
        goto err;
    result =(Byte*) OPENSSL_malloc(cOut);
    if(!result)
        goto err;
    
    if(EVP_PKEY_encrypt(ctx,result,(size_t*)&cOut,plain,cIn)<=0)//得到加密结果
        goto err;
    //    cout << "加密成功!" << endl;
    hasErr = false;
err:
    EVP_PKEY_CTX_free(ctx);
    
    if (!hasErr) {
        
        if (result) {
            OPENSSL_free(result);
        }
        return NO;
    }
    
    *enData = [NSData dataWithBytes:result length:cOut];
    OPENSSL_free(result);
    
    
    return YES;
}

#pragma mark --公钥解密

- (int)rsa_public_decrypt:(NSData*)enData deData:(NSData**)deData
{
    int out_len =  RSA_size(_pubKey_RSA);
    unsigned char *outData =  (unsigned char *)malloc(out_len);
    if(NULL == outData)
    {
        printf("pubkey_decrypt:malloc error!\n");
        return -1;
    }
    memset((void *)outData, 0, out_len);
    
    printf("pubkey_decrypt:Begin RSA_public_decrypt ...\n");
    int ret =  RSA_public_decrypt((int)enData.length, enData.bytes, outData, _pubKey_RSA, RSA_PKCS1_PADDING);
    
    if (ret > 0 ) {
        
        *deData = [NSData dataWithBytes:outData length:ret];
    }
    
    free(outData);
    outData = NULL;
    
    return ret;
}


#pragma mark --验证签名

- (void)testCheckSign
{
    NSString *strSouce = @"32303136303930383030313431363232323838383838383838383838383130302E3039";
    
    NSString *hexSign = @"210588947862378486712049B4671A0F4E76356729F4D7726A2A770F50365CD59FB8208C27DA71848247FBC66DE10432F598BBB41F29C2B7D8ECA273EC4615A1008787BC2F41DFFFF29FF9C1D594E55994962C3C755D96C89AA0F5CF8272453771D50A2AE67CEEBB46EB05B237EE97C2164F2BD1E356B4D1B56F2A5856EC3F51";

    BOOL isSignedCorrect =  [self rsa_check_sign:strSouce signString:hexSign];
    
    if (isSignedCorrect) {
        NSLog(@"签名验证通过");
    }
    else
    {
        NSLog(@"签名验证失败");
    }
}


#pragma mark --验证签名

//7．签名函数
//int RSA_sign(int type, unsigned char *m, unsigned int m_len,
//             
//             unsigned char *sigret, unsigned int *siglen, RSA *rsa);
//

//下面函数测试也是失败...，奇怪
//int RSA_verify(int type, unsigned char *m, unsigned int m_len,
//               
//               unsigned char *sigbuf, unsigned int siglen, RSA *rsa);

- (BOOL)rsa_check_sign:(NSString*)srcString signString:(NSString*)signString
{
//    对了，你验签的时候记得计算sha1后，前面加上"3021300906052B0E03021A05000414"这15个字节
//    
//    再去比对解密出来的数据，这个是陈丁炫那边的协议，我们统一下。
    
//    NSString *str = [NSString stringWithFormat:@"3021300906052B0E03021A05000414%@",signString];
    
    NSLog(@"signString:%@",signString);
    
    NSData *signData =  [[self class]hexString2Data:signString];
    
    //解密签名->摘要
    NSData *deData = nil;//接收解密后的数据
    int ret = [self rsa_public_decrypt:signData deData:&deData];
    NSLog(@"decrypt len:%d",ret);
    
    if (ret < 0)
    {
        return NO;
    }
    
    NSData *dataIbuf = [[self class]hexString2Data:srcString];
    
    unsigned char obuf[20];
    SHA1(dataIbuf.bytes, dataIbuf.length, obuf);
    NSString *strSHA = [[self class]hexString:[NSData dataWithBytes:obuf length:20]];
    NSLog(@"SHA1:%@",strSHA);
    
    strSHA = [NSString stringWithFormat:@"3021300906052B0E03021A05000414%@",strSHA];
    
    
    NSString* strSHA2 = deData.hexString;
    
    NSLog(@"strSHA2:%@",strSHA2);
    
    if ([strSHA isEqualToString:strSHA2])
    {
        return YES;
    }
    
    return NO;
}


+ (NSString*)SHA1:(NSString*)src
{
    
    
    NSData *dataIbuf =   [[self class]hexString2Data:src];
//    dataIbuf =  [[self class]hexString2Data:srcString];
    
//    NSData *dataIbuf =   [src dataUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char obuf[20];
    SHA1(dataIbuf.bytes, dataIbuf.length, obuf);
    NSString *strSHA = [[self class]hexString:[NSData dataWithBytes:obuf length:20]];
    NSLog(@"SHA1:%@",strSHA);
    
    return strSHA;
}





#pragma mark ---获取证书相关信息


//获取颁发者信息
- (NSString*)getPublisherInfo
{
    //获取证书颁发者信息，X509_NAME结构体保存了多项信息，包括国家、组织、部门、通用名、mail等。
    
    //X509_NAME结构体，保存证书颁发者信息
    //获取证书颁发者信息，X509_NAME结构体保存了多项信息，包括国家、组织、部门、通用名、mail等。
    X509_NAME *issuer = X509_get_issuer_name(_cert_X509);
    
    X509_NAME_ENTRY *name_entry;
    
    int entriesNum = sk_X509_NAME_ENTRY_num(issuer->entries);            //获取X509_NAME条目个数
    
    long Nid;
    
    char msginfo[1024];
    
    NSUInteger msginfoLen;
    
//    NSMutableString *certInfo = [[NSMutableString alloc]init];
    
    //X509_NAME结构体，保存证书拥有者信息
    X509_NAME *subject  = X509_get_subject_name(_cert_X509);            //获取证书主题信息
    
    NSMutableString *subjectstring = [[NSMutableString alloc]init];
    
    
    
    int countsubject = X509_NAME_entry_count(subject);
    
    NSLog(@"countsubject:%d",countsubject);
    
    X509_NAME_ENTRY  *subjectEntry = X509_NAME_get_entry(subject,2);
    
    X509_NAME_ENTRY_get_object(subjectEntry);
    
    X509_NAME_ENTRY_get_data(subjectEntry);
    
    
    NSString  *subjectstr = @"";
    
    if (subjectEntry && X509_NAME_ENTRY_get_data(subjectEntry)->data) {
        subjectstr = [NSString stringWithUTF8String:(char*)X509_NAME_ENTRY_get_data(subjectEntry)->data];
    }

    
    NSLog(@"final test %@",subjectstr);
    
    entriesNum = sk_X509_NAME_ENTRY_num(subject->entries);
    
    //循环读取个条目信息
    
    for(int i=0;i<entriesNum;i++)
    {
        
        //获取第I个条目值
        
        name_entry = sk_X509_NAME_ENTRY_value(subject->entries,i);
        
        Nid = OBJ_obj2nid(name_entry->object);
        
        //判断条目编码的类型
        
        NSLog(@" type is  %d",name_entry->value->type);
        
        NSString *tempstr;
        
        if(name_entry->value->type==V_ASN1_BMPSTRING)//把UTF8编码数据转化成可见字符
        {
            
            //ASN1_STRING_to_UTF8(mesre,name_entry->value);
            
            msginfoLen=name_entry->value->length;
            
            memcpy(msginfo,name_entry->value->data,msginfoLen);
            
            msginfo[msginfoLen]='\0';
            
            NSString *temptring = [NSString stringWithFormat:@"C=%s,",msginfo];
            
            //tempstr = [self EncodeUTF8Str:temptring];
            
            //            msginfoLen =UTF8_getc(name_entry->value->data, 2*name_entry->value->length, &rv);
            
            //            //msginfoLen =UTF8_putc(name_entry->value->data, name_entry->value->length, rv);
            
            //            //memcpy(msginfo,name_entry->value->data,msginfoLen);
            
            //            msginfo[msginfoLen]='\0';
            
            //            NSData *tempdata = [temptring dataUsingEncoding:NSUTF8StringEncoding];
            
            //            NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            
            //            NSString*pageSource = [[NSString alloc] initWithData:tempdata encoding:gbkEncoding];
            
            //            NSString*pageSource = [self encodeToPercentEscapeString:temptring];
            
            //            NSString *dataGBK = [pageSource stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            tempstr = temptring;
            
            
        }
        else
        {
            
            tempstr = [NSString stringWithFormat:@"C=%s,",msginfo];
            
            msginfoLen=name_entry->value->length;
            
            memcpy(msginfo,name_entry->value->data,msginfoLen);
            
            msginfo[msginfoLen]='\0';
            
        }
        
        switch(Nid)
        {
                
            case NID_countryName://国家C
            {
                //printf("issuer 's L:%s\n",msginfo);
                
                NSString *str = [NSString stringWithUTF8String:msginfo];
                
                str = [NSString stringWithFormat:@"C=%@,",str];
                
                [subjectstring appendString:str];
            }
                break;
            case NID_stateOrProvinceName://省ST
            {
                //printf("issuer 's L:%s\n",msginfo);
                
                NSString *str = [NSString stringWithUTF8String:msginfo];
                
                str = [NSString stringWithFormat:@"ST=%@,",str];
                
                [subjectstring appendString:str];
            }
                break;
                
            case NID_localityName://地区L
            {
                //printf("issuer 's L:%s\n",msginfo);
                
                NSString *str = [NSString stringWithUTF8String:msginfo];
                
               str = [NSString stringWithFormat:@"L=%@,",str];
                
                [subjectstring appendString:str];
            }
                break;
                
            case NID_organizationName://组织O
            {
                NSString *str = [NSString stringWithUTF8String:msginfo];
                str = [NSString stringWithFormat:@"O=%@,",str];
                
                [subjectstring appendString:str];
            }
                break;
                
            case NID_organizationalUnitName://单位OU
            {
                NSString *str = [NSString stringWithUTF8String:msginfo];
                str = [NSString stringWithFormat:@"OU=%@,",str];
                
                [subjectstring appendString:str];
            }
                break;
                
            case NID_commonName://通用名CNx
            {
                NSString *str = [NSString stringWithUTF8String:msginfo];
                str = [NSString stringWithFormat:@"CN=%@,",str];
                
                [subjectstring appendString:str];
            }
                break;
                
            case NID_pkcs9_emailAddress://Mail
                
                //printf("issuer 's emailAddress:%s\n",msginfo);
                
                break;
                
        }//end switch
        
    }
    
    return subjectstring;
}

#pragma mark --- 版本号
- (NSString*)getCerVersion
{
    int version = ((int) X509_get_version(_cert_X509)) + 1;
    
    return [NSString stringWithFormat:@"%d",version];
}

#pragma mark ---获取序列号
- (NSString*)getSerialNumber
{
    ASN1_INTEGER *serialNumber = _cert_X509->cert_info->serialNumber;
    
//    BIGNUM *bignum = ASN1_INTEGER_to_BN(serialNumber, NULL);
//    
//    char *pDec =  BN_bn2dec(bignum);//转化为10进制字符串
//    
//    NSString *strDec = [NSString stringWithUTF8String:pDec];
    
    NSData *dataSerialNo = [NSData dataWithBytes:serialNumber->data length:serialNumber->length];
    
    NSString *hexString = [[self class] hexString:dataSerialNo];
    
    return hexString;
}

#pragma mark --获取证书序列号并转换为10进制大数字符串
- (NSString*)getSerialBigNum
{
    ASN1_INTEGER *serialNumber = _cert_X509->cert_info->serialNumber;
    
    BIGNUM *bignum = ASN1_INTEGER_to_BN(serialNumber, NULL);
    
    char *pDec =  BN_bn2dec(bignum);//转化为10进制字符串
    
//    BN_dec2bn(<#BIGNUM **a#>, <#const char *str#>)
    
    NSString *strDec = [NSString stringWithUTF8String:pDec];
    
    OPENSSL_free(pDec);
    
    BN_free(bignum);
    
    return strDec;
}


#pragma mark ---获取证书有效时间
- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息，默认GMT时间,。
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    //显示的时间和手机时间一致。
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    return destDateString;
    
}



//开始日期
- (NSDate*) certificateGetStartDate
{
    NSDate *expiryDate = nil;
    
    if (_cert_X509 != NULL) {
        ASN1_TIME *certificateExpiryASN1 = X509_get_notBefore(_cert_X509);
        if (certificateExpiryASN1 != NULL) {
            ASN1_GENERALIZEDTIME *certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime(certificateExpiryASN1, NULL);
            
            
            //            ASN1_TIME *certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime(certificateExpiryASN1, NULL);
            
            
            if (certificateExpiryASN1Generalized != NULL) {
                unsigned char *certificateExpiryData = ASN1_STRING_data(certificateExpiryASN1Generalized);
                
                // ASN1 generalized times look like this: "20131114230046Z"
                //                                format:  YYYYMMDDHHMMSS
                //                               indices:  01234567890123
                //                                                   1111
                // There are other formats (e.g. specifying partial seconds or
                // time zones) but this is good enough for our purposes since
                // we only use the date and not the time.
                //
                // (Source: http://www.obj-sys.com/asn1tutorial/node14.html)
                
                NSString *expiryTimeStr = [NSString stringWithUTF8String:(char *)certificateExpiryData];
                NSDateComponents *expiryDateComponents = [[NSDateComponents alloc] init];
                
                expiryDateComponents.year   = [[expiryTimeStr substringWithRange:NSMakeRange(0, 4)] intValue];
                expiryDateComponents.month  = [[expiryTimeStr substringWithRange:NSMakeRange(4, 2)] intValue];
                expiryDateComponents.day    = [[expiryTimeStr substringWithRange:NSMakeRange(6, 2)] intValue];
                expiryDateComponents.hour   = [[expiryTimeStr substringWithRange:NSMakeRange(8, 2)] intValue];
                expiryDateComponents.minute = [[expiryTimeStr substringWithRange:NSMakeRange(10, 2)] intValue];
                expiryDateComponents.second = [[expiryTimeStr substringWithRange:NSMakeRange(12, 2)] intValue];
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                expiryDate = [calendar dateFromComponents:expiryDateComponents];
                
                
            }
        }
    }
    
    
    return expiryDate;
}

//截止日期
- (NSDate*) certificateGetExpiryDate
{
    NSDate *expiryDate = nil;
    
    if (_cert_X509 != NULL) {
        ASN1_TIME *certificateExpiryASN1 = X509_get_notAfter(_cert_X509);
        if (certificateExpiryASN1 != NULL) {
            ASN1_GENERALIZEDTIME *certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime(certificateExpiryASN1, NULL);
            
            
            //            ASN1_TIME *certificateExpiryASN1Generalized = ASN1_TIME_to_generalizedtime(certificateExpiryASN1, NULL);
            
            
            if (certificateExpiryASN1Generalized != NULL) {
                unsigned char *certificateExpiryData = ASN1_STRING_data(certificateExpiryASN1Generalized);
                
                // ASN1 generalized times look like this: "20131114230046Z"
                //                                format:  YYYYMMDDHHMMSS
                //                               indices:  01234567890123
                //                                                   1111
                // There are other formats (e.g. specifying partial seconds or
                // time zones) but this is good enough for our purposes since
                // we only use the date and not the time.
                //
                // (Source: http://www.obj-sys.com/asn1tutorial/node14.html)
                
                NSString *expiryTimeStr = [NSString stringWithUTF8String:(char *)certificateExpiryData];
                NSDateComponents *expiryDateComponents = [[NSDateComponents alloc] init];
                
                expiryDateComponents.year   = [[expiryTimeStr substringWithRange:NSMakeRange(0, 4)] intValue];
                expiryDateComponents.month  = [[expiryTimeStr substringWithRange:NSMakeRange(4, 2)] intValue];
                expiryDateComponents.day    = [[expiryTimeStr substringWithRange:NSMakeRange(6, 2)] intValue];
                expiryDateComponents.hour   = [[expiryTimeStr substringWithRange:NSMakeRange(8, 2)] intValue];
                expiryDateComponents.minute = [[expiryTimeStr substringWithRange:NSMakeRange(10, 2)] intValue];
                expiryDateComponents.second = [[expiryTimeStr substringWithRange:NSMakeRange(12, 2)] intValue];
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                expiryDate = [calendar dateFromComponents:expiryDateComponents];
                
                
            }
        }
    }
    
    
    return expiryDate;
}


//获取开始日期
- (NSString*)getStartValidateDate
{
    NSDate *date = [self certificateGetStartDate];
 
    //转换成当地时间
    date = [self getNowDateFromatAnDate:date];
    
    return [self stringFromDate:date];
}


//获取有效期结束时间
- (NSString*)getEndValidateDate
{
//    //证书有效期时间
//    ASN1_TIME *time = X509_get_notBefore(_cert_X509);
//
//    
//    NSString *notAfter = [NSString stringWithFormat:@"%s",time->data];
//    return notAfter;
    
    NSDate *date = [self certificateGetExpiryDate];
    
    date = [self getNowDateFromatAnDate:date];
//    date = [self getNowDateFromatAnDate:date];
    
    return [self stringFromDate:date];
}

#pragma mark---获取指纹(摘要)




#pragma mark ---获取公钥信息

- (NSString*)getCerPublicKeyInfo
{
    //保存证书公钥
//    EVP_PKEY *pubKey = _pubKey_EVP;
    
    if (!_pubKey_EVP) {
        
        X509_PUBKEY *key =  _cert_X509->cert_info->key;
        
        ASN1_BIT_STRING *public_key = key->public_key;
        
        unsigned char *pBytes = public_key->data;
        
        NSData *publicKeyData = [NSData dataWithBytes:pBytes+1 length:public_key->length-1];
        
        return publicKeyData.hexString;
    }

    
    
    RSA *rsa = _pubKey_RSA;
    
    if (rsa->bignum_data)
    {
        NSString *str = [NSString stringWithUTF8String:rsa->bignum_data];
        
        NSLog(@"%@",str);
    }
    
    
    //公钥数据
    char *pHex = BN_bn2hex(rsa->n);
    
    NSString *strPub = [NSString stringWithUTF8String:pHex];
    
    NSLog(@"%@",strPub);
    
    OPENSSL_free(pHex);
    
    //指数
    char *pDec = BN_bn2dec(rsa->e);
    
     NSLog(@"%@",[NSString stringWithUTF8String:pDec]);
    
    OPENSSL_free(pDec);
    
    return strPub;
    
//
//    
////    char *BN_bn2hex(const BIGNUM *a);
//    
//    if (EVP_PKEY_RSA == pubKey->type)
//    {
////        *pulType = CERT_KEY_ALG_RSA;
//    }
//    else if (EVP_PKEY_EC == pubKey->type)
//    {
////        *pulType = CERT_KEY_ALG_ECC;
//    }
//    else if (EVP_PKEY_DSA == pubKey->type)
//    {
////        *pulType = CERT_KEY_ALG_DSA;
//    }
//    else if (EVP_PKEY_DH == pubKey->type)
//    {
////        *pulType = CERT_KEY_ALG_DH;
//    }
//    else
//    {
////        return CERT_KEY_ALG_UNKNOWN;
//    }
//
//    
//    return str;
}



#pragma mark ---签名
void sign(EVP_PKEY* evpKey,Byte** signValue,unsigned int *signLen,Byte* text,int textLen)
{
    EVP_MD_CTX mdctx;   //摘要算法上下文变量
    
    if(evpKey == NULL)
    {
        printf("EVP_PKEY_new err\n");
        return;
    }
    
    //以下是计算签名的代码
    EVP_MD_CTX_init(&mdctx);        //初始化摘要上下文
    if(!EVP_SignInit_ex(&mdctx,EVP_md5(),NULL)) //签名初始化，设置摘要算法
    {
        printf("err\n");
        EVP_PKEY_free(evpKey);
        return;
    }
    if(!EVP_SignUpdate(&mdctx,text,textLen)) //计算签名（摘要）Update
    {
        printf("err\n");
        EVP_PKEY_free(evpKey);
        return;
    }
    
    unsigned char signValue1[6048];
    
    if(!EVP_SignFinal(&mdctx,signValue1,signLen,evpKey))  //签名输出
    {
        printf("err\n");
        EVP_PKEY_free(evpKey);
        return;
    }
    printf("消息\"%s\"的签名值是：\n",text);
//    printByte(*signValue,signLen);
    printf("\n");
    EVP_MD_CTX_cleanup(&mdctx);
    
}





- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间,仍然是UTC时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

/**
 *  获取证书相关信息
*
 *  @return 返回证书解析后的信息
 */
- (LBXCertificationModel*)certficationBaseInfo
{
    LBXCertificationModel *model = [[LBXCertificationModel alloc]init];
    model.hexSerialNumber = [self getSerialNumber];
    model.bigNumSerialNumber = [self getSerialBigNum];
    model.cerVersion = [self getCerVersion];
    model.enableCerFrom = [self getStartValidateDate];
    model.disableCerTo = [self getEndValidateDate];
    model.publicKey = [self getCerPublicKeyInfo];

    model.signature = [self signatureValue];
    
    int nid = OBJ_obj2nid(_cert_X509->sig_alg->algorithm);
    
    if (nid == NID_sha1WithRSAEncryption) {
        
        //签名算法，RSA加密的SHA1摘要
        model.signAlgorithm = [NSString stringWithUTF8String:SN_sha1WithRSAEncryption];
    }
    
    switch (nid)
    {
        case NID_md5WithRSAEncryption:
        {
            model.signAlgorithm = [NSString stringWithUTF8String:SN_md5WithRSAEncryption];
        }
            break;
        case NID_sha1WithRSAEncryption:
        {
            //签名算法，RSA加密的SHA1摘要
            model.signAlgorithm = [NSString stringWithUTF8String:SN_sha1WithRSAEncryption];
        }
            break;
        case NID_sha256WithRSAEncryption:
        {
            model.signAlgorithm = [NSString stringWithUTF8String:SN_sha256WithRSAEncryption];
        }
            break;
        case NID_sha512WithRSAEncryption:
        {
            model.signAlgorithm = [NSString stringWithUTF8String:SN_sha512WithRSAEncryption];
        }
            break;
        default:
            break;
    }
    
    //签名算法 OID
#define CERT_SIGNATURE_ALG_RSA_RSA          @"1.2.840.113549.1.1.1"
#define CERT_SIGNATURE_ALG_MD2RSA           @"1.2.840.113549.1.1.2"
#define CERT_SIGNATURE_ALG_MD4RSA           @"1.2.840.113549.1.1.3"
#define CERT_SIGNATURE_ALG_MD5RSA           @"1.2.840.113549.1.1.4"
#define CERT_SIGNATURE_ALG_SHA1RSA          @"1.2.840.113549.1.1.5"
#define CERT_SIGNATURE_ALG_SM3SM2           @"1.2.156.10197.1.501"

    
    if (model.signAlgorithm) {
        
        model.signAlgorithm = [NSString stringWithFormat:@"%@(%@)",model.signAlgorithm,[self signAlgorithm_oid]];
    }else{
        NSString *oid = [self signAlgorithm_oid];
        
        if ([oid isEqualToString:CERT_SIGNATURE_ALG_SM3SM2]) {
            
            model.signAlgorithm = [NSString stringWithFormat:@"SM2-SM3(%@)",oid];
        }else{
            model.signAlgorithm = [NSString stringWithFormat:@"oid:%@",oid];
        }
    }
    
    model.keyUsage = [self keyUsage];
    
    self.cerInfoModel = model;

    return  model;
}

- (NSString*)signatureValue
{
    //    X509_ALGOR *signature = _cert_X509->cert_info->signature;
    
    ASN1_BIT_STRING *signatureValue = _cert_X509->signature;
    
    
    
    unsigned char *pBytes = signatureValue->data;
    
    NSData *signatureData = [NSData dataWithBytes:pBytes length:signatureValue->length];
    
    NSLog(@"signature:%@",signatureData.hexString);
    
    return signatureData.hexString;
    
    //    return nil;
}



/**
 密钥用途

 @return purpose
 */
- (NSString*)keyUsage
{
    //证书类型，加密证书还是验证签名证书
    //must be called
    int ret = X509_check_ca(_cert_X509);
//    if (ret == 0)
    NSLog(@"check_ca:%d",ret);
    
    NSString *keyUsage = @"";
    
    unsigned long lKeyUsage = _cert_X509->ex_kusage;
    if ((lKeyUsage & KU_DATA_ENCIPHERMENT) == KU_DATA_ENCIPHERMENT)
    {
        keyUsage = @"加密证书";
    }
    else if ((lKeyUsage & KU_DIGITAL_SIGNATURE) == KU_DIGITAL_SIGNATURE)
    {
        keyUsage = @"验证签名证书";
    }
    else
    {
        keyUsage = @"加密或验证签名证书";
    }
    
    return keyUsage;
}

- (NSString*)signAlgorithm_oid
{
    //签名算法
    char oid[128] = {0};
    ASN1_OBJECT* salg  = _cert_X509->sig_alg->algorithm;
    OBJ_obj2txt(oid, 128, salg, 1);
    NSString *strOID = [NSString stringWithUTF8String:oid];
    NSLog(@"oid:%@",strOID); //sm2 :1.2.156.10197.1.501

    return strOID;
}

/**
 获取签名者信息
 
 @return 返回信息
 */
- (LBXCertificateIssuerModel*)certificationIssuerInfo
{
    //X509_NAME结构体，保存证书颁发者信息
    //获取证书颁发者信息，X509_NAME结构体保存了多项信息，包括国家、组织、部门、通用名、mail等。
    
    //读取签名者信息
    X509_NAME *issuer = X509_get_issuer_name(_cert_X509);
    
    return [self certificationIssuerOrSubjectInfo:issuer];
}

- (LBXCertificateIssuerModel*)certificationSubjectInfo
{
    //X509_NAME结构体，保存证书颁发者信息
    //获取证书颁发者信息，X509_NAME结构体保存了多项信息，包括国家、组织、部门、通用名、mail等。
    
    //读取主题信息
    X509_NAME *issuer = X509_get_subject_name(_cert_X509);
    
    return [self certificationIssuerOrSubjectInfo:issuer];
}


/**
 持有者信息(使用者)
 
 @return 返回信息
 */
- (LBXCertificateIssuerModel*)certificationWhoHave
{
    X509_NAME *name = _cert_X509->cert_info->subject;
    
    return [self certificationUserInfo:name];
}

- (LBXCertificateIssuerModel*)certificationIssuerOrSubjectInfo:(X509_NAME*)issuer
{
    LBXCertificateIssuerModel *cerIssuer = [[LBXCertificateIssuerModel alloc]init];
    
    long Nid;
    char msginfo[128]={0};
    NSUInteger msginfoLen = 0;
    
    int entriesNum = sk_X509_NAME_ENTRY_num(issuer->entries);            //获取X509_NAME条目个数
    //循环读取个条目信息
    for(int i=0;i<entriesNum;i++)
    {
        //获取第I个条目值
        X509_NAME_ENTRY *name_entry = sk_X509_NAME_ENTRY_value(issuer->entries,i);
        Nid = OBJ_obj2nid(name_entry->object);
        
        //判断条目编码的类型
        //      UKey_Log(@" type is  %d",name_entry->value->type);
        if(name_entry->value->type == V_ASN1_BMPSTRING)//把UTF8编码数据转化成可见字符
        {
            msginfoLen=name_entry->value->length;
            memcpy(msginfo,name_entry->value->data,msginfoLen);
            msginfo[msginfoLen]='\0';
        }
        else
        {
            msginfoLen=name_entry->value->length;
            memcpy(msginfo,name_entry->value->data,msginfoLen);
            msginfo[msginfoLen]='\0';
        }
        
        switch(Nid)
        {
            case NID_countryName:
            {
                //国家C，如CN
                cerIssuer.country = [NSString stringWithUTF8String:msginfo];
            }
                break;
            case NID_stateOrProvinceName:
            {
                //省份
                cerIssuer.province = [NSString stringWithUTF8String:msginfo];
            }
                break;
            case NID_localityName:
            {
                //所在地
                cerIssuer.localPlace = [NSString stringWithUTF8String:msginfo];
            }
                break;

            case NID_organizationName:
            {
                //组织O
                cerIssuer.organization = [NSString stringWithUTF8String:msginfo];
            }
                break;
            case NID_organizationalUnitName:
            {
                //组织单位
                cerIssuer.organizationUnit = [NSString stringWithUTF8String:msginfo];
            }
                break;
            case NID_commonName://通用名CNx
            {
                cerIssuer.commonName = [NSString stringWithUTF8String:msginfo];
            }
                break;
            case NID_serialNumber:
            {
                cerIssuer.serialNumber = [NSString stringWithUTF8String:msginfo];
            }
            case NID_pkcs9_emailAddress:
            {
//                NSLog(@"info:%@",[NSString stringWithUTF8String:msginfo]);
                cerIssuer.email = [NSString stringWithUTF8String:msginfo];
            }
                break;
        }//end switch
        
    }
    
//    NSString *whoHave = [self whoHaveCer];
    
    
    return cerIssuer;
}


//持有者(使用者)信息
- (LBXCertificateIssuerModel*)certificationUserInfo:(X509_NAME*)name
{
    
    
    LBXCertificateIssuerModel *cerIssuer = [[LBXCertificateIssuerModel alloc]init];
    
    

    char buf[256]={0};
    int iLen = X509_NAME_get_text_by_NID(name, NID_countryName, buf, 256);
    if (iLen > 0)
    {
        cerIssuer.country = [NSString stringWithUTF8String:buf];
    }
    
    
//        case NID_countryName:
//        case NID_stateOrProvinceName:
//        case NID_localityName:
//        case NID_organizationName:
//        case NID_organizationalUnitName:
//        case NID_commonName://通用名CNx
//        case NID_serialNumber:
//        case NID_pkcs9_emailAddress:
//       

    memset(buf, 0, 256);
    iLen = X509_NAME_get_text_by_NID(name, NID_stateOrProvinceName, buf, 256);
    if (iLen > 0)
    {
        cerIssuer.province = [NSString stringWithUTF8String:buf];
    }
    
    memset(buf, 0, 256);
    iLen = X509_NAME_get_text_by_NID(name, NID_localityName, buf, 256);
    if (iLen > 0)
    {
        cerIssuer.localPlace = [NSString stringWithUTF8String:buf];
    }
    
    memset(buf, 0, 256);
    iLen = X509_NAME_get_text_by_NID(name, NID_organizationName, buf, 256);
    if (iLen > 0)
    {
        cerIssuer.organization = [NSString stringWithUTF8String:buf];
    }
    
    memset(buf, 0, 256);
    iLen = X509_NAME_get_text_by_NID(name, NID_organizationalUnitName, buf, 256);
    if (iLen > 0)
    {
        cerIssuer.organizationUnit = [NSString stringWithUTF8String:buf];
    }

    memset(buf, 0, 256);
    iLen = X509_NAME_get_text_by_NID(name, NID_commonName, buf, 256);
    if (iLen > 0)
    {
        cerIssuer.commonName = [NSString stringWithUTF8String:buf];
    }

    memset(buf, 0, 256);
    iLen = X509_NAME_get_text_by_NID(name, NID_serialNumber, buf, 256);
    if (iLen > 0)
    {
        cerIssuer.serialNumber = [NSString stringWithUTF8String:buf];
    }

    memset(buf, 0, 256);
    iLen = X509_NAME_get_text_by_NID(name, NID_pkcs9_emailAddress, buf, 256);
    if (iLen > 0)
    {
        cerIssuer.email = [NSString stringWithUTF8String:buf];
    }

    
    return cerIssuer;
}


#pragma mark --持有者信息
- (NSString*)whoHaveCer
{
    char szOutCN[256]={0};
    X509_NAME *name = NULL;
    name = _cert_X509->cert_info->subject;
    X509_NAME_get_text_by_NID(name,NID_commonName,szOutCN,256);
    NSString *nameStr = [NSString stringWithUTF8String:szOutCN];
    NSLog(@"用户名:%@",nameStr);
    
    return nameStr;
}

/**
 *  获取cer证书序列号并转换为大数形式
 *
 *  @param strHexCer 证书字符串
 *
 *  @return 返回序列号的大数形式
 */
+ (NSString*)getCertificationSerialNumber2BigInteger:(NSString*)strHexCer
{
    //X509证书结构体，保存证书
    
//    NSString *hexString = [[self class]getCertificationSerialNumber:strHexCer];
//    
//    if (hexString) {
//        
//       return [BigIntegerConvert bigIntegerFromHexString:hexString];
//    }
    
    
    
    return nil;
}


/**
 * 数组转换成十六进制字符串
 */
+ (NSString*)hexString:(NSData*)data
{
    NSMutableString *arrayString = [[NSMutableString alloc]initWithCapacity:data.length * 2];
    int len = (int)data.length;
    unsigned char* bytes = (unsigned char*)data.bytes;
    
    for (int i = 0; i < len; i++)
    {
        unsigned char cValue = bytes[i];
        
        int iValue = cValue;
        
        iValue = iValue & 0x000000FF;
        
        NSString *str = [NSString stringWithFormat:@"%02x",iValue];
        
        [arrayString appendString:str];
    }
    
    return arrayString.uppercaseString;
}

+ (NSString*)hexString:(Byte*)data len:(int)len
{
    NSMutableString *arrayString = [[NSMutableString alloc]initWithCapacity:len * 2];
   
    unsigned char* bytes = data;
    
    for (int i = 0; i < len; i++)
    {
        unsigned char cValue = bytes[i];
        
        int iValue = cValue;
        
        iValue = iValue & 0x000000FF;
        
        NSString *str = [NSString stringWithFormat:@"%02x",iValue];
        
        [arrayString appendString:str];
    }
    
    return arrayString.uppercaseString;
}

+ (NSData*)hexString2Data:(NSString*)hexString
{
    if (!hexString) {
        return nil;
    }
    
    const char* ch = [[hexString lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
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




@end



