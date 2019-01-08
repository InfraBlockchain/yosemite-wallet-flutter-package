import 'package:meta/meta.dart';
import 'package:yosemite_wallet/models/typeName.dart';
import 'package:yosemite_wallet/pack/packer.dart';
import 'package:yosemite_wallet/pack/byteWriter.dart';

@immutable
class Authorization implements Packer {
  final TypeName actor;
  final TypeName permission;

  Authorization(String actor, String permission)
      : this.actor = TypeName(actor),
        this.permission = TypeName(permission);

  Map<String, dynamic> toJson() => {'actor': actor.toString(), 'permission': permission.toString()};

  @override
  void pack(ByteWriter byteWriter) {
    actor.pack(byteWriter);
    permission.pack(byteWriter);
  }
}
