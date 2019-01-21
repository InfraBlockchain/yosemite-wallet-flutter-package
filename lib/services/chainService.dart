import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yosemite_wallet/models/info.dart';

class ChainApiServerException implements Exception {
  final message;

  ChainApiServerException([this.message]);

  String toString() {
    if (message == null) return "ApiServerException";
    return "ApiServerException: $message";
  }
}

class ChainService {
  final http.Client httpClient;
  final String baseUrl;

  ChainService(this.baseUrl) : this.httpClient = new http.Client();

  Future<String> getAbi(String code, String action, Map data) async {
    final path = '/v1/chain/abi_json_to_bin';

    final headers = {'Content-Type': 'application/json'};

    final params = {"code": code, "action": action, "args": data};

    final response = await this
        .httpClient
        .post(this.baseUrl + path, headers: headers, body: json.encode(params));

    if (response.statusCode == 200) {
      final jsonRes = json.decode(response.body);
      return jsonRes['binargs'];
    } else {
      throw ChainApiServerException('Failed to load: code: ' + response.statusCode.toString());
    }
  }

  Future<Info> getChainInfo() async {
    final path = '/v1/chain/get_info';

    final response = await this.httpClient.get(this.baseUrl + path);

    if (response.statusCode == 200) {
      final jsonRes = json.decode(response.body);

      return Info.fromJson(jsonRes);
    } else {
      throw ChainApiServerException('Failed to load: code: ' + response.statusCode.toString());
    }
  }

  dispose() {
    this.httpClient.close();
  }
}
