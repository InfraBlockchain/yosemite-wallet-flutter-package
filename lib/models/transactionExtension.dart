import 'dart:typed_data';

import 'package:meta/meta.dart';

@immutable
class TransactionExtension {
  static final int TransactionVoteAccount = 1001;
  static final int DelegatedTransactionFeePayer = 1002;

  final int field;
  final Uint8List data;

  TransactionExtension(this.field, this.data);

  List toJson() {
    final dataInHexStr =
        data.fold('', (prev, elem) => '$prev${elem.toRadixString(16).padLeft(2, '0')}');
    return [field, dataInHexStr];
  }
}
