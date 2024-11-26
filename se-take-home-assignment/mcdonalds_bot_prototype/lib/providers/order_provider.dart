import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/bot.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _pendingOrders = [];
  final List<Order> _completedOrders = [];
  final List<Order> _processingOrders = []; 
  final List<Bot> _bots = [];
  final Map<int, Timer> _botTimers = {};
  int _orderCounter = 0;
  int _botCounter = 0;

  List<Order> get pendingOrders => List.unmodifiable(_pendingOrders);
  List<Order> get completedOrders => List.unmodifiable(_completedOrders);
   List<Order> get processingOrders => List.unmodifiable(_processingOrders);
  List<Bot> get bots => List.unmodifiable(_bots);

  void addOrder(OrderType type) {
    final order = Order(id: ++_orderCounter, type: type);
    if (type == OrderType.vip) {
      final vipIndex = _pendingOrders.indexWhere((o) => o.type == OrderType.normal);
      _pendingOrders.insert(vipIndex == -1 ? _pendingOrders.length : vipIndex, order);
    } else {
      _pendingOrders.add(order);
    }
    notifyListeners();
    _processOrders();
  }

  void addBot() {
    final bot = Bot(id: ++_botCounter);
    _bots.add(bot);
    notifyListeners();
    _processOrders();
  }

  void removeBot() {
    if (_bots.isNotEmpty) {
      // Get the last bot (the newest one)
      final bot = _bots.removeLast();
      // If the bot is busy (processing an order), we need to stop the process
      if (bot.isBusy) {
        // Find the order being processed by this bot
        final orderBeingProcessed = _processingOrders.lastWhere(
          (order) {
            return order.botId == bot.id;
          },
          orElse: () => Order(id: -1, type: OrderType.normal), // return dummy, if for some reason; bug
        );
        

        _botTimers[bot.id]?.cancel(); // Cancel the timer
        _botTimers.remove(bot.id); // Remove the timer from the map

        if (orderBeingProcessed.id != -1) {
          // Move the order back to PENDING status  
          orderBeingProcessed.botId = null;
          orderBeingProcessed.status = OrderStatus.pending;
          _pendingOrders.insert(0, orderBeingProcessed); // Reinsert it at the beginning of pending orders
          _processingOrders.remove(orderBeingProcessed);
        }
      }

      notifyListeners();
    }
  }


  void _processOrders() {
    for (final bot in _bots.where((bot) => !bot.isBusy)) {
      if (_pendingOrders.isNotEmpty) {
        final order = _pendingOrders.removeAt(0);
        
        // Assign this bot to the order
        order.botId = bot.id;
        bot.isBusy = true;

        _processingOrders.add(order);

        notifyListeners();

      // Start the processing timer and store it
      final timer = Timer(const Duration(seconds: 10), () {
        bot.isBusy = false;
        order.status = OrderStatus.complete;
        _completedOrders.add(order);
        _processingOrders.remove(order);
        _botTimers.remove(bot.id); // Remove the timer when done
        notifyListeners();
        _processOrders(); // Process remaining orders
      });

      _botTimers[bot.id] = timer; // Associate the timer with the bot
      }
    }
  }
}
