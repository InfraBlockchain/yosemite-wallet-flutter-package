#import "YosemiteWalletPlugin.h"
#import "YosWallet.h"
#import "YosPublicKey.h"

@implementation YosemiteWalletPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"com.yosemitex.yosemite_wallet"
            binaryMessenger:[registrar messenger]];
  YosemiteWalletPlugin* instance = [[YosemiteWalletPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (id)init {
  if (self = [super init]) {
  }
  
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  
  if ([@"create" isEqualToString:call.method]) {
    SecKeyRef privateKeyRef = [YosWallet lookupPrivateKeyRef];
    
    if (privateKeyRef == nil) {
      [YosWallet generateTouchIDKeyPair];
      privateKeyRef = [YosWallet lookupPrivateKeyRef];
    }
    
    SecKeyRef publicKeyRef = SecKeyCopyPublicKey(privateKeyRef);
    
    CFErrorRef error = NULL;
    
    NSData *publicKeyData = (__bridge NSData *)SecKeyCopyExternalRepresentation(publicKeyRef, &error);
    
    NSString *publicKeyString = [[[YosPublicKey alloc] initWithPublicKeyData:publicKeyData] base58EncodedKey];
    
    NSLog(@"PublicKey: %@", publicKeyString);
    
    result(publicKeyString);
  } else if ([@"getPublicKey" isEqualToString:call.method]) {
    SecKeyRef publicKeyRef = [YosWallet lookupPublicKeyRef];
    
    CFErrorRef error = NULL;
    
    NSData *publicKeyData = (__bridge NSData *)SecKeyCopyExternalRepresentation(publicKeyRef, &error);
    
    NSString *publicKeyString = [[[YosPublicKey alloc] initWithPublicKeyData:publicKeyData] base58EncodedKey];
    
    NSLog(@"PublicKey: %@", publicKeyString);
    
    result(publicKeyString);
  } else if ([@"signMessageData" isEqualToString:call.method]) {
    FlutterStandardTypedData *bytes = call.arguments[@"data"];
    
    [YosWallet generateSignatureForData:bytes.data withCompletion:^(NSString *signature, NSError *err) {
      if (signature != nil) {
        NSLog(@"[EOS Compatible] Signature for data: %@", signature);
        NSLog(@"");
        result(signature);
      } else {
        NSLog(@"Error: %@", err);
      }
    }];
  }
  
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
