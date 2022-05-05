import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:test_bitcoin/data_rest_chart.dart';
import 'dart:convert';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Test job'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);


  final String title;
//Підключення до веб сокета
  WebSocketChannel channel = IOWebSocketChannel.connect("wss://ws-sandbox.coinapi.io/v1/");



  @override
  _MyHomePageState createState() => _MyHomePageState();

}
class _MyHomePageState extends State<MyHomePage> {


//Налаштування параметрів для забору даних через Get - запит

  chartData chartingData = chartData();
  String myKey = 'C4F12EA7-D405-4619-99FD-62F4B00A80D9';
  String URL = 'https://rest.coinapi.io/v1/ohlcv/BITSTAMP_SPOT';
  String selectedCurrencyTicker = 'USD';
  String selectedCryptoTicker = 'BTC';
  double exchangeRate = 0.0;
  dynamic exchangeRatesChartData = [ExchangeRatesData(DateTime.now(), 0.0)];



  //Налаштування привітання WebSocket для того щоб отримувати дані у відповідь у реальнму часі




  // Запираєм дані REST API та WebSocket після запуску додатку
  @override
  void initState() {
    late  String mapAuth = '{\n"type": "hello",\n"apikey": "${myKey}",\n"heartbeat": false,\n"subscribe_data_type": ["exrate"],\n"subscribe_filter_asset_id": ["${selectedCryptoTicker}/${selectedCurrencyTicker}"]\n}';
    Future.delayed(Duration.zero, () async {
      exchangeRatesChartData = await chartingData.getExchangeRates(
          currency: selectedCurrencyTicker, crypto: selectedCryptoTicker, apiKey: myKey,coinURL : URL );
      exchangeRate = exchangeRatesChartData[0].exchangeRate;
      setState(() {
        print(mapAuth);
        sendData(mapAuth);
      });

    });
    super.initState();
  }




  //Декодуєм дані які отрмали через WebSocket

  String getExtractedRate(AsyncSnapshot<dynamic> snapshot) {
    return snapshot.hasData ? '${jsonDecode(snapshot.data)["rate"]}' : '';
  }

  String getExtractedBase(AsyncSnapshot<dynamic> snapshot) {
    return snapshot.hasData ? '${jsonDecode(snapshot.data)["asset_id_base"]}' : '';
  }
  String getExtractedQuote(AsyncSnapshot<dynamic> snapshot) {
    return snapshot.hasData ? '${jsonDecode(snapshot.data)["asset_id_quote"]}' : '';
  }
  String getExtractedTime(AsyncSnapshot<dynamic> snapshot) {
    return snapshot.hasData ?  DateFormat.yMd().add_jm().format(DateTime.parse('${jsonDecode(snapshot.data)["time"]}')) : '';
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body:
        StreamBuilder(
            stream: widget.channel.stream,
            builder: (context, snapshot) {
              return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: <Widget>[
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                      child: InputDecorator(

                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Text(getExtractedBase(snapshot) + "/" + getExtractedQuote(snapshot)),
                                      ),
                                    )
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    color: Colors.transparent,
                                    height: 70,
                                    padding: EdgeInsets.all(5.0),
                                    child:  FlatButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(color: Colors.grey),
                                      ),
                                      onPressed: () {},
                                      child: Text("Subsckribe" ,style: TextStyle(fontWeight: FontWeight. bold,
                                          fontSize: 12.0, color: Colors.blueGrey) ),
                                    ),
                                  ),

                                )
                              ],
                            ),

                          ),

                          Text(
                            "Market data:",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),

                          ),
                          Container(
                            padding: EdgeInsets.all(16.0),

                            child: InputDecorator(

                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children:<Widget>[
                                    Container(
                                        child: Column(
                                            children:<Widget>[
                                              Container(
                                                child: Text("Sumbol:"),

                                              ),
                                              Container(
                                                child: Text(getExtractedBase(snapshot) + "/" + getExtractedQuote(snapshot) ),
                                              ),
                                            ]
                                        )
                                    ),
                                    Container(
                                        child: Column(
                                            children:<Widget>[
                                              Container(
                                                child: Text("Price:"),

                                              ),
                                              Container(
                                                child: Text(getExtractedRate(snapshot)),
                                              ),
                                            ]
                                        )
                                    ),
                                    Container(
                                        child: Column(
                                            children:<Widget>[
                                              Container(
                                                child: Text("Time:"),

                                              ),
                                              Container(
                                                child: Text(getExtractedTime(snapshot)),
                                              ),
                                            ]
                                        )
                                    ),
                                  ]
                              ),

                            ),
                          ),
                          Container(
                              padding: EdgeInsets.all(16.0),

                              child: InputDecorator(

                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: SfCartesianChart(
                                  title: ChartTitle(
                                    text: 'Charting dats',
                                    textStyle: const TextStyle(fontSize: 16.0, color: Colors.black),
                                  ),
                                  // Initialize category axis
                                  primaryXAxis: DateTimeAxis(),
                                  series: <LineSeries<ExchangeRatesData, DateTime>>[
                                    LineSeries<ExchangeRatesData, DateTime>(
                                      // Bind data source
                                        dataSource: exchangeRatesChartData,
                                        xValueMapper: (ExchangeRatesData exchangeRate, _) =>
                                        exchangeRate.day,
                                        yValueMapper: (ExchangeRatesData exchangeRate, _) =>
                                        exchangeRate.exchangeRate),
                                  ],
                                ),
                              )

                          )
                        ]
                       ),
                  )
              );
            }
        )
    );
  }



  void sendData(mapAuth) {
    widget.channel.sink.add(mapAuth);

  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}




