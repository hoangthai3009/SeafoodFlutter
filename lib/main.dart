import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Provider/AuthProvider.dart';
import 'Provider/CartProvider.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/main_mavigation_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Seafood',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        routes: {
          '/register': (context) => RegisterPage(),
          '/login': (context) => LoginPage(),
          '/cart': (context) => CartPage(),
          '/main': (context) => MainNavigationPage(),
          '/checkout': (context) => CheckoutPage(),
          // Other routes...
        },
        home: MainNavigationPage(),
      ),
    );
  }
}
