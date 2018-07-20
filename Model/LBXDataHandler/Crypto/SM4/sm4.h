/**
 * \file sm4.h
 */
#ifndef XYSSL_sm4_2_H
#define XYSSL_sm4_2_H

#define sm4_2_ENCRYPT     1
#define sm4_2_DECRYPT     0

/**
 * \brief          SM4 context structure
 */
typedef struct
{
    int mode;                   /*!<  encrypt/decrypt   */
    unsigned long sk[32];       /*!<  SM4 subkeys       */
}
sm4_2_context;


#ifdef __cplusplus
extern "C" {
#endif

/**
 * \brief          SM4 key schedule (128-bit, encryption)
 *
 * \param ctx      SM4 context to be initialized
 * \param key      16-byte secret key
 */
void sm4_2_setkey_enc( sm4_2_context *ctx, unsigned char key[16] );

/**
 * \brief          SM4 key schedule (128-bit, decryption)
 *
 * \param ctx      SM4 context to be initialized
 * \param key      16-byte secret key
 */
void sm4_2_setkey_dec( sm4_2_context *ctx, unsigned char key[16] );

/**
 * \brief          SM4-ECB block encryption/decryption
 * \param ctx      SM4 context
 * \param mode     sm4_2_ENCRYPT or sm4_2_DECRYPT
 * \param length   length of the input data
 * \param input    input block
 * \param output   output block
 */
void sm4_2_crypt_ecb( sm4_2_context *ctx,
				     int mode,
					 int length,
                     unsigned char *input,
                     unsigned char *output);

/**
 * \brief          SM4-CBC buffer encryption/decryption
 * \param ctx      SM4 context
 * \param mode     sm4_2_ENCRYPT or sm4_2_DECRYPT
 * \param length   length of the input data
 * \param iv       initialization vector (updated after use)
 * \param input    buffer holding the input data
 * \param output   buffer holding the output data
 */
void sm4_2_crypt_cbc( sm4_2_context *ctx,
                     int mode,
                     int length,
                     unsigned char iv[16],
                     unsigned char *input,
                     unsigned char *output );

#ifdef __cplusplus
}
#endif

#endif /* sm4.h */
