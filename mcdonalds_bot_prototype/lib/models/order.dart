enum OrderType { normal, vip }
enum OrderStatus { pending, complete }

class Order {
  final int id;
  final OrderType type;
  OrderStatus status;
  int? botId;  // Add botId to track the bot that is processing this order

  Order({
    required this.id,
    required this.type,
    this.status = OrderStatus.pending,
    this.botId,  // Initialize botId if assigned
  });
}
