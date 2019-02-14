import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:yosemite_wallet/yosemite_chain.dart';

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
              Expanded(
                flex: 1,
                child: ListView(
                  children: <Widget>[
                    Container(
                      child: MaterialButton(
                        onPressed: createWallet,
                        child: Text('Create Wallet'),
                      ),
                      padding: const EdgeInsets.all(8.0),
                    ),
                    Container(
                      child: MaterialButton(
                        onPressed: deleteWallet,
                        child: Text('Delete Wallet'),
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
                        onPressed: signMessageData,
                        child: Text('Sign message data'),
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
              )
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

  Future deleteWallet() async {
    await YosemiteWallet.delete();

    setState(() {
      state = 'Wallet deleted';
    });
  }

  Future checkWalletStatus() async {
    bool isExist = await YosemiteWallet.isExist();

    if (isExist) {
      bool isLocked = await YosemiteWallet.isLocked();

      setState(() {
        state = 'isLocked: ${isLocked.toString()}';
      });
    } else {
      setState(() {
        state = 'Wallet doesn\'t exist';
      });
    }
  }

  Future signMessageData() async {
    String signature =
        await YosemiteWallet.signMessageData(Uint8List.fromList([0x01, 0x02, 0x03, 0x04]));

    setState(() {
      state = 'Signature: $signature';
    });
  }

  Future signTransaction() async {
    ChainService chainService = ChainService('http://testnet-sentinel.yosemitelabs.org:8888');

    final String contract = 'systoken.a';
    final String action = 'transfer';
    final String myAccountName = 'useraccountk';
    final String toAccountName = 'useraccounta';
    final List<Authorization> authorizations = [Authorization(myAccountName, 'active')];

    var txData = {
      't': contract,
      'from': myAccountName,
      'to': toAccountName,
      'qty': '1.0000 DUSD',
      'tag': 'This is the tx from Secure Enclave'
    };

    Future.wait([chainService.getChainInfo(), chainService.getAbi('yx.tokenabi', action, txData)])
        .then((List responses) {
      final chainInfoRes = responses[0];
      final abiRes = responses[1];

      Action actionReq =
          Action(account: contract, name: action, authorization: authorizations, data: abiRes);

      SignedTransaction txnBeforeSign = SignedTransaction();
      txnBeforeSign.addAction(actionReq);
      txnBeforeSign.addStringTransactionExtension(
          TransactionExtension.TransactionVoteAccount, 'producer.a');
      txnBeforeSign.addStringTransactionExtension(
          TransactionExtension.DelegatedTransactionFeePayer, myAccountName);
      txnBeforeSign.referenceBlock = chainInfoRes.headBlockId;
      txnBeforeSign.expiration = chainInfoRes.addTimeAfterHeadBlockTimeByMin(10);

      Uint8List packedBytesToSign = txnBeforeSign.getDigestForSignature(chainInfoRes.chainId);

      final dataInHexStr = packedBytesToSign.fold(
          '', (prev, elem) => '$prev${elem.toRadixString(16).padLeft(2, '0')}');

      print('Packed tx to sign: ' + dataInHexStr);

      return YosemiteWallet.signMessageData(packedBytesToSign).then((signature) {
        txnBeforeSign.addSignature(signature);
        return txnBeforeSign;
      });
    }).then((SignedTransaction signedTx) {
      // create a PackedTransaction
      PackedTransaction packedTransaction = PackedTransaction(signedTx);
      String stringifiedPackedTx = json.encode(packedTransaction.toJson());
      print('Packed tx to push: ' + stringifiedPackedTx);
    });
  }
}
