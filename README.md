## DevTool
Mac OS X 10.9以上 开发调试小工具

[不需要代码，点击直接下载安装包](https://github.com/MxABC/Resource/blob/master/DataHandler.zip)


#### 当前完成

1. base64
2. hash(MD5,SHA1,SHA256,SHA3,SM3,HMAC)
3. 对称加解密(DES,3DES,AES,SM4)
`支持分组加密模式有： ECB、CBC、PCBC、CFB、OFB、CTR`
`填充方式(分组不足补位)有：PKCS7、zero、ANSIX923、ISO10126、0x80等`
4. der,cer证书文件解析

![image](https://github.com/MxABC/Resource/blob/master/macApp.jpg)


#### cocoapods安装
包含base64,数据转换，摘要算法，对称加解密

```
  pod 'LBXDataHandler',git:'https://github.com/MxABC/DevDataTool.git',tag:'1.0.1'
```

#### 文件说明

#####  摘要算法
- `NSData+LBXHash.h` 各种摘要算法

- `NSString+LBXFileHash.h` 文件摘要

##### base64转换
- `NSData+LBXBase64.h` base64变换

- `NSString+LBXBase64.h` base64反变换

##### 编码转换、格式转换、形式转换

- `NSData+LBXConverter.h` 转换成各种形式NSString,字典等

- `NSString+LBXConverter.h` 各种编码转换、NSData,NSDate等

##### 对称加解密
- `NSData+LBXCrypt.h` 对称加解密封装接口

```
/**
 encrypt interface

 @param op encryt or decrypt
 @param alg encryt algorithm
 @param om ECB、CBC、CFB、OFB
 @param padding padding type
 @param key key
 @param iv init vector
 @param error return err info
 @return  result,fail if return nil
 */
- (NSData*)LBXCryptWithOp:(LBXOperaton)op
                algorithm:(LBXAlgorithm)alg
               optionMode:(LBXOptionMode)om
                  padding:(LBXPaddingMode)padding
                      key:(id)key
                       iv:(id)iv
                    error:(NSError**)error;
```