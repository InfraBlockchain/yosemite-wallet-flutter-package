import 'package:meta/meta.dart';

@immutable
class Info {
  final String chainId;
  final String headBlockId;
  final String headBlockTime;

  Info(this.chainId, this.headBlockId, String headBlockTime)
      : this.headBlockTime = headBlockTime + 'Z';

  String addTimeAfterHeadBlockTimeByMin(var min) {
    var headBlockTime = DateTime.parse(this.headBlockTime).toUtc();
    var newTime = headBlockTime.add(new Duration(minutes: min));

    return newTime.toIso8601String();
  }

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(json['chain_id'], json['head_block_id'], json['head_block_time']);
  }
}
