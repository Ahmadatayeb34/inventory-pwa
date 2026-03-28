import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory_item.dart';
import '../models/order.dart';

class StorageService {
  static const String _inventoryKey = 'ims_inventory_data_v2';
  static const String _ordersKey = 'ims_orders_data_v2';

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Inventory operations
  Future<List<InventoryItem>> loadInventory() async {
    final String? data = _prefs?.getString(_inventoryKey);
    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
      return jsonList
          .map((item) => InventoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading inventory: $e');
      return [];
    }
  }

  Future<void> saveInventory(List<InventoryItem> inventory) async {
    try {
      final String jsonStr =
          json.encode(inventory.map((item) => item.toJson()).toList());
      await _prefs?.setString(_inventoryKey, jsonStr);
    } catch (e) {
      print('Error saving inventory: $e');
    }
  }

  // Orders operations
  Future<Map<String, List<Order>>> loadOrders() async {
    final String? data = _prefs?.getString(_ordersKey);
    if (data == null || data.isEmpty) {
      return {'showroom': [], 'cafe': []};
    }

    try {
      final Map<String, dynamic> jsonMap = json.decode(data) as Map<String, dynamic>;
      
      final showroomOrders = (jsonMap['showroom'] as List<dynamic>?)
              ?.map((order) => Order.fromJson(order as Map<String, dynamic>))
              .toList() ??
          [];
      
      final cafeOrders = (jsonMap['cafe'] as List<dynamic>?)
              ?.map((order) => Order.fromJson(order as Map<String, dynamic>))
              .toList() ??
          [];

      return {
        'showroom': showroomOrders,
        'cafe': cafeOrders,
      };
    } catch (e) {
      print('Error loading orders: $e');
      return {'showroom': [], 'cafe': []};
    }
  }

  Future<void> saveOrders(Map<String, List<Order>> orders) async {
    try {
      final Map<String, dynamic> jsonMap = {
        'showroom': orders['showroom']?.map((order) => order.toJson()).toList() ?? [],
        'cafe': orders['cafe']?.map((order) => order.toJson()).toList() ?? [],
      };
      final String jsonStr = json.encode(jsonMap);
      await _prefs?.setString(_ordersKey, jsonStr);
    } catch (e) {
      print('Error saving orders: $e');
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _prefs?.remove(_inventoryKey);
    await _prefs?.remove(_ordersKey);
  }

  // Clear inventory only
  Future<void> clearInventory() async {
    await _prefs?.remove(_inventoryKey);
  }

  // Clear orders only
  Future<void> clearOrders() async {
    await _prefs?.remove(_ordersKey);
  }
}
