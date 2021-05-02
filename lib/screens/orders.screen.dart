import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/orders.dart';
import '../widgets/order_item.dart' as ord;

class OrderScreen extends StatefulWidget {
  static const routeName = '/orderscreen';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isLoading = false;
  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(Duration.zero).then((_) async {
      await Provider.of<Order>(context, listen: false).fetchAndSetOrders();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Orders!',
        ),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? CircularProgressIndicator()
          : ListView.builder(
              itemBuilder: (ctx, index) {
                return ord.OrderItem(
                  orderData.orders[index],
                );
              },
              itemCount: orderData.orders.length,
            ),
    );
  }
}
