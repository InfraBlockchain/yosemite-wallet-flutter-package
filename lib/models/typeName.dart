import 'dart:typed_data';

import 'package:yosemite_wallet/pack/packer.dart';
import 'package:yosemite_wallet/pack/byteWriter.dart';

class TypeName implements Packer {
  Uint8List _value;
  String _name;

  static final String AccountNameChars = '.12345abcdefghijklmnopqrstuvwxyz';

  static final int MAX_NAME_IDX = 12;

  static int charToSymbol(final int asciiChar) {
    int char = asciiChar;
    int charA = 'a'.codeUnitAt(0);
    int charZ = 'z'.codeUnitAt(0);
    int char1 = '1'.codeUnitAt(0);
    int char5 = '5'.codeUnitAt(0);

    if (char >= charA && char <= charZ)
      return (char - charA) + 6;
    else if (char >= char1 && char <= char5)
      return (char - char1) + 1;
    else
      return 0;
  }

  static Uint8List getNameInHex(final String name) {
    if (name == null) {
      return null;
    }

    final int length = name.length;

    var value = 0;

    for (int i = 0; i <= MAX_NAME_IDX; i++) {
      var c = 0;

      if (i < length) {
        c = charToSymbol(name.codeUnitAt(i));
      }

      if (i < MAX_NAME_IDX) {
        c &= 0x1f;
        c <<= 64 - (5 * (i + 1));
      } else {
        c &= 0x0f;
      }

      value |= c;
    }

    final list = Uint64List.fromList([value.toUnsigned(64)]);

    return Uint8List.view(list.buffer);
  }

  TypeName(String name) {
    _name = name;
    _value = getNameInHex(name);
  }

  String get name => _name;

  Uint8List get nameInHex => _value;

  @override
  void pack(ByteWriter byteWriter) {
    byteWriter.putUint8List(_value);
  }

  @override
  toString() {
    return _name;
  }
}
