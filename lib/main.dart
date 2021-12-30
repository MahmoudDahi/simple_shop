import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/auth_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_details_screen.dart';
import './screens/orders_screen.dart';
import './providers/cart.dart';
import './providers/products.dart';
import './providers/order.dart';
import './providers/auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products(),
          update: (ctx, auth, previousProducts) => Products()
            ..update(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items,
            ),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (context) => Order(null, null, []),
          update: (ctx, auth, previousOrders) => Order(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Simple Shop',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            fontFamily: 'lato',
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
          ),
          home: authData.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (ctx, snapShotLogin) =>
                      snapShotLogin.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailsScreen.routeName: (ctx) => ProductDetailsScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
