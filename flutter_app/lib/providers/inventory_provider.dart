import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import '../models/batch.dart';
import '../services/storage_service.dart';

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _inventory = [];
  final StorageService _storage = StorageService();

  List<InventoryItem> get inventory => _inventory;

  int get itemCount => _inventory.length;

  // Load inventory from storage
  Future<void> loadInventory() async {
    _inventory = await _storage.loadInventory();
    notifyListeners();
  }

  // Save inventory to storage
  Future<void> saveInventory() async {
    await _storage.saveInventory(_inventory);
    notifyListeners();
  }

  // Add new item
  void addItem(InventoryItem item) {
    _inventory.add(item);
    saveInventory();
  }

  // Update item
  void updateItem(String code, InventoryItem updatedItem) {
    final index = _inventory.indexWhere((item) => item.code == code);
    if (index != -1) {
      _inventory[index] = updatedItem;
      saveInventory();
    }
  }

  // Delete item
  void deleteItem(String code) {
    _inventory.removeWhere((item) => item.code == code);
    saveInventory();
  }

  // Find item by code
  InventoryItem? findByCode(String code) {
    try {
      return _inventory.firstWhere((item) => item.code == code);
    } catch (e) {
      return null;
    }
  }

  // Update quantity
  void updateQuantity(String code, int quantity, {bool isAdd = true}) {
    final index = _inventory.indexWhere((item) => item.code == code);
    if (index != -1) {
      if (isAdd) {
        _inventory[index].actualQty += quantity;
      } else {
        _inventory[index].actualQty =
            (_inventory[index].actualQty - quantity).clamp(0, double.infinity).toInt();
      }
      saveInventory();
    }
  }

  // Add batch to item
  void addBatch(String code, Batch batch) {
    final index = _inventory.indexWhere((item) => item.code == code);
    if (index != -1) {
      _inventory[index].batches.add(batch);
      _inventory[index].batches.sort((a, b) => a.date.compareTo(b.date));
      saveInventory();
    }
  }

  // Update batch
  void updateBatch(String code, int batchId, Batch updatedBatch) {
    final itemIndex = _inventory.indexWhere((item) => item.code == code);
    if (itemIndex != -1) {
      final batchIndex =
          _inventory[itemIndex].batches.indexWhere((b) => b.id == batchId);
      if (batchIndex != -1) {
        _inventory[itemIndex].batches[batchIndex] = updatedBatch;
        _inventory[itemIndex].batches.sort((a, b) => a.date.compareTo(b.date));
        saveInventory();
      }
    }
  }

  // Delete batch
  void deleteBatch(String code, int batchId) {
    final index = _inventory.indexWhere((item) => item.code == code);
    if (index != -1) {
      _inventory[index].batches.removeWhere((b) => b.id == batchId);
      saveInventory();
    }
  }

  // Update notes
  void updateNotes(String code, String roastery, String notes) {
    final index = _inventory.indexWhere((item) => item.code == code);
    if (index != -1) {
      _inventory[index].roastery = roastery;
      _inventory[index].notes = notes;
      saveInventory();
    }
  }

  // Get expiry alerts count (items expiring in 30 days)
  int get expiryAlertsCount {
    int count = 0;
    for (var item in _inventory) {
      for (var batch in item.batches) {
        final remainingDays = _calculateRemainingDays(batch.date, batch.duration);
        if (remainingDays <= 30) {
          count++;
        }
      }
    }
    return count;
  }

  // Get notes count
  int get notesCount {
    return _inventory.where((item) => item.notes.length > 2).length;
  }

  // Calculate remaining days
  int _calculateRemainingDays(String dateStr, int durationMonths) {
    try {
      final prodDate = DateTime.parse(dateStr);
      final expDate = DateTime(
        prodDate.year,
        prodDate.month + durationMonths,
        prodDate.day,
      );
      final today = DateTime.now();
      final diff = expDate.difference(today);
      return diff.inDays;
    } catch (e) {
      return 0;
    }
  }

  // Clear inventory quantities only
  Future<void> clearQuantities() async {
    for (var item in _inventory) {
      item.actualQty = 0;
    }
    await saveInventory();
  }

  // Clear all batches
  Future<void> clearAllBatches() async {
    for (var item in _inventory) {
      item.batches.clear();
    }
    await saveInventory();
  }

  // Clear all notes
  Future<void> clearAllNotes() async {
    for (var item in _inventory) {
      item.notes = '';
      item.roastery = '';
    }
    await saveInventory();
  }

  // Search items
  List<InventoryItem> searchItems(String query) {
    final lowerQuery = query.toLowerCase();
    return _inventory.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
