import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yosemite_wallet/yosemite_wallet.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _pubKey = 'Unknown';

  @override
  void initState() {
    super.initState();
    //initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
//  Future<void> initPlatformState() async {
//    String platformVersion;
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      platformVersion = await YosemiteWallet.platformVersion;
//    } on PlatformException {
//      platformVersion = 'Failed to get platform version.';
//    }
//
//    // If the widget was removed from the tree while the asynchronous platform
//    // message was in flight, we want to discard the reply rather than calling
//    // setState to update our non-existent appearance.
//    if (!mounted) return;
//
//    setState(() {
//      _platformVersion = platformVersion;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Container(
                child: MaterialButton(
                  onPressed: walletText,
                  child: Text('Create Wallet'),
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Text(_pubKey)
            ],
          ),
        ),
      ),
    );
  }

  Future walletText() async {
    String pubKey = await YosemiteWallet.create("wow");

    print('PubKey: $pubKey');

    setState(() {
      _pubKey = pubKey;
    });
  }
}
