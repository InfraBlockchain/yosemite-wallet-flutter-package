import 'package:yosemite_wallet/models/action.dart';
import 'package:yosemite_wallet/models/transactionExtension.dart';
import 'package:yosemite_wallet/models/transactionHeader.dart';
import 'package:yosemite_wallet/models/typeName.dart';
import 'package:yosemite_wallet/pack/byteWriter.dart';

class Transaction extends TransactionHeader {
  List<Action> contextFreeActions;
  List<Action> actions;
  List<TransactionExtension> transactionExtensions;

  Transaction()
      : this.contextFreeActions = [],
        this.actions = [],
        this.transactionExtensions = [];

  addAction(Action action) {
    this.actions.add(action);
  }

  addTransactionExtension(TransactionExtension txEx) {
    this.transactionExtensions.add(txEx);
  }

  addStringTransactionExtension(int field, String value) {
    TypeName typeName = TypeName(value);
    this.transactionExtensions.add(TransactionExtension(field, typeName.nameInHex));
  }

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json.addAll({
      'context_free_actions': contextFreeActions,
      'actions': actions,
      'transaction_extensions': transactionExtensions
    });

    return json;
  }

  @override
  pack(ByteWriter byteWriter) {
    super.pack(byteWriter);

    byteWriter.putPackerList(contextFreeActions);
    byteWriter.putPackerList(actions);
    byteWriter.putPackerList(transactionExtensions);
  }
}
