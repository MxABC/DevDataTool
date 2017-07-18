#include <string.h>
#include "sm3.h"

#define LEN_OF_SM3_KEY 16U

#define LEN_OF_SM3_BLOCK 64U

#define LEN_OF_SM3_HASHES 32U

static const uint8_t ipad = 0x36;
static const uint8_t opad = 0x5c;

//extern void sm3(uint8_t *message, uint32_t len, uint8_t sm3_hashes[32]);

void sm3_hmac(uint8_t *message, uint32_t len,
			  uint8_t key[LEN_OF_SM3_KEY], uint8_t hmac[LEN_OF_SM3_HASHES])
{
	uint8_t block[LEN_OF_SM3_BLOCK];
	uint8_t inner[LEN_OF_SM3_BLOCK+len];
	uint8_t outer[LEN_OF_SM3_BLOCK+LEN_OF_SM3_HASHES];
	int i;

	/*密钥使用sm4的对称密钥，固定长度128比特*/
	memcpy(block, key, (size_t)LEN_OF_SM3_KEY);
	memset(block+LEN_OF_SM3_KEY, 0, (size_t)LEN_OF_SM3_BLOCK-LEN_OF_SM3_KEY);
	for(i=0; (uint32_t)i<LEN_OF_SM3_BLOCK; i++)
	{
		inner[i] = block[i] ^ ipad;
		outer[i] = block[i] ^ opad;
	}

	memcpy(inner+LEN_OF_SM3_BLOCK, message, (size_t)len);

	sm3(inner, LEN_OF_SM3_BLOCK+len, hmac);

	memcpy(outer+LEN_OF_SM3_BLOCK, hmac, (size_t)LEN_OF_SM3_HASHES);

	sm3(outer, (LEN_OF_SM3_BLOCK+LEN_OF_SM3_HASHES), hmac);
}
