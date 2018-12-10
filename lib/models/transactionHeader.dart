import 'dart:typed_data';

import 'package:convert/convert.dart';

abstract class TransactionHeader {
  String _expiration;
  int _refBlockNum;
  int _refBlockPrefix;
  int _maxNetUsageWord;
  int _maxCpuUsageMs;
  int _delaySec;

  TransactionHeader()
      : this._refBlockNum = 0,
        this._refBlockPrefix = 0,
        this._maxCpuUsageMs = 0,
        this._maxNetUsageWord = 0,
        this._delaySec = 0;

  set expiration(String expiration) {
    _expiration = expiration;
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
}
