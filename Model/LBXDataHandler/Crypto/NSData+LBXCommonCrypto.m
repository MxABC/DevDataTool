/*
 *  NSData+CommonCrypto.m
 *  AQToolkit
 *
 *  Created by Jim Dovey on 31/8/2008.
 *
 *  Copyright (c) 2008-2009, Jim Dovey
 *  All rights reserved.
 *  
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *  
 *  Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *  
 *  Neither the name of this project's author nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 *  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 *  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import <Foundation/Foundation.h>
#import "NSData+LBXCommonCrypto.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

NSString * const LBXkCommonCryptoErrorDomain = @"LBXCommonCryptoErrorDomain";

static void FixKeyLengths( CCAlgorithm algorithm, NSMutableData * keyData, NSMutableData * ivData );

@implementation NSError (CommonCryptoErrorDomain)

+ (NSError *) errorWithCCCryptorStatus: (CCCryptorStatus) status
{
	NSString * description = nil, * reason = nil;
	
	switch ( status )
	{
		case kCCSuccess:
			description = NSLocalizedString(@"Success", @"Error description");
			break;
			
		case kCCParamError:
			description = NSLocalizedString(@"Parameter Error", @"Error description");
			reason = NSLocalizedString(@"Illegal parameter supplied to encryption/decryption algorithm", @"Error reason");
			break;
			
		case kCCBufferTooSmall:
			description = NSLocalizedString(@"Buffer Too Small", @"Error description");
			reason = NSLocalizedString(@"Insufficient buffer provided for specified operation", @"Error reason");
			break;
			
		case kCCMemoryFailure:
			description = NSLocalizedString(@"Memory Failure", @"Error description");
			reason = NSLocalizedString(@"Failed to allocate memory", @"Error reason");
			break;
			
		case kCCAlignmentError:
			description = NSLocalizedString(@"Alignment Error", @"Error description");
			reason = NSLocalizedString(@"Input size to encryption algorithm was not aligned correctly", @"Error reason");
			break;
			
		case kCCDecodeError:
			description = NSLocalizedString(@"Decode Error", @"Error description");
			reason = NSLocalizedString(@"Input data did not decode or decrypt correctly", @"Error reason");
			break;
			
		case kCCUnimplemented:
			description = NSLocalizedString(@"Unimplemented Function", @"Error description");
			reason = NSLocalizedString(@"Function not implemented for the current algorithm", @"Error reason");
			break;
			
		default:
			description = NSLocalizedString(@"Unknown Error", @"Error description");
			break;
	}
	
	NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject: description forKey: NSLocalizedDescriptionKey];
	
	if ( reason != nil )
		[userInfo setObject: reason forKey: NSLocalizedFailureReasonErrorKey];
	
	NSError * result = [NSError errorWithDomain: LBXkCommonCryptoErrorDomain code: status userInfo: userInfo];
	
	
	return ( result );
}

@end

#pragma mark -

@implementation NSData (CommonDigest)

- (NSData *) MD2Sum
{
	unsigned char hash[CC_MD2_DIGEST_LENGTH];
	(void) CC_MD2( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_MD2_DIGEST_LENGTH] );
}

- (NSData *) MD4Sum
{
	unsigned char hash[CC_MD4_DIGEST_LENGTH];
	(void) CC_MD4( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_MD4_DIGEST_LENGTH] );
}

- (NSData *) MD5Sum
{
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    (void) CC_MD5( [self bytes], (CC_LONG)[self length], hash );
    return ( [NSData dataWithBytes: hash length: CC_MD5_DIGEST_LENGTH] );

    
}

- (NSData *) SHA1Hash
{
	unsigned char hash[CC_SHA1_DIGEST_LENGTH];
	(void) CC_SHA1( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA1_DIGEST_LENGTH] );
}

- (NSData *) SHA224Hash
{
	unsigned char hash[CC_SHA224_DIGEST_LENGTH];
	(void) CC_SHA224( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA224_DIGEST_LENGTH] );
}

- (NSData *) SHA256Hash
{
	unsigned char hash[CC_SHA256_DIGEST_LENGTH];
	(void) CC_SHA256( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA256_DIGEST_LENGTH] );
}

- (NSData *) SHA384Hash
{
	unsigned char hash[CC_SHA384_DIGEST_LENGTH];
	(void) CC_SHA384( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA384_DIGEST_LENGTH] );
}

- (NSData *) SHA512Hash
{
	unsigned char hash[CC_SHA512_DIGEST_LENGTH];
	(void) CC_SHA512( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA512_DIGEST_LENGTH] );
}

@end

@implementation NSData (CommonCryptor)

- (NSData *) AES256EncryptedDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self dataEncryptedUsingAlgorithm: kCCAlgorithmAES128
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}

- (NSData *) decryptedAES256DataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self decryptedDataUsingAlgorithm: kCCAlgorithmAES128
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}

- (NSData *) DESEncryptedDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self dataEncryptedUsingAlgorithm: kCCAlgorithmDES
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
    
//    NSData * result = [self dataEncryptedUsingAlgorithm: kCCAlgorithmDES
//                                                    key: key
//                                                options: kCCOptionECBMode
//                                                  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}

/**
 DES加密： ECB模式，填充方式 PKCS7Padding
 
 @param key   密钥，8字节
 @param error 加密返回错误
 
 @return 返回加密结果
 */
- (NSData*)DES_ECB_PKCS7Padding:(id)key error: (NSError **) error
{
    NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
    //    NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
    
    NSMutableData * keyData;
    if ( [key isKindOfClass: [NSData class]] )
        keyData = (NSMutableData *) [key mutableCopy];
    else
        keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    
    NSMutableData* plainData = [NSMutableData dataWithData:self];
    
    
    size_t bufferPtrSize = plainData.length + kCCKeySizeDES;
    void* bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    size_t movedBytes = 0;
    
    CCCryptorStatus ccStatus = CCCrypt(kCCEncrypt,
                                       kCCAlgorithmDES,
                                       kCCOptionECBMode | kCCOptionPKCS7Padding,
                                       keyData.bytes,
                                       kCCKeySizeDES,
                                       nil,
                                       plainData.bytes,
                                       plainData.length,
                                       (void *)bufferPtr,
                                       bufferPtrSize,
                                       &movedBytes);
    
    
    // output situation after crypt
    switch (ccStatus) {
        case kCCSuccess:
        {
            NSLog(@"SUCCESS");
            
            NSData *result = [NSData dataWithBytes:bufferPtr length:movedBytes];
            
            free(bufferPtr);
            bufferPtr = NULL;
            
            return result;
        }
            break;
        case kCCParamError:
            NSLog(@"PARAM ERROR");
            break;
        case kCCBufferTooSmall:
            NSLog(@"BUFFER TOO SMALL");
            break;
        case kCCMemoryFailure:
            NSLog(@"MEMORY FAILURE");
            break;
        case kCCAlignmentError:
            //未填充报错
            NSLog(@"ALIGNMENT ERROR");
            break;
        case kCCDecodeError:
            NSLog(@"DECODE ERROR");
            break;
        case kCCUnimplemented:
            NSLog(@"UNIMPLEMENTED");
            break;
        default:
            break; 
    }
    
    free(bufferPtr);
    bufferPtr = NULL;
    
    return nil;
}


//- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
//                                     key: (id) key
//                    initializationVector: (id) iv
//                                 options: (CCOptions) options
//                                   error: (CCCryptorStatus *) error


- (NSData*)dataCipherUsingAlogorithm:(CCAlgorithm) algorithm
                                  op:(CCOperation) op
                                mode:(CCOptions) options
                                 key: (id) key
                initializationVector: (id) iv
                               error: (NSError **) error
{
    return nil;
}

- (NSData*)DE_DES_ECB_PKCS7Padding:(id)key error: (NSError **) error
{
    NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
    //    NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
    
    NSMutableData * keyData;
    if ( [key isKindOfClass: [NSData class]] )
        keyData = (NSMutableData *) [key mutableCopy];
    else
        keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    
    NSMutableData* plainData = [NSMutableData dataWithData:self];
    
    
    size_t bufferPtrSize = plainData.length + kCCKeySizeDES;
    void* bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    size_t movedBytes = 0;
    
    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt,
                                       kCCAlgorithmDES,
                                       kCCOptionECBMode | kCCOptionPKCS7Padding,
                                       keyData.bytes, //"123456789012345678901234", //key
                                       kCCKeySizeDES,
                                       nil, //"init Vec", //iv,
                                       plainData.bytes, //"Your Name", //plainText,
                                       plainData.length,
                                       (void *)bufferPtr,
                                       bufferPtrSize,
                                       &movedBytes);
    
    
    // output situation after crypt
    switch (ccStatus) {
        case kCCSuccess:
        {
            NSLog(@"SUCCESS");
            
            NSData *result = [NSData dataWithBytes:bufferPtr length:movedBytes];
            free(bufferPtr);
            return result;
        }
            break;
        case kCCParamError:
            NSLog(@"PARAM ERROR");
            break;
        case kCCBufferTooSmall:
            NSLog(@"BUFFER TOO SMALL");
            break;
        case kCCMemoryFailure:
            NSLog(@"MEMORY FAILURE");
            break;
        case kCCAlignmentError:
            //未填充报错
            NSLog(@"ALIGNMENT ERROR");
            break;
        case kCCDecodeError:
            NSLog(@"DECODE ERROR");
            break;
        case kCCUnimplemented:
            NSLog(@"UNIMPLEMENTED");
            break;
        default:
            break;
    }
    
    free(bufferPtr);
    bufferPtr = NULL;
    
    return nil;
}


- (NSData*)DES_ECB_ZeroPadding:(id)key error: (NSError **) error
{
    NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
//    NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
    
    NSMutableData * keyData;
    if ( [key isKindOfClass: [NSData class]] )
        keyData = (NSMutableData *) [key mutableCopy];
    else
        keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    
    NSMutableData* plainData = [NSMutableData dataWithData:self];
    
    //zeropadding
    int diff = plainData.length % kCCKeySizeDES;
    if (diff > 0) {
        diff = kCCKeySizeDES - diff;
    }
    unsigned char zeroPadding[kCCKeySizeDES] = {0};
    [plainData appendBytes:zeroPadding length:diff];
    
    
    size_t bufferPtrSize = plainData.length;
    void* bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    size_t movedBytes = 0;
    
    CCCryptorStatus ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmDES,
                       kCCOptionECBMode,
                       keyData.bytes, //"123456789012345678901234", //key
                       kCCKeySizeDES,
                       nil, //"init Vec", //iv,
                       plainData.bytes, //"Your Name", //plainText,
                       plainData.length,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    
    // output situation after crypt
    switch (ccStatus) {
        case kCCSuccess:
        {
            NSLog(@"SUCCESS");
            
            NSData *result = [NSData dataWithBytes:bufferPtr length:movedBytes];
            free(bufferPtr);
            return result;
        }
            break;
        case kCCParamError:
            NSLog(@"PARAM ERROR");
            break;
        case kCCBufferTooSmall:
            NSLog(@"BUFFER TOO SMALL");
            break;
        case kCCMemoryFailure:
            NSLog(@"MEMORY FAILURE");
            break;
        case kCCAlignmentError:
            //未填充报错
            NSLog(@"ALIGNMENT ERROR");
            break;
        case kCCDecodeError:
            NSLog(@"DECODE ERROR");
            break;
        case kCCUnimplemented:
            NSLog(@"UNIMPLEMENTED");
            break;
        default:
            break; 
    }
    
    
    free(bufferPtr);
    bufferPtr = NULL;
    
    
    return nil;
}

- (NSData*)DE_DES_ECB_ZeroPadding:(id)key error: (NSError **) error
{
    NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
    //    NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
    
    NSMutableData * keyData;
    if ( [key isKindOfClass: [NSData class]] )
        keyData = (NSMutableData *) [key mutableCopy];
    else
        keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    
    NSMutableData* plainData = [NSMutableData dataWithData:self];
    
//    //zeropadding
//    int diff = plainData.length % kCCKeySizeDES;
//    if (diff > 0) {
//        diff = kCCKeySizeDES - diff;
//    }
//    unsigned char zeroPadding[kCCKeySizeDES] = {0};
//    [plainData appendBytes:zeroPadding length:diff];
    
    
    size_t bufferPtrSize = plainData.length;
    void* bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    size_t movedBytes = 0;
    
    CCCryptorStatus ccStatus = CCCrypt(kCCDecrypt,
                                       kCCAlgorithmDES,
                                       kCCOptionECBMode,
                                       keyData.bytes, //"123456789012345678901234", //key
                                       kCCKeySizeDES,
                                       nil, //"init Vec", //iv,
                                       plainData.bytes, //"Your Name", //plainText,
                                       plainData.length,
                                       (void *)bufferPtr,
                                       bufferPtrSize,
                                       &movedBytes);
    
    
    // output situation after crypt
    switch (ccStatus) {
        case kCCSuccess:
        {
            NSLog(@"SUCCESS");
            
            //判断后面的0，删除掉
            int i = (int)(movedBytes - 1);
            unsigned char *tmp = (unsigned char*)bufferPtr;
            for (; i >= 0; i--) {
                
                if (tmp[i] == 0x00)
                {
                    movedBytes--;
                }
                else
                {
                    break;
                }
            }
            
            NSData *result = [NSData dataWithBytes:bufferPtr length:movedBytes];
            free(bufferPtr);
            return result;
        }
            break;
        case kCCParamError:
            NSLog(@"PARAM ERROR");
            break;
        case kCCBufferTooSmall:
            NSLog(@"BUFFER TOO SMALL");
            break;
        case kCCMemoryFailure:
            NSLog(@"MEMORY FAILURE");
            break;
        case kCCAlignmentError:
            //未填充报错
            NSLog(@"ALIGNMENT ERROR");
            break;
        case kCCDecodeError:
            NSLog(@"DECODE ERROR");
            break;
        case kCCUnimplemented:
            NSLog(@"UNIMPLEMENTED");
            break;
        default:
            break; 
    }
    
    
    free(bufferPtr);
    bufferPtr = NULL;
    
    
    return nil;
}

- (NSData *) decryptedDESDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self decryptedDataUsingAlgorithm: kCCAlgorithmDES
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}

- (NSData *) CASTEncryptedDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self dataEncryptedUsingAlgorithm: kCCAlgorithmCAST
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}

- (NSData *) decryptedCASTDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self decryptedDataUsingAlgorithm: kCCAlgorithmCAST
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}

@end

static void FixKeyLengths( CCAlgorithm algorithm, NSMutableData * keyData, NSMutableData * ivData )
{
	NSUInteger keyLength = [keyData length];
	switch ( algorithm )
	{
		case kCCAlgorithmAES128:
		{
			if ( keyLength <= 16 )
			{
				[keyData setLength: 16];
			}
			else if ( keyLength <= 24 )
			{
				[keyData setLength: 24];
			}
			else
			{
				[keyData setLength: 32];
			}
			
			break;
		}
			
		case kCCAlgorithmDES:
		{
			[keyData setLength: 8];
			break;
		}
			
		case kCCAlgorithm3DES:
		{
			[keyData setLength: 24];
			break;
		}
			
		case kCCAlgorithmCAST:
		{
			if ( keyLength <= 5 )
			{
				[keyData setLength: 5];
			}
			else if ( keyLength > 16 )
			{
				[keyData setLength: 16];
			}
			
			break;
		}
			
		case kCCAlgorithmRC4:
		{
			if ( keyLength > 512 )
				[keyData setLength: 512];
			break;
		}
			
		default:
			break;
	}
    
    if (ivData) {
        [ivData setLength: [keyData length]];
    }
}

@implementation NSData (LowLevelCommonCryptor)

- (NSData *) _runCryptor: (CCCryptorRef) cryptor result: (CCCryptorStatus *) status
{
	size_t bufsize = CCCryptorGetOutputLength( cryptor, (size_t)[self length], true );
	void * buf = malloc( bufsize );
	size_t bufused = 0;
    size_t bytesTotal = 0;
	*status = CCCryptorUpdate( cryptor, [self bytes], (size_t)[self length], 
							  buf, bufsize, &bufused );
	if ( *status != kCCSuccess )
	{
		free( buf );
		return ( nil );
	}
    
    bytesTotal += bufused;
	
	// From Brent Royal-Gordon (Twitter: architechies):
	//  Need to update buf ptr past used bytes when calling CCCryptorFinal()
	*status = CCCryptorFinal( cryptor, buf + bufused, bufsize - bufused, &bufused );
	if ( *status != kCCSuccess )
	{
		free( buf );
		return ( nil );
	}
    
    bytesTotal += bufused;
	
	return ( [NSData dataWithBytesNoCopy: buf length: bytesTotal] );
}

- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key
								   error: (CCCryptorStatus *) error
{
	return ( [self dataEncryptedUsingAlgorithm: algorithm
										   key: key
                          initializationVector: nil
									   options: 0
										 error: error] );
}

- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key
                                 options: (CCOptions) options
								   error: (CCCryptorStatus *) error
{
    return ( [self dataEncryptedUsingAlgorithm: algorithm
										   key: key
                          initializationVector: nil
									   options: options
										 error: error] );
}

- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key
					initializationVector: (id) iv
								 options: (CCOptions) options
								   error: (CCCryptorStatus *) error
{
	CCCryptorRef cryptor = NULL;
	CCCryptorStatus status = kCCSuccess;
	
	NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
	NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
	
	NSMutableData * keyData, * ivData;
	if ( [key isKindOfClass: [NSData class]] )
		keyData = (NSMutableData *) [key mutableCopy];
	else
		keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	
	if ( [iv isKindOfClass: [NSString class]] )
		ivData = [[iv dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	else
		ivData = (NSMutableData *) [iv mutableCopy];	// data or nil
	
	
	
	// ensure correct lengths for key and iv data, based on algorithms
	FixKeyLengths( algorithm, keyData, ivData );
	
	status = CCCryptorCreate( kCCEncrypt, algorithm, options,
							  [keyData bytes], [keyData length], [ivData bytes],
							  &cryptor );
	
	if ( status != kCCSuccess )
	{
		if ( error != NULL )
			*error = status;
		return ( nil );
	}
	
	NSData * result = [self _runCryptor: cryptor result: &status];
	if ( (result == nil) && (error != NULL) )
		*error = status;
	
	CCCryptorRelease( cryptor );
	
	return ( result );
}

- (NSData *) decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key		// data or string
								   error: (CCCryptorStatus *) error
{
	return ( [self decryptedDataUsingAlgorithm: algorithm
										   key: key
						  initializationVector: nil
									   options: 0
										 error: error] );
}

- (NSData *) decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key		// data or string
                                 options: (CCOptions) options
								   error: (CCCryptorStatus *) error
{
    return ( [self decryptedDataUsingAlgorithm: algorithm
										   key: key
						  initializationVector: nil
									   options: options
										 error: error] );
}

- (NSData *) decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key		// data or string
					initializationVector: (id) iv		// data or string
								 options: (CCOptions) options
								   error: (CCCryptorStatus *) error
{
	CCCryptorRef cryptor = NULL;
	CCCryptorStatus status = kCCSuccess;
	
	NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
	NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
	
	NSMutableData * keyData, * ivData;
	if ( [key isKindOfClass: [NSData class]] )
		keyData = (NSMutableData *) [key mutableCopy];
	else
		keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	
	if ( [iv isKindOfClass: [NSString class]] )
		ivData = [[iv dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	else
		ivData = (NSMutableData *) [iv mutableCopy];	// data or nil
	
	
	
	// ensure correct lengths for key and iv data, based on algorithms
	FixKeyLengths( algorithm, keyData, ivData );
	
	status = CCCryptorCreate( kCCDecrypt, algorithm, options,
							  [keyData bytes], [keyData length], [ivData bytes],
							  &cryptor );
	
	if ( status != kCCSuccess )
	{
		if ( error != NULL )
			*error = status;
		return ( nil );
	}
	
	NSData * result = [self _runCryptor: cryptor result: &status];
	if ( (result == nil) && (error != NULL) )
		*error = status;
	
	CCCryptorRelease( cryptor );
	
	return ( result );
}

@end

@implementation NSData (CommonHMAC)

- (NSData *) HMACWithAlgorithm: (CCHmacAlgorithm) algorithm
{
	return ( [self HMACWithAlgorithm: algorithm key: nil] );
}

- (NSData *) HMACWithAlgorithm: (CCHmacAlgorithm) algorithm key: (id) key
{
	NSParameterAssert(key == nil || [key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
	
	NSData * keyData = nil;
	if ( [key isKindOfClass: [NSString class]] )
		keyData = [key dataUsingEncoding: NSUTF8StringEncoding];
	else
		keyData = (NSData *) key;
	
	// this could be either CC_SHA1_DIGEST_LENGTH or CC_MD5_DIGEST_LENGTH. SHA1 is larger.
//	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
    unsigned char buf[CC_SHA512_DIGEST_LENGTH];
	CCHmac( algorithm, [keyData bytes], [keyData length], [self bytes], [self length], buf );
    
    
    NSInteger digestLen = 0;

    
    switch (algorithm) {
        case kCCHmacAlgSHA1:
            digestLen = CC_SHA1_DIGEST_LENGTH;
            break;
        case kCCHmacAlgMD5:
            digestLen = CC_MD5_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA224:
            digestLen = CC_SHA224_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA256:
            digestLen = CC_SHA256_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA384:
            digestLen = CC_SHA384_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA512:
            digestLen = CC_SHA512_DIGEST_LENGTH;
            break;
        default:
            break;
    }
	return [NSData dataWithBytes: buf length: digestLen];
}

@end
