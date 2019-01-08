import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:yosemite_wallet/pack/packer.dart';
import 'package:yosemite_wallet/pack/byteWriter.dart';

@immutable
class TransactionExtension implements Packer {
  static final int TransactionVoteAccount = 1001;
  static final int DelegatedTransactionFeePayer = 1002;

  final int field; // uint16_t
  final Uint8List data;

  TransactionExtension(this.field, this.data);

  List toJson() {
    final dataInHexStr =
        data.fold('', (prev, elem) => '$prev${elem.toRadixString(16).padLeft(2, '0')}');
    return [field, dataInHexStr];
  }

  @override
  void pack(ByteWriter byteWriter) {
    byteWriter.putUint16(field);
    byteWriter.putVariableUint(data.lengthInBytes);
    byteWriter.putUint8List(data);
  }
}
