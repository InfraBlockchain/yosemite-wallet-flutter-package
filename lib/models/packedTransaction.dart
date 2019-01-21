import 'dart:typed_data';

import 'package:yosemite_wallet/models/signedTransaction.dart';
import 'package:yosemite_wallet/models/transaction.dart';
import 'package:yosemite_wallet/pack/byteWriter.dart';

class PackedTransaction {
  final SignedTransaction signedTransaction;

  final String compression;
  final String packed_trx;
  final String packed_context_free_data;

  PackedTransaction(this.signedTransaction)
      : this.compression = 'none',
        this.packed_context_free_data = '',
        this.packed_trx = packTransaction(signedTransaction);

  static String packTransaction(SignedTransaction transaction) {
    ByteWriter byteWriter = ByteWriter(endian: Endian.little);

    transaction.packOnlyTransaction(byteWriter);
    ByteData byteData = byteWriter.done();
    Uint8List bytes = Uint8List.view(byteData.buffer, 0, byteData.lengthInBytes);

    final dataInHexStr =
        bytes.fold('', (prev, elem) => '$prev${elem.toRadixString(16).padLeft(2, '0')}');

    return dataInHexStr;
  }

  Map<String, dynamic> toJson() {
    return {
      'signatures': this.signedTransaction.signatures,
      'compression': this.compression,
      'packed_context_free_data': this.packed_context_free_data,
      'packed_trx': this.packed_trx
    };
  }
}
