
#include "sm3.h"
#include <string.h>


#define ROTL(x, n) (((x) << (n)) | ((x) >> (32 - (n))))

#define SM3_FUNC_FF0_15(x, y, z) ((x) ^ (y) ^ (z))

#define SM3_FUNC_FF16_63(x, y, z) (((x) & (y)) | ((x) & (z)) | ((y) & (z)))

#define SM3_FUNC_GG0_15(x, y, z) ((x) ^ (y) ^ (z))

#define SM3_FUNC_GG16_63(x, y, z) (((x) & (y)) | ((~(x)) & (z)))

#define SM3_FUNC_P0(x) ((x) ^ (ROTL((x), 9)) ^ (ROTL((x), 17)))

#define SM3_FUNC_P1(x) ((x) ^ (ROTL((x), 15)) ^ (ROTL((x), 23)))

#define INT_2_CHARX4(n, b, i)                   \
{							                                	\
	((b)[(i)  ] = (uint8_t)((n) >> 24)); 		\
  ((b)[(i)+1] = (uint8_t)((n) >> 16));	\
	((b)[(i)+2] = (uint8_t)((n) >>  8));		\
	((b)[(i)+3] = (uint8_t)((n)      ));		\
}

#define CHARX4_2_INT(n, b, i)					      	\
(													                    \
 	(n) = ((uint32_t)((b)[(i)  ] << 24))		\
 		  | ((uint32_t)((b)[(i)+1] << 16))		  \
 		  | ((uint32_t)((b)[(i)+2] <<  8))		  \
 		  | ((uint32_t)((b)[(i)+3]      ))		  \
)

static const uint32_t iv[8] = {0x7380166f, 0x4914b2b9, 0x172442d7, 0xda8a0600,
							 0xa96f30bc, 0x163138aa, 0xe38dee4d, 0xb0fb0e4e};
static const uint32_t t0_t15 = 0x79cc4519;
static const uint32_t t16_t63 = 0x7a879d8a;

struct sm3_context
{
	uint32_t reg[8];
	uint32_t ss1;
	uint32_t ss2;
	uint32_t tt1;
	uint32_t tt2;
	uint32_t v[8];
};

/*不支持最大长度2^64比特，所支持最大长度修改为2^32比特。*/
static void sm3_padding(uint8_t *message, uint32_t len, uint8_t *message1)
{
	uint32_t len_pad_zero;

	len_pad_zero = 59U - (len % 64U);
	memcpy(message1, message, (size_t)len);
	message1[len] = 0x80;
	memset(message1+len+1, 0, (size_t)len_pad_zero);
	INT_2_CHARX4(len*8U, message1, len+len_pad_zero+1U);
}

static void sm3_extend(uint8_t b[64], uint32_t w[68], uint32_t w1[64])
{
	int i;

	for(i=0; i<16; i++)
	{
		CHARX4_2_INT(w[i], b, i*4);
	}

	for(i=16; i<=67; i++)
	{
		w[i] = SM3_FUNC_P1(w[i-16] ^ w[i-9] ^ (ROTL(w[i-3], 15))) ^ ROTL(w[i-13], 7) ^ w[i-6];
	}

	for(i=0; i<=63; i++)
	{
		w1[i] = w[i] ^ w[i+4];
	}
}

static void sm3_func_cf(struct sm3_context *ctx, uint32_t w[68], uint32_t w1[64])
{
	int i;

	for(i=0; i<8; i++)
	{
		ctx->reg[i] = ctx->v[i];
	}

	for(i=0; i<=15; i++)
	{
		ctx->ss1 = ROTL((ROTL(ctx->reg[0], 12) + ctx->reg[4] + ROTL(t0_t15, i)), 7);
		ctx->ss2 = ctx->ss1 ^ ROTL(ctx->reg[0], 12);
		ctx->tt1 = SM3_FUNC_FF0_15(ctx->reg[0], ctx->reg[1], ctx->reg[2]) + \
				   				   ctx->reg[3] + ctx->ss2 + w1[i];
		ctx->tt2 = SM3_FUNC_GG0_15(ctx->reg[4], ctx->reg[5], ctx->reg[6]) + \
				   				   ctx->reg[7] + ctx->ss1 + w[i];
		ctx->reg[3] = ctx->reg[2];
		ctx->reg[2] = ROTL(ctx->reg[1], 9);
		ctx->reg[1] = ctx->reg[0];
		ctx->reg[0] = ctx->tt1;
		ctx->reg[7] = ctx->reg[6];
		ctx->reg[6] = ROTL(ctx->reg[5], 19);
		ctx->reg[5] = ctx->reg[4];
		ctx->reg[4] = SM3_FUNC_P0(ctx->tt2);
	}
	for(i=16; i<=63; i++)
	{
		ctx->ss1 = ROTL((ROTL(ctx->reg[0], 12) + ctx->reg[4] + ROTL(t16_t63, i)), 7);
		ctx->ss2 = ctx->ss1 ^ ROTL(ctx->reg[0], 12);
		ctx->tt1 = SM3_FUNC_FF16_63(ctx->reg[0], ctx->reg[1], ctx->reg[2]) + \
				   				   ctx->reg[3] + ctx->ss2 + w1[i];
		ctx->tt2 = SM3_FUNC_GG16_63(ctx->reg[4], ctx->reg[5], ctx->reg[6]) + \
				   				   ctx->reg[7] + ctx->ss1 + w[i];
		ctx->reg[3] = ctx->reg[2];
		ctx->reg[2] = ROTL(ctx->reg[1], 9);
		ctx->reg[1] = ctx->reg[0];
		ctx->reg[0] = ctx->tt1;
		ctx->reg[7] = ctx->reg[6];
		ctx->reg[6] = ROTL(ctx->reg[5], 19);
		ctx->reg[5] = ctx->reg[4];
		ctx->reg[4] = SM3_FUNC_P0(ctx->tt2);
	}

	for(i=0; i<8; i++)
	{
		ctx->v[i] = ctx->reg[i] ^ ctx->v[i];
	}
}

static void sm3_iteration(uint8_t *message1, uint32_t len, struct sm3_context *ctx)
{
	int i;
	uint32_t n;
	uint32_t w[68];
	uint32_t w1[64];

	n = (len + (64U - (len % 64U))) / 64U;
	memcpy(ctx->v, iv, (size_t)(8U*sizeof(uint32_t)));

	for(i=0; (uint32_t)i<n; i++)
	{
		sm3_extend(message1+((uint32_t)i*64U), w, w1);
		sm3_func_cf(ctx, w, w1);
	}
}

void sm3(uint8_t *message, uint32_t len, uint8_t sm3_hashes[32])
{
	int i;
	struct sm3_context context;
	uint8_t message1[len+(64U-(len%64U))];

	sm3_padding(message, len, message1);

	sm3_iteration(message1, len, &context);

	for(i=0; i<8; i++)
	{
		INT_2_CHARX4(context.v[i], sm3_hashes, i*4);
	}
}
