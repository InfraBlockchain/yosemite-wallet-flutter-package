import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yosemite_wallet/yosemite_wallet.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String state = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

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
              Text(state),
              Container(
                child: MaterialButton(
                  onPressed: createWallet,
                  child: Text('Create Wallet'),
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: MaterialButton(
                  onPressed: checkWalletStatus,
                  child: Text('Show wallet status'),
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: MaterialButton(
                  onPressed: () => YosemiteWallet.lock(),
                  child: Text('Lock the wallet'),
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: MaterialButton(
                  onPressed: () => YosemiteWallet.unlock('wow'),
                  child: Text('Unlock with correct password'),
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: MaterialButton(
                  onPressed: () => YosemiteWallet.unlock('wow2'),
                  child: Text('Unlock with incorrect password'),
                ),
                padding: const EdgeInsets.all(8.0),
              ),
              Container(
                child: MaterialButton(
                  onPressed: signData,
                  child: Text('Sign data'),
                ),
                padding: const EdgeInsets.all(8.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future createWallet() async {
    String pubKey = await YosemiteWallet.create("wow");

    setState(() {
      state = pubKey;
    });
  }

  Future checkWalletStatus() async {
    bool isLocked = await YosemiteWallet.isLocked();

    setState(() {
      state = 'isLocked: ${isLocked.toString()}';
    });
  }

  Future signData() async {
    String signature = await YosemiteWallet.sign('arbitrary data');

    setState(() {
      state = 'Signature: $signature';
    });
  }
}
