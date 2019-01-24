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
    
    if (![[YosWallet sharedManager] loadWallet]) {
      [[YosWallet sharedManager] createWallet];
    }
    
    result([[YosWallet sharedManager] getPublicKey]);
  } else if ([@"getPublicKey" isEqualToString:call.method]) {
    result([[YosWallet sharedManager] getPublicKey]);
  } else if ([@"lock" isEqualToString:call.method]) {
    
  } else if ([@"unlock" isEqualToString:call.method]) {
    
  } else if ([@"isLocked" isEqualToString:call.method]) {
    
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
