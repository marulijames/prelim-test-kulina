import 'package:flutter/material.dart';
import '../widget/subscription_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_choice.dart';
import 'package:intl/intl.dart';

class SubscriptionPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int boxPerDay = 1;
  int minimumBoxPerDay = 1;
  int selected = 0;
  String startDate = '';
  int selectedPrice = subscriptionChoices[0].price;
  final formatter = NumberFormat("#,###");
  static List<SubscriptionChoice> subscriptionChoices = [
    SubscriptionChoice(id: 1, numberOfDays: 5, price: 25000),
    SubscriptionChoice(id: 2, numberOfDays: 10, price: 24250),
    SubscriptionChoice(id: 3, numberOfDays: 20, price: 22250)
  ];

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int selected = prefs.getInt('selected');
    String startDate = prefs.getString('start_date');
    int price = prefs.getInt('price');
    this.setState(() {
      if (startDate != null) this.startDate = startDate;
      if (selected != null) this.selected = selected;
      if (price != null) this.selectedPrice = price;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    getData();

    // Bagian jumlah box per hari
    final boxCountSection = new Container(
        margin: EdgeInsets.only(left: 12.0, bottom: 12.0, top: 6.0),
        width: screenWidth / 2,
        height: 50.0,
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.circular(3.5),
            border: new Border.all(
                width: 1.5, color: Theme.of(context).buttonColor)),
        child: Center(
          child: Text(
            this.boxPerDay.toString() + ' Box',
            textAlign: TextAlign.left,
            style: TextStyle(
                fontSize: 22.0,
                color: Theme.of(context).textSelectionColor,
                fontWeight: FontWeight.bold),
          ),
        ));
    final minButton = Container(
        margin: EdgeInsets.only(left: 12.0, bottom: 12.0, top: 6.0, right: 1.0),
        child: InkWell(
            onTap: () {
              setState(() {
                if (this.boxPerDay > 1) {
                  this.boxPerDay--;
                }
              });
            },
            child: Container(
                width: screenWidth / 6.5,
                height: 50.0,
                decoration: new BoxDecoration(
                    color: Theme.of(context).buttonColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(0.0),
                      topLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(0.0),
                      bottomLeft: Radius.circular(5.0),
                    )),
                child: Center(
                  child: Text(
                    '-',
                    style: TextStyle(fontSize: 35.0, color: Colors.white),
                  ),
                ))));
    final plusButton = Container(
        margin: EdgeInsets.only(left: 1.0, bottom: 12.0, top: 6.0, right: 12.0),
        child: InkWell(
            onTap: () {
              setState(() {
                this.boxPerDay++;
              });
            },
            child: Container(
                width: screenWidth / 6.5,
                height: 50.0,
                decoration: new BoxDecoration(
                    color: Theme.of(context).buttonColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.0),
                      topLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(0.0),
                    )),
                child: Center(
                  child: Text(
                    '+',
                    style: TextStyle(fontSize: 35.0, color: Colors.white),
                  ),
                ))));
    final boxPerDaySection = Container(
        child: Row(
      children: <Widget>[
        boxCountSection,
        Expanded(child: Container()),
        Row(children: <Widget>[minButton, plusButton])
      ],
    ));
    // --------------------------------
    Widget cardTitle(data) {
      return Container(
          padding: EdgeInsets.only(left: 12.0, bottom: 6.0, top: 24.0),
          alignment: Alignment.centerLeft,
          child: Text(data,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)));
    }

    final proTipsSection = Container(
        padding: EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 16.0),
        child: Container(
            child: Card(
                color: Color(0xFFFEf4E7),
                child: Container(
                    padding: EdgeInsets.all(12.0),
                    child: Column(children: [
                      Container(
                          padding: EdgeInsets.only(bottom: 4.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pro Tips',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Text(
                        'Atur jadwal langganan dengan menekan tanggal pada kalender. Selesaikan transaksi sebelum pukul 19:00 untuk mulai pengiriman besok.',
                        textAlign: TextAlign.left,
                      ),
                    ])))));

    final firstCard = Container(
        margin: EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 0.0),
        child: Container(
            child: Card(
                color: Colors.white,
                child: Center(
                    child: Column(
                  children: <Widget>[
                    cardTitle('Jumlah box per hari'),
                    boxPerDaySection,
                    cardTitle('Lama Langganan'),
                    SubscriptionPicker(DateTime.now(), subscriptionChoices),
                    proTipsSection
                  ],
                ))),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFDCDFE1),
                blurRadius: 8.0,
              ),
            ])));
    // Bagian rincian langganan
    final pricePerBoxSection = Container(
        margin: EdgeInsets.all(12.0),
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: <Widget>[
                  Text('Harga per box',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).textSelectionColor,
                      )),
                  Expanded(child: Container()),
                  Text('Rp ' + formatter.format(selectedPrice),
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).textSelectionColor,
                      ))
                ],
              )),
          Divider()
        ]));

    final totalBoxSection = Container(
        margin: EdgeInsets.all(12.0),
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: <Widget>[
                  Text('Jumlah Box',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).textSelectionColor,
                      )),
                  Expanded(child: Container()),
                  Text(boxPerDay.toString() + ' Box',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).textSelectionColor,
                      ))
                ],
              )),
          Divider()
        ]));
    final subsNumOfDaySection = Container(
        margin: EdgeInsets.all(12.0),
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: <Widget>[
                  Text('Lama Langganan',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).textSelectionColor,
                      )),
                  Expanded(child: Container()),
                  Text(selected.toString() + ' Hari',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Theme.of(context).textSelectionColor,
                      ))
                ],
              )),
          Container(
              margin: EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: <Widget>[
                  Text('Mulai ' + startDate,
                      style: TextStyle(fontSize: 14.0, color: Colors.black45)),
                  Expanded(child: Container()),
                ],
              )),
          Divider()
        ]));

    final totalPriceSection = Container(
        margin: EdgeInsets.all(12.0),
        child: Column(children: [
          Container(
              margin: EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: <Widget>[
                  Text('Total',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                  Expanded(child: Container()),
                  Text(
                      'Rp ' +
                          formatter
                              .format(selectedPrice * boxPerDay * selected),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ))
                ],
              ))
        ]));
    //---------------------------------
    final secondCard = Container(
        margin: EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 0.0),
        child: Container(
            child: Card(
                color: Color(0xFFFFFFFF),
                child: Center(
                    child: Column(
                  children: <Widget>[
                    cardTitle('Rincian Langganan'),
                    pricePerBoxSection,
                    totalBoxSection,
                    subsNumOfDaySection,
                    totalPriceSection
                  ],
                ))),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFDCDFE1),
                blurRadius: 8.0,
              ),
            ])));

    final nextButton = Container(
        margin: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
        child: InkWell(
            onTap: () {},
            child: Container(
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.5),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF94D34),
                    blurRadius: 4.0,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.0, 1.0],
                  colors: [
                    Color(0xFFF94D34),
                    Color(0XFFFC831C),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  'Selanjutnya',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ),
            )));
    return Theme(
        data: Theme.of(context),
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0.0,
              bottom: PreferredSize(
                  child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 35.0),
                          child: Row(
                            children: <Widget>[
                              Center(
                                  child: Column(children: <Widget>[
                                Text(
                                  '      Mulai      ',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Theme.of(context).buttonColor),
                                ),
                                Text(
                                  'o',
                                  style: TextStyle(
                                      fontSize: 30.0,
                                      color: Theme.of(context).buttonColor),
                                )
                              ])),
                              Expanded(
                                child: Container(),
                              ),
                              Center(
                                  child: Column(children: <Widget>[
                                Text('Pengiriman',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFFDADEDF))),
                                Text('o',
                                    style: TextStyle(
                                        fontSize: 30.0,
                                        color: Color(0xFFDADEDF)))
                              ])),
                              Expanded(
                                child: Container(),
                              ),
                              Center(
                                  child: Column(children: <Widget>[
                                Text('Pembayaran',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFFDADEDF))),
                                Text('o',
                                    style: TextStyle(
                                        fontSize: 30.0,
                                        color: Color(0xFFDADEDF)))
                              ])),
                            ],
                          ))),
                  preferredSize: const Size.fromHeight(60.0)),
              title: Text('Mulai Langganan',
                  style: TextStyle(fontSize: 24.0, color: Colors.black)),
            ),
            body: ListView(
                children: <Widget>[firstCard, secondCard, nextButton])));
  }
}
