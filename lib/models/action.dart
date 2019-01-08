import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:meta/meta.dart';
import 'package:yosemite_wallet/models/authorization.dart';
import 'package:yosemite_wallet/models/typeName.dart';
import 'package:yosemite_wallet/pack/packer.dart';
import 'package:yosemite_wallet/pack/byteWriter.dart';

@immutable
class Action implements Packer {
  final TypeName account;
  final TypeName name;
  final List<Authorization> authorization;
  final String data;

  Action({String account, String name, this.authorization, this.data})
      : this.account = TypeName(account),
        this.name = TypeName(name);

  Map<String, dynamic> toJson() => {
        'account': account.toString(),
        'name': name.toString(),
        'authorization': authorization,
        'data': data
      };

  @override
  void pack(ByteWriter byteWriter) {
    account.pack(byteWriter);
    name.pack(byteWriter);

    byteWriter.putPackerList(authorization);

    if (data != null) {
      var dataAsBytes = hex.decode(data);
      byteWriter.putVariableUint(dataAsBytes.length);
      byteWriter.putUint8List(Uint8List.fromList(dataAsBytes));
    } else {
      byteWriter.putVariableUint(0);
    }
  }
}
