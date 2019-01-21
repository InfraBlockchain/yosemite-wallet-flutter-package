//
//  YOSData.m
//  YosWalletTest
//
//  Created by Joe Park on 10/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import "YOSData.h"

// This is designed to be not optimized out by compiler like memset
void *YOSSecureMemset(void *v, unsigned char c, size_t n) {
  if (!v) return v;
  volatile unsigned char *p = v;
  while (n--)
    *p++ = c;
  
  return v;
}

void YOSSecureClearCString(char *s) {
  if (!s) return;
  YOSSecureMemset(s, 0, strlen(s));
}

NSMutableData* YOSReversedMutableData(NSData* data) {
  if (!data) return nil;
  NSMutableData* md = [NSMutableData dataWithData:data];
  YOSDataReverse(md);
  return md;
}

void YOSReverseBytesLength(void* bytes, NSUInteger length) {
  // K&R
  if (length <= 1) return;
  unsigned char* buf = bytes;
  unsigned char byte;
  NSUInteger i, j;
  for (i = 0, j = length - 1; i < j; i++, j--) {
    byte = buf[i];
    buf[i] = buf[j];
    buf[j] = byte;
  }
}

// Reverses byte order in the internal buffer of mutable data object.
void YOSDataReverse(NSMutableData* self) {
  YOSReverseBytesLength(self.mutableBytes, self.length);
}

// Clears contents of the data to prevent leaks through swapping or buffer-overflow attacks.
BOOL YOSDataClear(NSData* data) {
  if ([data isKindOfClass:[NSMutableData class]]) {
    [(NSMutableData*)data resetBytesInRange:NSMakeRange(0, data.length)];
    return YES;
  }
  return NO;
}
