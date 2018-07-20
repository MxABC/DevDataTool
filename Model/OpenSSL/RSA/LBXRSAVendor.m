//
//  LBXRSAVendor.m
//  DataHandler
//
//  Created by lbxia on 2016/11/9.
//  Copyright © 2016年 lbx. All rights reserved.
//

#import "LBXRSAVendor.h"
#import "NSData+LBXConverter.h"
#import "NSString+LBXConverter.h"

@interface LBXRSAVendor()

@property (nonatomic, strong) NSString *publicKApplicationTag;
@property (nonatomic, strong) NSString *privateKApplicationTag;


@property (nonatomic,strong) NSData   *publicKeyBits;
@property (nonatomic,strong) NSData   *privateKeyBits;
@property (nonatomic,readonly) SecKeyRef publicKeyRef;
@property (nonatomic,readonly) SecKeyRef privateKeyRef;


@end

@implementation LBXRSAVendor


#if DEBUG
#define LOGGING_FACILITY(X, Y)	\
NSAssert(X, Y);

#define LOGGING_FACILITY1(X, Y, Z)	\
NSAssert1(X, Y, Z);
#else
#define LOGGING_FACILITY(X, Y)	\
if (!(X)) {			\
NSLog(Y);		\
}

#define LOGGING_FACILITY1(X, Y, Z)	\
if (!(X)) {				\
NSLog(Y, Z);		\
}
#endif

+ (instancetype)sharedManager
{
    static LBXRSAVendor * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LBXRSAVendor alloc] init];
        
        _sharedInstance.publicKApplicationTag = @"com.lbx.keychain.rsa.public";
        _sharedInstance.privateKApplicationTag = @"com.lbx.keychain.rsa.private";
        
    });
    
    return _sharedInstance;
}

+ (void)test
{
    {
        
        //代码创建
        
        [[LBXRSAVendor sharedManager]generateWithKeyLength:1024 result:^(BOOL isSuccess) {
            
            
            NSData*data = [LBXRSAVendor sharedManager].publicKeyBits;
            
            NSLog(@"publickey:%@",data.hexString);
            
            NSString *str = @"0123456701234567";
            
            //加解密
            {
                
                NSData *enData = [[LBXRSAVendor sharedManager]encryptWithData:str.utf8Data padding:kSecPaddingPKCS1 keyMode:YES];
                
                enData = [[LBXRSAVendor sharedManager]decryptWithData:enData padding:kSecPaddingPKCS1 keyMode:NO];
                
                NSLog(@"%@",enData.utf8String);
            }
            
            
            //签名验证签名
            {
                NSData *signData= [[LBXRSAVendor sharedManager]signData:str.utf8Data withPadding:kSecPaddingPKCS1];
                
                BOOL isCheck = [[LBXRSAVendor sharedManager]verifyData:str.utf8Data withSignature:signData withPadding:kSecPaddingPKCS1];
                
                NSLog(@"%d",isCheck);
            }
        }];
    }
    
    
    {
        
        //加载证书
        
        NSData *publicData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Certificate.bundle/public_key1" ofType:@"der"]];
        NSData *privateData =  [[NSData alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Certificate.bundle/private_key1" ofType:@"p12"]];
        NSString *pwd = @"123456";
        
        if ( [[LBXRSAVendor sharedManager]loadRSAPairWithPublicData:publicData privateData:privateData privatePwd:pwd] )
        {
            NSData*data = [LBXRSAVendor sharedManager].publicKeyBits;
            
            NSLog(@"publickey:%@",data.hexString);
            
            NSString *str = @"0123456701234567";
            
            //加解密
            {
                
                NSData *enData = [[LBXRSAVendor sharedManager]encryptWithData:str.utf8Data padding:kSecPaddingPKCS1 keyMode:YES];
                NSLog(@"%@",enData.utf8String);
                
                enData = [[LBXRSAVendor sharedManager]decryptWithData:enData padding:kSecPaddingPKCS1 keyMode:NO];
                
                NSLog(@"%@",enData.utf8String);
            }
            
            //签名验证签名
            {
                NSData *signData= [[LBXRSAVendor sharedManager]signData:str.utf8Data withPadding:kSecPaddingPKCS1];
                
                BOOL isCheck = [[LBXRSAVendor sharedManager]verifyData:str.utf8Data withSignature:signData withPadding:kSecPaddingPKCS1];
                
                NSLog(@"%d",isCheck);
            }
        }
        
    }
    
}

#pragma mark ---   创建公私钥对  -----


- (void)generateWithKeyLength:(NSUInteger)keyLength result:(void(^)(BOOL isSuccess))result
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL isSuccess = [self generateKeyPairRSAWithKeyLength:keyLength];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            result(isSuccess);
        });
    });
}

- (BOOL)generateKeyPairRSAWithKeyLength:(NSUInteger)keyLength
{
    if (_publicKeyRef) CFRelease(_publicKeyRef);
    if (_privateKeyRef) CFRelease(_privateKeyRef);
    
    _publicKeyRef = NULL;
    _privateKeyRef = NULL;
    
    // First delete current keys.
    [self deleteAsymmetricKeys];
    
    // Container dictionaries.
    NSMutableDictionary * privateKeyAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * publicKeyAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * keyPairAttr = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set top level dictionary for the keypair.
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:keyLength] forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    // Set the private key dictionary.
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:_privateKApplicationTag forKey:(__bridge id)kSecAttrApplicationTag];
    // See SecKey.h to set other flag values.
    
    // Set the public key dictionary.
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:_publicKApplicationTag forKey:(__bridge id)kSecAttrApplicationTag];
    // See SecKey.h to set other flag values.
    
    // Set attributes to top level dictionary.
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    
    // SecKeyGeneratePair returns the SecKeyRefs just for educational purposes.
    OSStatus ret  = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &_publicKeyRef, &_privateKeyRef);
    
    LOGGING_FACILITY( ret == noErr && _publicKeyRef != NULL && _privateKeyRef != NULL, @"Something really bad went wrong with generating the key pair." );
    
    return ret==0;
}


- (void)deleteAsymmetricKeys
{
    OSStatus sanityCheck = noErr;
    NSMutableDictionary * queryPublicKey = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * queryPrivateKey = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:_publicKApplicationTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:_privateKApplicationTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Delete the private key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing private key, OSStatus == %d.", sanityCheck );
    
    // Delete the public key.
    sanityCheck = SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Error removing public key, OSStatus == %d.", sanityCheck );
}

/*
 获得RSA公钥
 返回类型：NSData
 */
- (NSData *)publicKeyBits
{
    if (_publicKeyBits) {
        return _publicKeyBits;
    }
    
    OSStatus sanityCheck = noErr;
    CFTypeRef  _publicKeyBitsReference = NULL;
    
    NSMutableDictionary * queryPublicKey = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:_publicKApplicationTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    // Get the key bits.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&_publicKeyBitsReference);
    
    if (sanityCheck != noErr) {
        _publicKeyBitsReference = NULL;
    }
    
    NSData* d = (__bridge NSData*)_publicKeyBitsReference;
    
    _publicKeyBits = [self addASNHeaderForPublicKey:d];
    
    return _publicKeyBits;
}


- (NSData *)privateKeyBits {
    
    if (_privateKeyBits) {
        return _privateKeyBits;
    }
    
    OSStatus sanityCheck = noErr;
    CFTypeRef  _privateKeyBitsReference = NULL;
    
    NSMutableDictionary * queryPublicKey = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // Set the public key query dictionary.
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:_privateKApplicationTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnData];
    
    // Get the key bits.
    sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&_privateKeyBitsReference);
    
    if (sanityCheck != noErr) {
        _privateKeyBitsReference = NULL;
    }
    
    
    NSData* d = (__bridge NSData*)_privateKeyBitsReference;
    
    _privateKeyBits = [self addASNHeaderForPublicKey:d];
    
    return _privateKeyBits;
}


/*
 苹果API生成的RSA公钥是不带ASN.1格式头的，后台的RSA公钥是带的，在上送给后台
 前，需要加上这个格式头
 */
- (NSData*) addASNHeaderForPublicKey:(NSData*) pub_key
{
    if (!pub_key || pub_key.length == 0 ) {
        return nil;
    }
    
    unsigned char seqiodHeader[] =
    { 0x30,0x81,0x9f,0x30,0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d,0x01, 0x01,0x01, 0x05, 0x00,0x03,0x81,0x8d,0x00};
  
    
    unsigned char *c_key = (unsigned char *)[pub_key bytes];
    
    unsigned char newKey[162];
    
    memset(newKey,0,sizeof(162));
    
    int i = 0;
    for(; i < 22; ++i)
    {
        newKey[i] = seqiodHeader[i];
    }
    
    for(int j = 0; j < 140; ++j)
    {
        newKey[i] = c_key[j];
        i++;
    }
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&newKey[0] length:162]);
}


#pragma mark --- 加载证书文件 ---- 

- (BOOL)loadRSAPairWithPublicData:(NSData*)publicData privateData:(NSData*)privateData privatePwd:(NSString*)pwd
{
    if (_publicKeyRef) CFRelease(_publicKeyRef);
    if (_privateKeyRef) CFRelease(_privateKeyRef);
    
    _publicKeyRef = NULL;
    _privateKeyRef = NULL;
    
    _publicKeyRef = [self getPKRefrenceFromData:publicData];
    
    _privateKeyRef = [self getSKRefrenceFromData:privateData password:pwd];
    
    if (_publicKeyRef && _privateKeyRef) {
        return YES;
    }
    
    if (_publicKeyRef) CFRelease(_publicKeyRef);
    if (_privateKeyRef) CFRelease(_privateKeyRef);
    
    _publicKeyRef = NULL;
    _privateKeyRef = NULL;
    
    return NO;
}

- (BOOL)loadPublicData:(NSData*)publicData
{
    if (_publicKeyRef) CFRelease(_publicKeyRef);
   
    
    _publicKeyRef = NULL;
 
    
    _publicKeyRef = [self getPKRefrenceFromData:publicData];
    
   
    
    if (_publicKeyRef && _privateKeyRef) {
        return YES;
    }
    
    if (_publicKeyRef)
        CFRelease(_publicKeyRef);
   
    _publicKeyRef = NULL;

    
    return NO;
}

- (BOOL)loadWithPrivateData:(NSData*)privateData privatePwd:(NSString*)pwd
{

    if (_privateKeyRef) CFRelease(_privateKeyRef);
    _privateKeyRef = NULL;
    
    _privateKeyRef = [self getSKRefrenceFromData:privateData password:pwd];
    
    if (_privateKeyRef) {
        return YES;
    }
    
    if (_privateKeyRef) CFRelease(_privateKeyRef);
    _privateKeyRef = NULL;
    
    return NO;
}

- (SecKeyRef)getPKRefrenceFromData: (NSData*)PKData {
    
    if (!PKData) {
        return nil;
    }
    SecCertificateRef PKCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)PKData);
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    SecTrustRef myTrust;
    OSStatus status = SecTrustCreateWithCertificates(PKCertificate,myPolicy,&myTrust);
    SecTrustResultType trustResult;
    SecKeyRef tempPK = nil;
    if (status == noErr) {
        status = SecTrustEvaluate(myTrust, &trustResult);
        tempPK = SecTrustCopyPublicKey(myTrust);
    }
    
    CFRelease(PKCertificate);
    CFRelease(myPolicy);
    CFRelease(myTrust);
    
    return tempPK;
}

- (SecKeyRef)getSKRefrenceFromData: (NSData*)SKData password:(NSString*)password{
    
    if (!SKData || !password ) {
        return nil;
    }
    
    SecKeyRef tempSK = nil;
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    [options setObject: password forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)SKData, (__bridge CFDictionaryRef)options, &items);
    if (securityError == noErr && CFArrayGetCount(items) > 0) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp = (SecIdentityRef)CFDictionaryGetValue(identityDict, kSecImportItemIdentity);
        securityError = SecIdentityCopyPrivateKey(identityApp, &tempSK);
        if (securityError != noErr) {
            tempSK = nil;
        }
    }
    CFRelease(items);
    
    return tempSK;
}


#pragma mark ----  加解密 ------


/**
 RSA加密

 @param data 待加密数据
 @param secPaddingType 填充方式
 @param isPublickey YES:公钥加密，NO:表示采用私钥加密
 @return 返回加密后的数据
 */
- (NSData*)encryptWithData:(NSData*)data padding:(SecPadding)secPaddingType keyMode:(BOOL)isPublickey
{
    if (!data) {
        return nil;
    }
    
    SecKeyRef key = isPublickey ? _publicKeyRef : _privateKeyRef;
    
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *plainTextBytes = data;
//    size_t blockSize = cipherBufferSize - 11;
    size_t blockSize = cipherBufferSize - 12;
    size_t blockCount = (size_t)ceil([plainTextBytes length] / (double)blockSize);
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:0];
    
    for (int i=0; i<blockCount; i++) {
        
        NSUInteger bufferSize = MIN(blockSize,[plainTextBytes length] - i * blockSize);
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        //kSecPaddingNone
        OSStatus status = SecKeyEncrypt(key,
                                        secPaddingType,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
            
                                        &cipherBufferSize);
        
        if (status == noErr){
            NSData *encryptedBytes = [NSData dataWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            [encryptedData appendData:encryptedBytes];
            
        }else{
            
            //-50，参数错误
            
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            return nil;
        }
    }
    if (cipherBuffer) free(cipherBuffer);
    
  
    return encryptedData;
}

/**
 RSA解密
 
 @param data 待解密数据
 @param secPaddingType 填充方式
 @param isPublickey YES:公钥解密，NO:表示采用私钥解密
 @return 返回加密后的数据
 */
- (NSData*)decryptWithData:(NSData*)data padding:(SecPadding)secPaddingType keyMode:(BOOL)isPublickey
{
    if (!data) {
        return nil;
    }
    
    SecKeyRef key = isPublickey ? _publicKeyRef : _privateKeyRef;

    NSData *wrappedSymmetricKey = data;
 
    
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    size_t keyBufferSize = [wrappedSymmetricKey length];
    
    NSMutableData *bits = [NSMutableData dataWithLength:keyBufferSize];
    OSStatus sanityCheck = SecKeyDecrypt(key,
                                         kSecPaddingPKCS1,
                                         (const uint8_t *) [wrappedSymmetricKey bytes],
                                         cipherBufferSize,
                                         [bits mutableBytes],
                                         &keyBufferSize);
    NSAssert(sanityCheck == noErr, @"Error decrypting, OSStatus == %d.", sanityCheck);
    
    [bits setLength:keyBufferSize];
    
    return bits;
}



- (NSData *)signData:(NSData *)rawData withPadding:(SecPadding)padding{
    size_t hashSize = SecKeyGetBlockSize(_privateKeyRef);
    uint8_t *bytes = malloc(hashSize);
    
    OSStatus err = SecKeyRawSign(_privateKeyRef,
                                 padding,
                                 [rawData bytes],
                                 [rawData length],
                                 bytes,
                                 &hashSize);
//    NSAssert(err == errSecSuccess, @"SecKeyRawSign failed: %d", (int)err);
    
    if (err != errSecSuccess) {
        NSLog(@"SecKeyRawSign failed: %d", (int)err);
        
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:bytes length:hashSize];
    
}
- (BOOL)verifyData:(NSData *)rawData withSignature:(NSData *)signature  withPadding:(SecPadding)padding{
    return errSecSuccess == SecKeyRawVerify(_publicKeyRef,
                                            padding,
                                            [rawData bytes],
                                            [rawData length],
                                            [signature bytes],
                                            [signature length]);
}


@end





