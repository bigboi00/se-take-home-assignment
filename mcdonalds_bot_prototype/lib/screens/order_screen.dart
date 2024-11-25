import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          // Buttons for user actions - Wrap the Row with SingleChildScrollView for horizontal scrolling
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => orderProvider.addOrder(OrderType.normal),
                  child: Text('New Normal Orders'),
                ),
                SizedBox(width: 8),  // Space between buttons
                ElevatedButton(
                  onPressed: () => orderProvider.addOrder(OrderType.vip),
                  child: Text('New VIP Order'),
                ),
                SizedBox(width: 8),  // Space between buttons
                ElevatedButton(
                  onPressed: () => orderProvider.addBot(),
                  child: Text('+ Bot'),
                ),
                SizedBox(width: 8),  // Space between buttons
                ElevatedButton(
                  onPressed: () => orderProvider.removeBot(),
                  child: Text('- Bot'),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Display current bots
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Current Bots',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orderProvider.bots.length,
              itemBuilder: (context, index) {
                final bot = orderProvider.bots[index];
                return ListTile(
                  title: Text('Bot ID: ${bot.id}'),
                  subtitle: Text('Is Busy: ${bot.isBusy ? "Yes" : "No"}'),
                );
              },
            ),
          ),

          // Pending and Completed orders display
          Expanded(
            child: Row(
              children: [
                // Pending orders section
                Expanded(
                  child: OrderList(
                    title: 'PENDING',
                    orders: orderProvider.pendingOrders,
                  ),
                ),
                // Completed orders section
                Expanded(
                  child: OrderList(
                    title: 'COMPLETE',
                    orders: orderProvider.completedOrders,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for displaying a list of orders
class OrderList extends StatelessWidget {
  final String title;
  final List<Order> orders;

  OrderList({required this.title, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Section title
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),

          // List of orders
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text(
                    order.type == OrderType.vip ? 'VIP Order' : 'Normal Order',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
