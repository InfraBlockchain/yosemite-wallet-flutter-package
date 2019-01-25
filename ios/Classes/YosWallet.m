//
//  YosWallet.m
//  YosWalletTest
//
//  Created by Joe Park on 18/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import "YosWallet.h"
#import "YosPublicKey.h"
#import "YOSData.h"
#include "bignum.h"
#include "ecdsa.h"
#include "secp256r1.h"
#include "YosEcUtil.h"

#import <CommonCrypto/CommonDigest.h>

#define newCFDict CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks)
#define kPrivateKeyName @"com.yosemitex.wallet.private"
#define kPublicKeyName @"com.yosemitex.wallet.public"

NSString *const WalletErrorDomain = @"WalletErrorDomain";

NSInteger const WalletErrorNoKeyPairFound = 100;

NSString *const CredentialAccount = @"dytpalxlwlrkq";

NSString *const Salt = @"1-I/P~XnXboGQ!jY(,{@a4uc)A!-sZz}2;[4|Fj*G.(?G4%;L?sEy&UKnT$W%Wr?";

@interface YosWallet()

@property (nonatomic) SecKeyRef publicKeyRef;
@property (nonatomic) SecKeyRef privateKeyRef;

@property (nonatomic) BOOL isLocked;

@end

@implementation YosWallet

+ (id)sharedManager {
  static YosWallet *sharedYosWallet = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedYosWallet = [[self alloc] init];
  });
  
  return sharedYosWallet;
}

#pragma Private Methods

- (BOOL)_loadWallet {
  if (self.privateKeyRef != nil && self.publicKeyRef != nil) {
    return YES;
  }
  
  self.privateKeyRef = [self _lookupPrivateKeyRef];
  
  if (!self.privateKeyRef) {
    return NO;
  }
  
  self.publicKeyRef = SecKeyCopyPublicKey(self.privateKeyRef);
  
  return YES;
}

- (bool)_generateTouchIDKeyPair {
  
  CFErrorRef error = NULL;
  
  SecAccessControlRef sacObject = SecAccessControlCreateWithFlags(
                                                                  kCFAllocatorDefault,
                                                                  kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                                  kSecAccessControlPrivateKeyUsage,
                                                                  &error);
  
  if (error != errSecSuccess) {
    NSLog(@"Generate key error: %@\n", error);
  }
  
  return [self _generateKeyPairWithAccessControlObject:sacObject];
}

- (bool)_generateKeyPairWithAccessControlObject:(SecAccessControlRef)accessControlRef {
  CFMutableDictionaryRef accessControlDict = newCFDict;
  CFDictionaryAddValue(accessControlDict, kSecAttrAccessControl, accessControlRef);
  CFDictionaryAddValue(accessControlDict, kSecAttrIsPermanent, kCFBooleanTrue);
  CFDictionaryAddValue(accessControlDict, kSecAttrLabel, kPrivateKeyName);
  
  CFMutableDictionaryRef generatePairRef = newCFDict;
  CFDictionaryAddValue(generatePairRef, kSecAttrTokenID, kSecAttrTokenIDSecureEnclave);
  CFDictionaryAddValue(generatePairRef, kSecAttrKeyType, kSecAttrKeyTypeECSECPrimeRandom);
  CFDictionaryAddValue(generatePairRef, kSecAttrKeySizeInBits, (__bridge const void *)([NSNumber numberWithInt:256]));
  CFDictionaryAddValue(generatePairRef, kSecPrivateKeyAttrs, accessControlDict);
  
  CFErrorRef error = NULL;
  
  SecKeyCreateRandomKey(generatePairRef, &error);
  
  if (error) {
    NSLog(@"%@", (__bridge NSError *)error);
    return NO;
  }
  
  return YES;
}

- (SecKeyRef)_lookupPrivateKeyRef {
  CFMutableDictionaryRef getPrivateKeyRef = newCFDict;
  CFDictionarySetValue(getPrivateKeyRef, kSecClass, kSecClassKey);
  CFDictionarySetValue(getPrivateKeyRef, kSecAttrKeyClass, kSecAttrKeyClassPrivate);
  CFDictionarySetValue(getPrivateKeyRef, kSecAttrLabel, kPrivateKeyName);
  CFDictionarySetValue(getPrivateKeyRef, kSecReturnRef, kCFBooleanTrue);
  
  SecKeyRef privateKeyRef;
  
  OSStatus status = SecItemCopyMatching(getPrivateKeyRef, (CFTypeRef *)&privateKeyRef);
  
  if (status == errSecSuccess)
    return privateKeyRef;
  else if (status == errSecItemNotFound)
    return nil;
  else
    [NSException raise:@"LookUpPrivateKeyException" format:@"Status: %i", (int)status];
  
  return nil;
}

- (void)_deletePrivateKey {
  CFMutableDictionaryRef deletePrivateKeyRef = newCFDict;
  CFDictionarySetValue(deletePrivateKeyRef, kSecClass, kSecClassKey);
  CFDictionarySetValue(deletePrivateKeyRef, kSecAttrKeyClass, kSecAttrKeyClassPrivate);
  CFDictionarySetValue(deletePrivateKeyRef, kSecAttrLabel, kPrivateKeyName);
  CFDictionarySetValue(deletePrivateKeyRef, kSecReturnRef, kCFBooleanTrue);
  
  OSStatus status = SecItemDelete(deletePrivateKeyRef);
  
  if (status != errSecSuccess)
    [NSException raise:@"DeletePrivateKeyException" format:@"Status: %i", (int)status];
}

- (void)_assertWalletUnlocked {
  if (self.isLocked) {
    [NSException raise:@"GetPublicKeyException" format:@"Wallet is locked"];
  }
}

- (void)_addCredential:(NSString *)credential {
  NSData *pwData = [[NSString stringWithFormat:@"%@%@", credential, Salt] dataUsingEncoding:NSUTF8StringEncoding];
  
  NSMutableData *pwHash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(pwData.bytes, (uint32_t)pwData.length, pwHash.mutableBytes);
  
  CFMutableDictionaryRef addCredentialQuery = newCFDict;
  CFDictionarySetValue(addCredentialQuery, kSecClass, kSecClassGenericPassword);
  CFDictionarySetValue(addCredentialQuery, kSecAttrAccount, (__bridge CFStringRef)CredentialAccount);
  CFDictionarySetValue(addCredentialQuery, kSecValueData, (__bridge CFDataRef)pwHash);
  
  OSStatus status = SecItemAdd(addCredentialQuery, nil);
  
  YOSDataClear(pwData);
  YOSDataClear(pwHash);
  
  if (status != errSecSuccess) {
    [NSException raise:@"AddCredentialException" format:@"Status: %i", (int)status];
  }
}

- (NSData *)_readCredential {
  CFMutableDictionaryRef readCredentialQuery = newCFDict;
  CFDictionarySetValue(readCredentialQuery, kSecClass, kSecClassGenericPassword);
  CFDictionarySetValue(readCredentialQuery, kSecAttrAccount, (__bridge CFStringRef)CredentialAccount);
  CFDictionarySetValue(readCredentialQuery, kSecMatchLimit, kSecMatchLimitOne);
  CFDictionarySetValue(readCredentialQuery, kSecReturnAttributes, kCFBooleanTrue);
  CFDictionarySetValue(readCredentialQuery, kSecReturnData, kCFBooleanTrue);
  
  CFTypeRef result;
  
  OSStatus status = SecItemCopyMatching(readCredentialQuery, &result);
  
  if (status == errSecSuccess) {
    NSDictionary *resultDic = (__bridge NSDictionary *)result;
    return [resultDic objectForKey:(__bridge id)kSecValueData];
  }
  
  return nil;
}

- (void)_deleteCredential {
  CFMutableDictionaryRef deleteCredentialQuery = newCFDict;
  CFDictionarySetValue(deleteCredentialQuery, kSecClass, kSecClassGenericPassword);
  CFDictionarySetValue(deleteCredentialQuery, kSecAttrAccount, (__bridge CFStringRef)CredentialAccount);
  
  OSStatus status = SecItemDelete(deleteCredentialQuery);
  
  if (status != errSecSuccess)
    [NSException raise:@"DeleteCredentialException" format:@"Status: %i", (int)status];
}

- (BOOL)_verifyCredential:(NSString *)credential {
  
  NSData *pwData = [[NSString stringWithFormat:@"%@%@", credential, Salt] dataUsingEncoding:NSUTF8StringEncoding];
  
  NSMutableData *pwHash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(pwData.bytes, (uint32_t)pwData.length, pwHash.mutableBytes);
  
  NSData *readPwData = [self _readCredential];
  
  BOOL success = NO;
  
  if ([pwHash isEqualToData:readPwData]) {
    success = YES;
  }
  
  YOSDataClear(pwData);
  YOSDataClear(pwHash);
  
  return success;
}

#pragma Public Methods

- (id)init {
  if (self = [super init]) {
    self.isLocked = YES;
  }
  
  return self;
}

- (BOOL)createWallet:(NSString *)password {
  
  if ([self _readCredential] != nil) {
    return NO;
  }
  
  @try {
    [self _addCredential:password];
    [self _generateTouchIDKeyPair];
    if ([self _loadWallet]) {
      self.isLocked = NO;
    }
  } @catch (NSException *exception) {
    NSLog(@"%@", [exception reason]);
  } @finally {
    if (self.isLocked) {
      return NO;
    } else {
      return YES;
    }
  }
}

- (void)deleteWallet {
  [self _deleteCredential];
  [self _deletePrivateKey];
  
  self.isLocked = YES;
  self.privateKeyRef = nil;
  self.publicKeyRef = nil;
}

- (void)lock {
  self.isLocked = YES;
  
  self.privateKeyRef = nil;
  self.publicKeyRef = nil;
}

- (void)unlock:(NSString *)password {
  @try {
    if ([self _verifyCredential:password]) {
      if (![self _loadWallet]) {
        [NSException raise:@"LoadingWalletException" format:@""];
      }
      
      self.isLocked = NO;
    }
  } @catch (NSException *exception) {
    NSLog(@"%@", [exception reason]);
  }
}

- (NSString *)getPublicKey {
  
  [self _assertWalletUnlocked];
  
  SecKeyRef publicKeyRef = self.publicKeyRef;
  
  if (publicKeyRef == nil) {
    return nil;
  }
  
  CFErrorRef error = NULL;
  
  NSData *publicKeyData = (__bridge NSData *)SecKeyCopyExternalRepresentation(publicKeyRef, &error);
  
  if (error) {
    NSLog(@"%@", (__bridge NSError *)error);
    return nil;
  }
  
  return [[[YosPublicKey alloc] initWithPublicKeyData:publicKeyData] base58EncodedKey];
}

- (void)sign:(NSData *)digest withCompletion:(void(^)(NSString *, NSError *)) completion {
  
  [self _assertWalletUnlocked];
  
  SecKeyRef privateKeyRef = self.privateKeyRef;
  SecKeyRef publicKeyRef = self.publicKeyRef;
  
  if (privateKeyRef == nil || publicKeyRef == nil) {
    completion(nil, [NSError errorWithDomain:WalletErrorDomain code:WalletErrorNoKeyPairFound userInfo:nil]);
    return;
  }
  
  uint8_t digestDataByte[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(digest.bytes, (uint32_t)digest.length, digestDataByte);
  
  CFErrorRef error = NULL;
  
  NSData *publicKeyData = (__bridge NSData *)SecKeyCopyExternalRepresentation(publicKeyRef, &error);
  
  if (error) {
    completion(nil, (__bridge NSError *)error);
  }
  
  NSLog(@"Public key raw bits:\n%@", publicKeyData);
  
  Boolean result = SecKeyIsAlgorithmSupported(privateKeyRef, kSecKeyOperationTypeSign, kSecKeyAlgorithmECDSASignatureDigestX962SHA256);
  
  if (!result) {
    completion(nil, nil);
    return;
  }
  
  NSData *digestData2 = [NSData dataWithData:(__bridge NSData *)CFDataCreate(NULL, (UInt8*)digestDataByte, CC_SHA256_DIGEST_LENGTH)];
  NSLog(@"digestData:%@", digestData2);
  
  NSData *signature = (__bridge NSData *)SecKeyCreateSignature(privateKeyRef, kSecKeyAlgorithmECDSASignatureDigestX962SHA256, CFDataCreate(NULL, (UInt8*)digestDataByte, CC_SHA256_DIGEST_LENGTH), &error);
  
  uint8_t sig_asn1[64];
  
  ecdsa_der_to_sig((uint8_t *)signature.bytes, sig_asn1);
  
  NSLog(@"sig_asn1:%@", [NSData dataWithBytes:sig_asn1 length:64]);
  
  const ecdsa_curve *curve = &secp256r1;
  
  uint8_t sig_asn1_s[32];
  memcpy(sig_asn1_s, sig_asn1 + 32, 32);
  
  NSLog(@"sig_asn1_s:%@", [NSData dataWithBytes:sig_asn1_s length:32]);
  
  bignum256 s_big;
  
  bn_read_be(sig_asn1_s, &s_big);
  
  if (bn_is_less(&secp256r1.order_half, &s_big)) {
    bignum256 result;
    bn_subtract(&secp256r1.order, &s_big, &result);
    bn_write_be(&result, sig_asn1 + 32);
  }
  
  int i;
  int recId = -1;
  const uint8_t *pub_key_bytes = publicKeyData.bytes;
  uint8_t rec_pubkey[65];
  for (i = 0; i < 4; i++) {
    ecdsa_recover_pub_from_sig(curve, rec_pubkey, sig_asn1, digestDataByte, i);
    
    NSLog(@"rec_pubkey:%@ with recId:%d", [NSData dataWithBytes:rec_pubkey length:65], i);
    
    if (memcmp(rec_pubkey, pub_key_bytes, 65) == 0) {
      recId = i;
      break;
    }
  }
  
  if (recId == -1) {
    completion(nil, nil);
  } else {
    uint8_t compact_sig[65];
    memset(compact_sig, (recId + 27 + 4), 1);
    memcpy(compact_sig + 1, sig_asn1, 64);
    completion([NSString stringWithFormat:@"SIG_R1_%@", [YosEcUtil encodeBase58CheckStringWithData:[NSData dataWithBytes:compact_sig length:65]]], nil);
  }
}

- (void)dealloc {
  if (self.privateKeyRef) {
    CFRelease(self.privateKeyRef);
  }
  
  if (self.publicKeyRef) {
    CFRelease(self.publicKeyRef);
  }
}

@end
