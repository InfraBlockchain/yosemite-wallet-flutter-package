import 'package:meta/meta.dart';
import 'package:yosemite_wallet/models/authorization.dart';

@immutable
class Action {
  final String account;
  final String name;
  final List<Authorization> authorization;
  final String data;

  Action(this.account, this.name, this.authorization, this.data);

  Map<String, dynamic> toJson() =>
      {'account': account, 'name': name, 'authorization': authorization, 'data': data};
}
