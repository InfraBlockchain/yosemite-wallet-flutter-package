import 'package:meta/meta.dart';

@immutable
class Authorization {
  final String actor;
  final String permission;

  Authorization(this.actor, this.permission);

  Map<String, dynamic> toJson() => {'actor': actor, 'permission': permission};
}
