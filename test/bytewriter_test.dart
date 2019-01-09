import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:yosemite_wallet/models/action.dart';
import 'package:yosemite_wallet/models/authorization.dart';
import 'package:yosemite_wallet/models/signedTransaction.dart';
import 'package:yosemite_wallet/models/transactionExtension.dart';

void main() {
  test('Byte writer test', () {

    String expectedByteData =
        '047316f411b2db9ba0f600fdbca8e3bbd224d82a367ff02fbd355bb0675288e32a84355cf0eaffafdd87000000000100800153419ab1c70000000000a531760100800153419ab1c700000000a8ed32322500800153419ab1c7902865015e53157d10270000000000000444555344000000047465737402e9030800800157219de8adea030800800153419ab1c70000000000000000000000000000000000000000000000000000000000000000';

    String chainId = '047316f411b2db9ba0f600fdbca8e3bbd224d82a367ff02fbd355bb0675288e3';
    String headBlockId = '001feaf0f02495bcffafdd87bc4d03021e592d78bd94e111854832da377f1858';
    String expiration = '2019-01-09T05:18:34';

    Action action = Action(
        account: 'systoken.a',
        name: 'issue',
        authorization: [Authorization('systoken.a', 'active')],
        data: '00800153419ab1c7902865015e53157d102700000000000004445553440000000474657374');

    SignedTransaction signedTx = SignedTransaction();

    signedTx.expiration = expiration;
    signedTx.referenceBlock = headBlockId;
    signedTx.addAction(action);
    signedTx.addStringTransactionExtension(
        TransactionExtension.TransactionVoteAccount, 'producer.a');
    signedTx.addStringTransactionExtension(
        TransactionExtension.DelegatedTransactionFeePayer, 'systoken.a');

    Uint8List bytes = signedTx.getDigestForSignature(chainId);
    final dataInHexStr =
        bytes.fold('', (prev, elem) => '$prev${elem.toRadixString(16).padLeft(2, '0')}');
    
    expect(dataInHexStr, expectedByteData);
  });
}
