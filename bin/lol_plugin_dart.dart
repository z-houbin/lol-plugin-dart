import 'LcuApi.dart';
import 'LolClient.dart';

void main(List<String> arguments) {
  var client = LolClient(authToken: '5elDKwxXVIqUk_qrGzMSNA', appPort: 50953);

  Lcu lcu = Lcu(client);
  lcu.connect();

  lcu.request('get', 'lol-summoner/v1/current-summoner').then((data) {
    print('current-summoner: $data');
  });

  lcu.listen('/lol-clash/v1/time', (data) {
    print('listen: $data');
  });
}
