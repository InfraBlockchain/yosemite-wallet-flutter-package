import 'dart:async';

import 'package:flutter/services.dart';

class YosemiteWallet {
  static const MethodChannel _channel = const MethodChannel('com.yosemitex.yosemite_wallet');

  static Future<String> create(String password) async {
    return await _channel.invokeMethod('create', {'password': password});
  }

  static Future<void> lock() async {
    await _channel.invokeMethod('lock');
  }

  static Future<void> unlock(String password) async {
    await _channel.invokeMethod('unlock', {'password': password});
  }

  static Future<String> sign(String data) async {
    return await _channel.invokeMethod('sign', {'data': data});
  }

  static Future<String> getPublicKey() async {
    return await _channel.invokeMethod('getPublicKey');
  }

  static Future<bool> isLocked() async {
    return await _channel.invokeMethod('isLocked');
  }
}
