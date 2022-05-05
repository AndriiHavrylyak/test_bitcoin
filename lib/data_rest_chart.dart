
import 'package:http/http.dart' as http;
import 'dart:convert';


class chartData {
  Future<List<ExchangeRatesData>> getExchangeRates(
      {required String currency, required String crypto,required String apiKey,required String  coinURL}) async {
    List<ExchangeRatesData> exchangeRatesList = [];


    var uri = Uri.parse(
        '${coinURL}_${crypto}_$currency/latest?period_id=5DAY&limit=36&apikey=${apiKey}');
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      String data = response.body;
      // Декодуєм джесон
      List<dynamic> decodedData = jsonDecode(data);

      // Парсим обекти джесона за якими буде построїний графік
      for (dynamic item in decodedData) {
        exchangeRatesList.add(ExchangeRatesData(
            DateTime.parse(item['time_close']), item['price_close']));
      }
      return exchangeRatesList;
    } else {
      return [ExchangeRatesData(DateTime.now(), 0.0)];
    }
  }
}

//Обекти класа за якими будуть строїтись графіки
class ExchangeRatesData {
  ExchangeRatesData(this.day, this.exchangeRate);
  final DateTime day;
  final double exchangeRate;
}
