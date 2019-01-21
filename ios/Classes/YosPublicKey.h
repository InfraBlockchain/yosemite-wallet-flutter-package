//
//  YosPublicKey.h
//  YosWalletTest
//
//  Created by Joe Park on 10/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YosPublicKey : NSObject

- (id)initWithPublicKeyData:(NSData *)publicKey;
- (NSString *)base58EncodedKey;

@end

