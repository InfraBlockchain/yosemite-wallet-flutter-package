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
              Container(
                child: MaterialButton(
                  onPressed: signTransaction,
                  child: Text('Sign tx'),
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

  Future signTransaction() async {

    print('Before sign...');

    String txToSign = '{"expiration":"2018-12-07T08:37:40.500","ref_block_num":0,"ref_block_prefix":0,"max_net_usage_word":0,"max_cpu_usage_ms":0,"delay_sec":0,"context_free_actions":[],"actions":[{"account":"yx.token","name":"transfer","authorization":[{"actor":"joepark1good","permission":"active"}],"data":"902865015e53157da090db57e1740df2e8030000000000000243524400000000902865015e53157d00"}],"transaction_extensions":[],"signatures":[],"context_free_data":[]}';

    String chainId = '6376573815dbd2de2d9929027a94aeab3f6e60e87caa953f94ee701ac8425811';

    String signedTx = await YosemiteWallet.signTransaction(txToSign, chainId);

    print('After sign...');
    print(signedTx);
  }
}
