//
//  YosPublicKey.m
//  YosWalletTest
//
//  Created by Joe Park on 10/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import "YosPublicKey.h"
#import "YOSData.h"
#import "YosEcUtil.h"

#define ECSizeInBits (256)

@implementation YosPublicKey {
  NSData *_key;
  NSData *_compressedKey; // 33 bytes(1 byte: sign + 32 bytes: x coordinate)
  NSString *_base58EncodedKey; // Encoded 37 bytes the data (33 bytes of compressed key + 4 bytes of the checksum)
}

- (id)initWithPublicKeyData:(NSData *)publicKey {
  if (self = [super init]) {
    _key = publicKey;
    _compressedKey = [self _compress:publicKey];
    _base58EncodedKey = [YosEcUtil encodeBase58CheckStringWithData:_compressedKey];
  }
  
  return self;
}

- (NSData *)_compress:(NSData *)data {
  
  NSInteger length = [data length];
  
  if (length == 0) {
    return nil;
  }
  
  const unsigned char *bytes = (unsigned char *)data.bytes;
  
  switch (bytes[0]) {
      
    // Already compressed
    case 0x02:
    case 0x03:
      return data;
    case 0x04: {
      int numBytes = ECSizeInBits / 8;
      int numDigits = numBytes / 8;
      
      uint64_t xCoord[numDigits], yCoord[numDigits];
      ecc_bytes2native(xCoord, &bytes[1], numDigits);
      ecc_bytes2native(yCoord, &bytes[1 + numBytes], numDigits);
      
      uint8_t publicKey[numBytes + 1];
      ecc_native2bytes(publicKey + 1, xCoord, numDigits);
      publicKey[0] = 0x02 + (yCoord[0] & 0x01);
      
      return [NSData dataWithBytes:publicKey length:numBytes + 1];
    }
  }
  
  return nil;
}

- (NSString *)base58EncodedKey {
  return [NSString stringWithFormat:@"PUB_R1_%@", _base58EncodedKey];
}
@end
