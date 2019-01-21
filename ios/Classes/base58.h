//
//  base58.h
//  YosWalletTest
//
//  Created by Joe Park on 15/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#ifndef base58_h
#define base58_h

#include <stdio.h>
#include <stdbool.h>

bool b58enc(char *b58, size_t *b58sz, const void *data, size_t binsz);
bool b58encWithChecksum(char *b58, size_t *b58sz, const void *data, size_t binsz);

#endif /* base58_h */
