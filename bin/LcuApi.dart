import 'dart:convert';
import 'dart:io';

import 'LolClient.dart';

class Lcu {
  LolClient lolClient;

  late WebSocket _webSocketClient;
  late HttpClient _httpClient;
  Map<String, Function> listener = {};

  Lcu(this.lolClient);

  void connect() async {
    var url = 'wss://127.0.0.1:${lolClient.appPort}/';

    var authorization = utf8.fuse(base64).encode("riot:${lolClient.authToken}");

    var headers = {
      'Authorization': 'Basic ' + authorization,
      // 'Connection': 'upgrade',
      // 'Upgrade': 'websocket'
    };

    SecurityContext secCtx = SecurityContext();

    secCtx.setTrustedCertificatesBytes(utf8.encode(
        File("G:\\github\\lol-plugin-dart\\bin\\lol.pem").readAsStringSync()));

    _httpClient = HttpClient(context: secCtx);
    _httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };

    _webSocketClient = await WebSocket.connect(url,
        headers: headers, customClient: _httpClient);

    // 监听消息
    _webSocketClient.listen((data) {
      if (data.isEmpty) {
        return;
      }

      List<dynamic> jsonList = json.decode(data);
      if (jsonList.length != 3) {
        return;
      }

      data = json.decode(data)[2];
      var uri = data['uri'];
      print('event: $uri');

      listener.forEach((key, value) {
        if (uri.toString().contains(key)) {
          if (listener.containsKey(uri)) {
            Function? fn = listener[uri];
            Function.apply(fn!, [data]);
          }
        }
      });
    });

    // 订阅事件通知
    subscribe('OnJsonApiEvent');

    print('connect finish ');
  }

  /// 监听地址数据
  void listen(uri, listen) {
    if (listen != null) {
      listener[uri] = listen;
    }
  }

  /// 订阅事件
  void subscribe(event, {listen}) {
    if (listen != null) {
      listener[event] = listen;
    }
    _webSocketClient.add('[${OPCode.SUBSCRIBE},"$event"]');
  }

  /// 取消订阅事件
  void unSubscribe(event) {
    _webSocketClient.add('[${OPCode.UN_SUBSCRIBE},"$event"]');
  }

  /// 执行请求
  Future<Map<String, dynamic>> request(String method, String endpoint,
      {Map<String, dynamic>? body}) async {
    HttpClientRequest req = await _httpClient.openUrl(
        method, Uri.parse('https://127.0.0.1:${lolClient.appPort}/$endpoint'));

    req.headers.set(HttpHeaders.acceptHeader, 'application/json');
    req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    req.headers.set(HttpHeaders.authorizationHeader,
        'Basic ' + utf8.fuse(base64).encode('riot:${lolClient.authToken}'));

    if (body != null) req.add(json.fuse(utf8).encode(body));

    HttpClientResponse resp = await req.close();
    return resp
        .transform(utf8.decoder)
        .join()
        .then((String data) => json.decode(data.isEmpty ? '{}' : data));
  }
}

class Functions {}

class OPCode {
  /// 订阅
  static int SUBSCRIBE = 5;

  /// 取消订阅
  static int UN_SUBSCRIBE = 6;

  /// 接收
  static int RECEIVE = 8;
}
