//
//  YOSData.h
//  YosWalletTest
//
//  Created by Joe Park on 10/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import <Foundation/Foundation.h>

void *YOSSecureMemset(void *v, unsigned char c, size_t n);
void YOSSecureClearCString(char *s);
NSMutableData* YOSReversedMutableData(NSData* data);
void YOSReverseBytesLength(void* bytes, NSUInteger length);
void YOSDataReverse(NSMutableData* self);
BOOL YOSDataClear(NSData* data);
