//
//  YosEcUtil.m
//  YosWalletTest
//
//  Created by Joe Park on 15/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import "YosEcUtil.h"
#include <string.h>
#import "base58.h"
#import <CommonCrypto/CommonDigest.h>
#import "YOSData.h"
#import "ripemd160.h"

#define MAX_ADDR_SIZE 130
#define FROMHEX_MAXLEN 512

void ecc_bytes2native(uint64_t *p_native, const uint8_t *p_bytes, int NUM_ECC_DIGITS) {
  unsigned i;
  for (i=0; i<NUM_ECC_DIGITS; ++i) {
    const uint8_t *p_digit = p_bytes + 8 * (NUM_ECC_DIGITS - 1 -i);
    p_native[i] = ((uint64_t)p_digit[0] << 56) | ((uint64_t)p_digit[1] << 48) | ((uint64_t)p_digit[2] << 40) | ((uint64_t)p_digit[3] << 32) |
    ((uint64_t)p_digit[4] << 24) | ((uint64_t)p_digit[5] << 16) | ((uint64_t)p_digit[6] << 8) | (uint64_t)p_digit[7];
  }
}

void ecc_native2bytes(uint8_t *p_bytes, const uint64_t *p_native, int NUM_ECC_DIGITS) {
  unsigned i;
  for(i=0; i<NUM_ECC_DIGITS; ++i) {
    uint8_t *p_digit = p_bytes + 8 * (NUM_ECC_DIGITS - 1 - i);
    p_digit[0] = p_native[i] >> 56;
    p_digit[1] = p_native[i] >> 48;
    p_digit[2] = p_native[i] >> 40;
    p_digit[3] = p_native[i] >> 32;
    p_digit[4] = p_native[i] >> 24;
    p_digit[5] = p_native[i] >> 16;
    p_digit[6] = p_native[i] >> 8;
    p_digit[7] = p_native[i];
  }
}

const uint8_t *fromhex(const char *str)
{
  static uint8_t buf[FROMHEX_MAXLEN];
  size_t len = strlen(str) / 2;
  if (len > FROMHEX_MAXLEN) len = FROMHEX_MAXLEN;
  for (size_t i = 0; i < len; i++) {
    uint8_t c = 0;
    if (str[i * 2] >= '0' && str[i*2] <= '9') c += (str[i * 2] - '0') << 4;
    if ((str[i * 2] & ~0x20) >= 'A' && (str[i*2] & ~0x20) <= 'F') c += (10 + (str[i * 2] & ~0x20) - 'A') << 4;
    if (str[i * 2 + 1] >= '0' && str[i * 2 + 1] <= '9') c += (str[i * 2 + 1] - '0');
    if ((str[i * 2 + 1] & ~0x20) >= 'A' && (str[i * 2 + 1] & ~0x20) <= 'F') c += (10 + (str[i * 2 + 1] & ~0x20) - 'A');
    buf[i] = c;
  }
  return buf;
}

@implementation YosEcUtil

+ (NSString *)encodeBase58StringWithData:(NSData *)data {
  char addr[MAX_ADDR_SIZE];
  size_t res = sizeof(addr);
  
  if (!b58enc(addr, &res, data.bytes, (size_t)data.length)) {
    return nil;
  }
  
  return [NSString stringWithCString:addr encoding:NSASCIIStringEncoding];
}

+ (NSString *)encodeBase58CheckStringWithData:(NSData *)data {
  if (!data) return NULL;
  
  uint8_t typeBytes[2] = {0x52, 0x31};
  
  uint8_t toHashBytes[data.length + 2];
  memcpy(toHashBytes, data.bytes, data.length);
  memcpy(toHashBytes + data.length, typeBytes, 2);
  
  uint8_t buf[data.length + RIPEMD160_DIGEST_LENGTH];
  
  ripemd160(toHashBytes, (int)data.length + 2, buf);
  
  NSMutableData *dataWithChecksum = [NSMutableData dataWithData:data];
  [dataWithChecksum appendBytes:buf length:4]; // adding first 4 bytes as checksum
  
  NSLog(@"Compressed key with checksum:%@", dataWithChecksum);
  
  NSString *result = [self encodeBase58StringWithData:dataWithChecksum];
  
  YOSSecureMemset(buf, 0, sizeof(buf));
  YOSDataClear(dataWithChecksum);
  return result;
}

@end
