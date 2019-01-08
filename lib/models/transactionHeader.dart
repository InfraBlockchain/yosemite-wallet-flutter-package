import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:yosemite_wallet/pack/packer.dart';
import 'package:yosemite_wallet/pack/byteWriter.dart';

class TransactionHeader implements Packer {
  String _expiration; // uint32_t
  int _refBlockNum; // uint16_t
  int _refBlockPrefix; // uint32_t
  int _maxNetUsageWord; // fc:unsigned_int
  int _maxCpuUsageMs; // uint8_t
  int _delaySec; // fc:unsigned_int

  TransactionHeader()
      : this._refBlockNum = 0,
        this._refBlockPrefix = 0,
        this._maxCpuUsageMs = 0,
        this._maxNetUsageWord = 0,
        this._delaySec = 0;

  set expiration(String expiration) {
    _expiration = expiration + 'Z';
  }

  set refBlockNum(int refBlockNum) {
    _refBlockNum = refBlockNum;
  }

  set refBlockPrefix(int refBlockPrefix) {
    _refBlockPrefix = refBlockPrefix;
  }

  set maxNetUsageWord(int maxNetUsageWord) {
    _maxNetUsageWord = maxNetUsageWord;
  }

  set maxCpuUsageMs(int maxCpuUsageMs) {
    _maxCpuUsageMs = maxCpuUsageMs;
  }

  set delaySec(int delaySec) {
    _delaySec = delaySec;
  }

  set referenceBlock(String referenceBlockId) {
    _refBlockNum = int.tryParse(referenceBlockId.substring(0, 8), radix: 16);

    var blockPrefixBytes = hex.decode(referenceBlockId.substring(16, 24));
    ByteData blockPrefixByteData = Uint8List.fromList(blockPrefixBytes).buffer.asByteData();

    _refBlockPrefix = blockPrefixByteData.getUint32(0, Endian.little);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'expiration': _expiration,
      'ref_block_num': _refBlockNum,
      'ref_block_prefix': _refBlockPrefix,
      'max_net_usage_word': _maxNetUsageWord,
      'max_cpu_usage_ms': _maxCpuUsageMs,
      'delay_sec': _delaySec
    };
  }

  @override
  pack(ByteWriter byteWriter) {
    DateTime dateTime = DateTime.parse(_expiration);

    var expirationInSec = dateTime.millisecondsSinceEpoch ~/ 1000;

    byteWriter.putUint32(expirationInSec);
    byteWriter.putUint16(_refBlockNum);
    byteWriter.putUint32(_refBlockPrefix);
    byteWriter.putVariableUint(_maxNetUsageWord);
    byteWriter.putVariableUint(_maxCpuUsageMs);
    byteWriter.putVariableUint(_delaySec);
  }
}
