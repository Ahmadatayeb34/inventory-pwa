import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/storage_service.dart';

class OrdersProvider with ChangeNotifier {
  Map<String, List<Order>> _orders = {
    'showroom': [],
    'cafe': [],
  };

  final StorageService _storage = StorageService();

  List<Order> getOrders(String source) => _orders[source] ?? [];

  // Load orders from storage
  Future<void> loadOrders() async {
    _orders = await _storage.loadOrders();
    notifyListeners();
  }

  // Save orders to storage
  Future<void> saveOrders() async {
    await _storage.saveOrders(_orders);
    notifyListeners();
  }

  // Add order
  void addOrder(String source, Order order) {
    _orders[source]?.insert(0, order);
    saveOrders();
  }

  // Update order
  void updateOrder(String source, int orderId, Order updatedOrder) {
    final list = _orders[source];
    if (list != null) {
      final index = list.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        list[index] = updatedOrder;
        saveOrders();
      }
    }
  }

  // Delete order
  void deleteOrder(String source, int orderId) {
    _orders[source]?.removeWhere((order) => order.id == orderId);
    saveOrders();
  }

  // Toggle order status
  void toggleOrderStatus(String source, int orderId) {
    final list = _orders[source];
    if (list != null) {
      final index = list.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        list[index].status =
            list[index].status == 'completed' ? 'pending' : 'completed';
        
        // Sort: pending orders first, then by id descending
        list.sort((a, b) {
          if (a.status == b.status) {
            return b.id.compareTo(a.id);
          }
          return a.status == 'completed' ? 1 : -1;
        });
        
        saveOrders();
      }
    }
  }

  // Get pending orders count
  int getPendingCount(String source) {
    return _orders[source]
            ?.where((order) => order.status != 'completed')
            .length ??
        0;
  }

  // Get total pending orders (both sources)
  int get totalPendingCount {
    return getPendingCount('showroom') + getPendingCount('cafe');
  }

  // Calculate days since order
  int calculateDaysSince(String dateStr) {
    try {
      final orderDate = DateTime.parse(dateStr);
      final today = DateTime.now();
      final diff = today.difference(orderDate);
      return diff.inDays;
    } catch (e) {
      return 0;
    }
  }

  // Clear all orders
  Future<void> clearAllOrders() async {
    _orders = {
      'showroom': [],
      'cafe': [],
    };
    await saveOrders();
  }

  // Find order by ID
  Order? findOrder(String source, int orderId) {
    try {
      return _orders[source]?.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }
}
