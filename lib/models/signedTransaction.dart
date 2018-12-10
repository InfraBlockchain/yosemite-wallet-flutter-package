import 'package:yosemite_wallet/models/transaction.dart';

class SignedTransaction extends Transaction {
  List<String> signatures;
  List<String> contextFreeData;

  SignedTransaction()
      : signatures = [],
        contextFreeData = [];

  Map<String, dynamic> toJson() {
    var json = super.toJson();

    json.addAll({'signatures': signatures, 'context_free_data': contextFreeData});

    return json;
  }
}
