import 'package:flutter/material.dart';
import 'page/money.dart';

buildBottomNavigationBar(final currentIndex, final BuildContext context) {
  return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          title: Text('Money'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          title: Text('Payments'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          title: Text('Account'),
        )
      ],
      currentIndex: currentIndex,
      onTap: (final int index) {
        WidgetBuilder builder;
        switch (index) {
          default:
            builder = (context) => MoneyPage();
            break;
        }
        Navigator.push(context, MaterialPageRoute(builder: builder));
      });
}
