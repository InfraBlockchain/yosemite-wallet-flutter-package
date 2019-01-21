//
//  secp256r1.c
//  YosWalletTest
//
//  Created by Joe Park on 16/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#include "secp256r1.h"

const ecdsa_curve secp256r1 = {
  /* .prime */ {
    /*.val =*/ {0x3fffffff, 0x3fffffff, 0x3fffffff, 0x3f, 0x0, 0x0, 0x1000, 0x3fffc000, 0xffff}
  },
  
  /* G */ {
    /*.x =*/{/*.val =*/{0x1898c296, 0x1284e517, 0x1eb33a0f, 0xdf604b, 0x2440f277, 0x339b958e, 0x4247f8b, 0x347cb84b, 0x6b17}},
    /*.y =*/{/*.val =*/{0x37bf51f5, 0x2ed901a0, 0x3315ecec, 0x338cd5da, 0xf9e162b, 0x1fad29f0, 0x27f9b8ee, 0x10b8bf86, 0x4fe3}}
  },
  
  /* order */ {
    /*.val =*/{0x3c632551, 0xee72b0b, 0x3179e84f, 0x39beab69, 0x3fffffbc, 0x3fffffff, 0xfff, 0x3fffc000, 0xffff}
  },
  
  /* order_half */ {
    /*.val =*/{0x3e3192a8, 0x27739585, 0x38bcf427, 0x1cdf55b4, 0x3fffffde, 0x3fffffff, 0x7ff, 0x3fffe000, 0x7fff}
  },
  
  /* a */ -3,
  
  /* b */ {
    /*.val =*/{0x27d2604b, 0x2f38f0f8, 0x53b0f63, 0x741ac33, 0x1886bc65, 0x2ef555da, 0x293e7b3e, 0xd762a8e, 0x5ac6}
  }
  
#if USE_PRECOMPUTED_CP
  ,
  /* cp */ {
#include "secp256r1.table"
  }
#endif
};
