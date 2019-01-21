//
//  rand.h
//  YosWalletTest
//
//  Created by Joe Park on 16/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#ifndef rand_h
#define rand_h

#include <stdint.h>
#include <stdlib.h>

void random_reseed(const uint32_t value);
uint32_t random32(void);
void random_buffer(uint8_t *buf, size_t len);

uint32_t random_uniform(uint32_t n);
void random_permute(char *buf, size_t len);

#endif /* rand_h */
