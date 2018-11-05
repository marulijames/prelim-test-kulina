import 'package:flutter/material.dart';
import 'pages/subscription_page.dart';

class Routes extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    SubscriptionPage.tag: (context) => SubscriptionPage()
  };

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Flutter App',
        theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.white,
            accentColor: Color.fromRGBO(251, 150, 45, 100.0),
            buttonColor: Color(0xFFFD9714),
            scaffoldBackgroundColor: Color(0xFFF2F3F4),
            textSelectionColor: Color(0xFF555F61),
            fontFamily: 'GoogleSans'
            ),
            
        home: SubscriptionPage(),
        routes: routes);
  }
}
