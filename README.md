## DevTool

实现mac端调试工具验证结果正确性,代码兼容iOS和MacOS,其中SM3,SM4使用C语言代码，补位代码和分组模式代码自行通过objective-c代码实现，加强理解。代码基本通过category形式提供。

#### 当前完成
1. NSString和NSData各种编码转换(UTF-8,GBK,Latin1,unicode,shiftJI)

2. NSData转换hexString及base64String方便调试看数据

3. NSString与NSData之间转换

4. base64

5. hash(MD5,SHA1,SHA256,SHA3,SM3,HMAC)

6. 对称加解密(DES,3DES,AES,SM4)
`支持分组加密模式有： ECB、CBC、PCBC、CFB、OFB、CTR`
`填充方式(分组不足补位)有：PKCS7、zero、ANSIX923、ISO10126、0x80等`

7. der,cer证书文件解析

#### 截图

##### HASH
![image](https://gitee.com/lbxia/Resourse/raw/master/DevDataTool0.png)

##### encryption and decryption
![image](https://gitee.com/lbxia/Resourse/raw/master/DevDataToo1.png)

##### cer analysis
![image](https://raw.githubusercontent.com/MxABC/Resource/master/macApp.jpg)


#### cocoapods安装
包含base64,数据转换，摘要算法，对称加解密

```
 pod 'LBXDataHandler', '~> 1.0.3'
```

#### 文件说明

##### 常用转换
- `NSData+LBXConverter.h`
- `NSString+LBXConverter.h`

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