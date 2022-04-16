import 'dart:io';

class LolClient {
  late String executePath;
  late String authToken = '';
  int appPort = 0;

  LolClient({this.authToken = '', this.appPort = 0}) {
    var runSync = Process.runSync("cmd", [
      "/C",
      "wmic PROCESS WHERE name='LeagueClientUx.exe' GET commandline",
    ]);

    var commandResult = runSync.stdout.toString();
    File("cmd.txt").writeAsString(commandResult);

    // win admin
    if (commandResult.contains("--app-port")) {
      var split = commandResult.split(RegExp(r"(\s+)"));
      for (var value in split) {
        if (value.contains("--remoting-auth-token")) {
          authToken = value.split("=")[1].replaceAll("\"", "");
        } else if (value.contains("--app-port")) {
          appPort = value.split("=")[1].replaceAll("\"", "") as int;
        }
      }
    }

    print('authToken: $authToken');
    print('appPort: $appPort');
  }
}
