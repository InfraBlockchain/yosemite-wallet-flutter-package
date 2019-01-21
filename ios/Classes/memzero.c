//
//  memzero.c
//  YosWalletTest
//
//  Created by Joe Park on 16/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#include "memzero.h"
#include <string.h>

void memzero(void *s, size_t n)
{
  memset(s, 0, n);
}
