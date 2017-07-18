//
//  sm3.h
//  DataHandler
//
//  Created by lbxia on 2017/5/9.
//  Copyright © 2017年 LBX. All rights reserved.
//

#ifndef sm3_h
#define sm3_h
#include <stdio.h>
#include <stdint.h>


#define LEN_OF_SM3_KEY 16U
#define LEN_OF_SM3_BLOCK 64U
#define LEN_OF_SM3_HASHES 32U

void sm3(uint8_t *message, uint32_t len, uint8_t sm3_hashes[LEN_OF_SM3_HASHES]);


void sm3_hmac(uint8_t *message, uint32_t len,
              uint8_t key[LEN_OF_SM3_KEY], uint8_t hmac[LEN_OF_SM3_HASHES]);

#endif /* sm3_h */
