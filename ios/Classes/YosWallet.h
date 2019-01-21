//
//  NSObject+YosWallet.h
//  YosWalletTest
//
//  Created by Joe Park on 18/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YosWallet : NSObject

+ (bool)generateTouchIDKeyPair;
+ (bool)generateKeyPairWithAccessControlObject:(SecAccessControlRef)accessControlRef;
+ (bool)savePublicKeyFromRef:(SecKeyRef)publicKeyRef;
+ (SecKeyRef)lookupPublicKeyRef;
+ (SecKeyRef)lookupPrivateKeyRef;
+ (void)generateSignatureForData:(NSData *)inputData withCompletion:(void(^)(NSString *, NSError *)) completion;

@end
