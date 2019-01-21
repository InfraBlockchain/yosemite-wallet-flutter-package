//
//  ecdsa.h
//  YosWalletTest
//
//  Created by Joe Park on 16/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#ifndef ecdsa_h
#define ecdsa_h

#include <stdio.h>
#include "bignum.h"
#include "options.h"

// curve point x and y
typedef struct {
  bignum256 x, y;
} curve_point;

typedef struct {
  
  bignum256 prime;       // prime order of the finite field
  curve_point G;         // initial curve point
  bignum256 order;       // order of G
  bignum256 order_half;  // order of G divided by 2
  int       a;           // coefficient 'a' of the elliptic curve
  bignum256 b;           // coefficient 'b' of the elliptic curve
  
#if USE_PRECOMPUTED_CP
  const curve_point cp[64][8];
#endif
  
} ecdsa_curve;

void point_copy(const curve_point *cp1, curve_point *cp2);
void point_add(const ecdsa_curve *curve, const curve_point *cp1, curve_point *cp2);
void point_double(const ecdsa_curve *curve, curve_point *cp);
void point_multiply(const ecdsa_curve *curve, const bignum256 *k, const curve_point *p, curve_point *res);
void point_set_infinity(curve_point *p);
int point_is_infinity(const curve_point *p);
int point_is_equal(const curve_point *p, const curve_point *q);
int point_is_negative_of(const curve_point *p, const curve_point *q);
void scalar_multiply(const ecdsa_curve *curve, const bignum256 *k, curve_point *res);
void uncompress_coords(const ecdsa_curve *curve, uint8_t odd, const bignum256 *x, bignum256 *y);

int ecdsa_recover_pub_from_sig (const ecdsa_curve *curve, uint8_t *pub_key, const uint8_t *sig, const uint8_t *digest, int recid);
int ecdsa_validate_pubkey(const ecdsa_curve *curve, const curve_point *pub);
int ecdsa_der_to_sig(const uint8_t *der, uint8_t *sig);

#endif /* ecdsa_h */
