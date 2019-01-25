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
    
    NSString *password = call.arguments[@"password"];
    
    @try {
      [[YosWallet sharedManager] deleteWallet];
      [[YosWallet sharedManager] createWallet:password];
      result([[YosWallet sharedManager] getPublicKey]);
    } @catch (NSException *exception) {
      NSLog(@"%@", [exception reason]);
    }
  } else if ([@"getPublicKey" isEqualToString:call.method]) {
    result([[YosWallet sharedManager] getPublicKey]);
  } else if ([@"lock" isEqualToString:call.method]) {
    [[YosWallet sharedManager] lock];
  } else if ([@"unlock" isEqualToString:call.method]) {
    NSString *password = call.arguments[@"password"];
    [[YosWallet sharedManager] unlock:password];
  } else if ([@"isLocked" isEqualToString:call.method]) {
    BOOL isLocked = [[YosWallet  sharedManager] isLocked];
    result([NSNumber numberWithBool:isLocked]);
  } else if ([@"signMessageData" isEqualToString:call.method]) {
    FlutterStandardTypedData *bytes = call.arguments[@"data"];
    
    [[YosWallet sharedManager] sign:bytes.data withCompletion:^(NSString *signature, NSError *err) {
      result(signature);
    }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
