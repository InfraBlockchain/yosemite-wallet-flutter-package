//
//  rand.c
//  YosWalletTest
//
//  Created by Joe Park on 16/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#include "rand.h"

// The following code is not supposed to be used in a production environment.
// It's included only to make the library testable.
// The message above tries to prevent any accidental use outside of the test environment.
//
// You are supposed to replace the random8() and random32() function with your own secure code.
// There is also a possibility to replace the random_buffer() function as it is defined as a weak symbol.

static uint32_t seed = 0;

void random_reseed(const uint32_t value)
{
  seed = value;
}

uint32_t random32(void)
{
  // Linear congruential generator from Numerical Recipes
  // https://en.wikipedia.org/wiki/Linear_congruential_generator
  seed = 1664525 * seed + 1013904223;
  return seed;
}

//
// The following code is platform independent
//

void __attribute__((weak)) random_buffer(uint8_t *buf, size_t len)
{
  uint32_t r = 0;
  for (size_t i = 0; i < len; i++) {
    if (i % 4 == 0) {
      r = random32();
    }
    buf[i] = (r >> ((i % 4) * 8)) & 0xFF;
  }
}

uint32_t random_uniform(uint32_t n)
{
  uint32_t x, max = 0xFFFFFFFF - (0xFFFFFFFF % n);
  while ((x = random32()) >= max);
  return x / (max / n);
}

void random_permute(char *str, size_t len)
{
  for (int i = len - 1; i >= 1; i--) {
    int j = random_uniform(i + 1);
    char t = str[j];
    str[j] = str[i];
    str[i] = t;
  }
}
