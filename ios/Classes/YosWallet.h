//
//  NSObject+YosWallet.h
//  YosWalletTest
//
//  Created by Joe Park on 18/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YosWallet : NSObject

@property (nonatomic, readonly) BOOL isLocked;

+ (id)sharedManager;

- (BOOL)loadWallet;
- (void)createWallet:(NSString *)password;
- (void)lock;
- (void)unlock:(NSString *)password;
- (NSString *)getPublicKey;
- (void)sign:(NSData *)digest withCompletion:(void(^)(NSString *, NSError *)) completion;

@end
