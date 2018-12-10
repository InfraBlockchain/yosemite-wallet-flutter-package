import 'package:meta/meta.dart';

@immutable
class Info {
  final String chainId;
  final String headBlockId;
  final String headBlockTime;

  Info(this.chainId, this.headBlockId, this.headBlockTime);

  String addTimeAfterHeadBlockTimeByMin(var min) {
    var headBlockTime = DateTime.parse(this.headBlockTime);
    var newTime = headBlockTime.add(new Duration(minutes: min));

    return newTime.toIso8601String();
  }

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(json['chain_id'], json['head_block_id'], json['head_block_time']);
  }
}
