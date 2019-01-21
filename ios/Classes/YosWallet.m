//
//  YosWallet.m
//  YosWalletTest
//
//  Created by Joe Park on 18/01/2019.
//  Copyright © 2019 Joe Park. All rights reserved.
//

#import "YosWallet.h"
#import "YosPublicKey.h"
#include "bignum.h"
#include "ecdsa.h"
#include "secp256r1.h"
#include "YosEcUtil.h"

#import <CommonCrypto/CommonDigest.h>

#define newCFDict CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks)
#define kPrivateKeyName @"com.yosemitex.wallet.private"
#define kPublicKeyName @"com.yosemitex.wallet.public"

@implementation YosWallet

static SecKeyRef publicKeyRef;
static SecKeyRef privateKeyRef;

+ (bool)generateTouchIDKeyPair {
  CFErrorRef error = NULL;
  
  SecAccessControlRef sacObject = SecAccessControlCreateWithFlags(
                                                                  kCFAllocatorDefault,
                                                                  kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                                  kSecAccessControlTouchIDAny | kSecAccessControlPrivateKeyUsage,
                                                                  &error);
  
  if (error != errSecSuccess) {
    NSLog(@"Generate key error: %@\n", error);
  }
  
  return [self generateKeyPairWithAccessControlObject:sacObject];
}

+ (bool)generateKeyPairWithAccessControlObject:(SecAccessControlRef)accessControlRef {
  CFMutableDictionaryRef accessControlDict = newCFDict;
  CFDictionaryAddValue(accessControlDict, kSecAttrAccessControl, accessControlRef);
  CFDictionaryAddValue(accessControlDict, kSecAttrIsPermanent, kCFBooleanTrue);
  CFDictionaryAddValue(accessControlDict, kSecAttrLabel, kPrivateKeyName);
  
  CFMutableDictionaryRef generatePairRef = newCFDict;
  CFDictionaryAddValue(generatePairRef, kSecAttrTokenID, kSecAttrTokenIDSecureEnclave);
  CFDictionaryAddValue(generatePairRef, kSecAttrKeyType, kSecAttrKeyTypeEC);
  CFDictionaryAddValue(generatePairRef, kSecAttrKeySizeInBits, (__bridge const void *)([NSNumber numberWithInt:256]));
  CFDictionaryAddValue(generatePairRef, kSecPrivateKeyAttrs, accessControlDict);
  
  CFErrorRef error = NULL;
  
  privateKeyRef = SecKeyCreateRandomKey(generatePairRef, &error);
  
  publicKeyRef = SecKeyCopyPublicKey(privateKeyRef);
  
  [self savePublicKeyFromRef:publicKeyRef];
  return YES;
}

+ (bool)savePublicKeyFromRef:(SecKeyRef)publicKeyRef {
  CFTypeRef keyBits;
  CFMutableDictionaryRef savePublicKeyDict = newCFDict;
  CFDictionaryAddValue(savePublicKeyDict, kSecClass, kSecClassKey);
  CFDictionaryAddValue(savePublicKeyDict, kSecAttrKeyType, kSecAttrKeyTypeEC);
  CFDictionaryAddValue(savePublicKeyDict, kSecAttrKeyClass, kSecAttrKeyClassPublic);
  CFDictionaryAddValue(savePublicKeyDict, kSecAttrApplicationTag, kPublicKeyName);
  CFDictionaryAddValue(savePublicKeyDict, kSecValueRef, publicKeyRef);
  CFDictionaryAddValue(savePublicKeyDict, kSecAttrIsPermanent, kCFBooleanTrue);
  CFDictionaryAddValue(savePublicKeyDict, kSecReturnData, kCFBooleanTrue);
  
  OSStatus err = SecItemAdd(savePublicKeyDict, &keyBits);
  if (err == errSecDuplicateItem) {
    SecItemDelete(savePublicKeyDict);
  }
  err = SecItemAdd(savePublicKeyDict, &keyBits);
  
  return YES;
}

+ (SecKeyRef)lookupPublicKeyRef {
  
  CFMutableDictionaryRef getPublicKeyQuery = newCFDict;
  CFDictionarySetValue(getPublicKeyQuery, kSecClass,                kSecClassKey);
  CFDictionarySetValue(getPublicKeyQuery, kSecAttrKeyType,          kSecAttrKeyTypeEC);
  CFDictionarySetValue(getPublicKeyQuery, kSecAttrApplicationTag,   kPublicKeyName);
  CFDictionarySetValue(getPublicKeyQuery, kSecAttrKeyClass,         kSecAttrKeyClassPublic);
  CFDictionarySetValue(getPublicKeyQuery, kSecReturnData,           kCFBooleanTrue);
  CFDictionarySetValue(getPublicKeyQuery, kSecReturnPersistentRef,  kCFBooleanTrue);
  
  OSStatus status = SecItemCopyMatching(getPublicKeyQuery, (CFTypeRef *)&publicKeyRef);
  
  if (status == errSecSuccess)
    return (SecKeyRef)publicKeyRef;
  else if (status == errSecItemNotFound)
    return nil;
  else
    [NSException raise:@"Unexpected OSStatus" format:@"Status: %i", status];
  return false;
}

+ (SecKeyRef)lookupPrivateKeyRef {
  CFMutableDictionaryRef getPrivateKeyRef = newCFDict;
  CFDictionarySetValue(getPrivateKeyRef, kSecClass, kSecClassKey);
  CFDictionarySetValue(getPrivateKeyRef, kSecAttrKeyClass, kSecAttrKeyClassPrivate);
  CFDictionarySetValue(getPrivateKeyRef, kSecAttrLabel, kPrivateKeyName);
  CFDictionarySetValue(getPrivateKeyRef, kSecReturnRef, kCFBooleanTrue);
  CFDictionarySetValue(getPrivateKeyRef, kSecUseOperationPrompt, @"autneticate to sign data");
  
  OSStatus status = SecItemCopyMatching(getPrivateKeyRef, (CFTypeRef *)&privateKeyRef);
  if (status == errSecItemNotFound)
    return nil;
  
  return (SecKeyRef)privateKeyRef;
}

+ (void)generateSignatureForData:(NSData *)inputData withCompletion:(void(^)(NSString *, NSError *)) completion {
  
  uint8_t digestData[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(inputData.bytes, (uint32_t)inputData.length, digestData);
  
  SecKeyRef _privateKeyRef = [self lookupPrivateKeyRef];
  
  SecKeyRef _publicKeyRef = SecKeyCopyPublicKey(_privateKeyRef);
  
  CFErrorRef error = NULL;
  
  NSData *publicKeyData = (__bridge NSData *)SecKeyCopyExternalRepresentation(_publicKeyRef, &error);
  
  NSLog(@"Public key raw bits:\n%@", publicKeyData);
  
  Boolean result = SecKeyIsAlgorithmSupported(_privateKeyRef, kSecKeyOperationTypeSign, kSecKeyAlgorithmECDSASignatureDigestX962SHA256);
  
  NSData *digestData2 = [NSData dataWithData:(__bridge NSData *)CFDataCreate(NULL, (UInt8*)digestData, CC_SHA256_DIGEST_LENGTH)];
  NSLog(@"digestData:%@", digestData2);
  
  NSData *signature = (__bridge NSData *)SecKeyCreateSignature(_privateKeyRef, kSecKeyAlgorithmECDSASignatureDigestX962SHA256, CFDataCreate(NULL, (UInt8*)digestData, CC_SHA256_DIGEST_LENGTH), &error);
  
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
    ecdsa_recover_pub_from_sig(curve, rec_pubkey, sig_asn1, digestData, i);
    
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

@end
