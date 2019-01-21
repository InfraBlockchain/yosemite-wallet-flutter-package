//
//  YosEcUtil.h
//  YosWalletTest
//
//  Created by Joe Park on 15/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import <Foundation/Foundation.h>

void ecc_bytes2native(uint64_t *p_native, const uint8_t *p_bytes, int NUM_ECC_DIGITS);
void ecc_native2bytes(uint8_t *p_bytes, const uint64_t *p_native, int NUM_ECC_DIGITS);
const uint8_t *fromhex(const char *str);

@interface YosEcUtil : NSObject

+ (NSString *)encodeBase58StringWithData:(NSData *)data;
+ (NSString *)encodeBase58CheckStringWithData:(NSData *)data;

@end
