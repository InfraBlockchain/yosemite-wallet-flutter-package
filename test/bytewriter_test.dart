import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:yosemite_wallet/models/action.dart';
import 'package:yosemite_wallet/models/authorization.dart';
import 'package:yosemite_wallet/models/transactionExtension.dart';
import 'package:yosemite_wallet/models/typeName.dart';
import 'package:yosemite_wallet/pack/byteWriter.dart';

void main() {
  test('Byte writer test', () {
    String headBlockId = '00b2e365f1519017104e87b28a533f8ab31fae16a3580b767e087ffbac50ca41';
    String expiration = '2018-12-09T13:50:08.500';

    ByteWriter byteWriter = ByteWriter(endian: Endian.little);

//    Action action = Action(
//        account: 'yx.ntoken',
//        name: 'transfer',
//        authorization: [Authorization('useraccount1', 'active')],
//        data: '902865015e53157da090db57e1740df2e8030000000000000243524400000000902865015e53157d00');
//    action.pack(byteWriter);

//    TypeName typeName = TypeName('useraccount1');
//    TransactionExtension tx = TransactionExtension(TransactionExtension.TransactionVoteAccount, typeName.nameInHex);
//    tx.pack(byteWriter);

    ByteData bd = byteWriter.done();

    print('ByteData:' + bd.buffer.lengthInBytes.toString());
    Uint8List data = Uint8List.view(bd.buffer, 0, bd.lengthInBytes);
    print('data:' + data.lengthInBytes.toString());
    final dataInHexStr =
        data.fold('', (prev, elem) => '$prev${elem.toRadixString(16).padLeft(2, '0')}');
    print(dataInHexStr);
    final count = 1;
    expect(count, 1);
  });
}
