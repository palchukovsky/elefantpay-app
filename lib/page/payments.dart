import 'package:flutter/material.dart';
import '../help.dart';
import '../navigation.dart';

class PaymentsPage extends StatefulWidget {
  PaymentsPage({Key key}) : super(key: key);

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Payments')),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: buildBottomNavigationBar(1, context),
        floatingActionButton: HelpFloatingButton());
  }
}
