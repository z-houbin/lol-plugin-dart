A simple command-line application.

## swagger 信息

- token = --riotclient-auth-token
- port = --riotclient-app-port

> https://127.0.0.1:{port}/swagger/v2/swagger.json
> https://127.0.0.1:{port}/swagger/v3/openapi.json

## 客户端信息

- token = --remoting-auth-token
- port = --app-port

## HTTP 格式

##### 请求URL

- ` https://riot:5e{token}@127.0.0.1:{port}/lol-summoner/v1/current-summoner `

##### 请求方式

- GET/POST

## WebSocket 格式

##### 请求URL

- ` wss://127.0.0.1:{port}/ `

##### 请求头

|参数名| 类型     | 说明                                 |
|:---- |:-------|------------------------------------|
|Authorization | string | 'Basic ' + base64("riot:${token}") |

### 编译

```shell
dart compile exe .\bin\lol_plugin_dart.dart
```