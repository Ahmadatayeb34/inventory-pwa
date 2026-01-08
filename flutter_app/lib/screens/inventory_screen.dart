import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inventory_item.dart';
import '../providers/inventory_provider.dart';
import '../widgets/search_field.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  String _searchQuery = '';
  InventoryItem? _selectedItem;
  bool _isAddMode = true;

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _selectItem(InventoryItem item) {
    setState(() {
      _selectedItem = item;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _submitQuantity() {
    if (_selectedItem == null) return;
    
    final qty = int.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كمية صحيحة')),
      );
      return;
    }

    context.read<InventoryProvider>().updateQuantity(
          _selectedItem!.code,
          qty,
          isAdd: _isAddMode,
        );

    setState(() {
      _selectedItem = context.read<InventoryProvider>().findByCode(_selectedItem!.code);
      _qtyController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث الكمية')),
    );
  }

  void _deleteItem() {
    if (_selectedItem == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الصنف "${_selectedItem!.name}" نهائياً من النظام؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<InventoryProvider>().deleteItem(_selectedItem!.code);
              Navigator.pop(context);
              setState(() {
                _selectedItem = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف الصنف بنجاح'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _addNewItem(String code) {
    final nameController = TextEditingController();
    final sysQtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة صنف جديد للنظام'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: code),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'الكود',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الصنف',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sysQtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الكمية الافتراضية',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newItem = InventoryItem(
                  code: code,
                  name: nameController.text,
                  sysQty: int.tryParse(sysQtyController.text) ?? 0,
                  actualQty: 0,
                );
                context.read<InventoryProvider>().addItem(newItem);
                Navigator.pop(context);
                _selectItem(newItem);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة الصنف بنجاح')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1b4b),
        title: const Text(
          'إدارة الجرد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Left panel - Item details
          Container(
            width: 400,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFF8FAFC),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إدارة الجرد',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1e1b4b),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SearchField(
                        hintText: 'باركود أو اسم...',
                        icon: Icons.qr_code_scanner,
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ميزة الاستيراد ستكون متاحة قريباً')),
                                );
                              },
                              icon: const Icon(Icons.upload, size: 16),
                              label: const Text('استيراد', style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF4f46e5),
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('ميزة التصدير ستكون متاحة قريباً')),
                                );
                              },
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('تصدير', style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF4f46e5),
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('تأكيد'),
                              content: const Text('هل أنت متأكد من تصفير جميع الكميات الفعلية؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('تصفير'),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmed == true) {
                            await context.read<InventoryProvider>().clearQuantities();
                            setState(() {
                              _selectedItem = null;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم تصفير كميات الجرد')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('تصفير كميات الجرد فقط', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _selectedItem == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'امسح الكود للبدء',
                                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : _buildItemDetails(),
                ),
              ],
            ),
          ),
          // Right panel - Table
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _buildInventoryTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedItem!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1e1b4b),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _selectedItem!.code,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _deleteItem,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'حذف الصنف نهائياً',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQtyCard('الكمية الحالية', '${_selectedItem!.actualQty}', Colors.grey[700]!),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQtyCard('الكمية بالنظام', '${_selectedItem!.sysQty}', Colors.grey[400]!),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _isAddMode = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAddMode ? const Color(0xFF4f46e5) : Colors.grey[100],
                          foregroundColor: _isAddMode ? Colors.white : Colors.grey[500],
                          elevation: 0,
                        ),
                        child: const Text('إضافة (+)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _isAddMode = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isAddMode ? Colors.red[500] : Colors.grey[100],
                          foregroundColor: !_isAddMode ? Colors.white : Colors.grey[500],
                          elevation: 0,
                        ),
                        child: const Text('خصم (-)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'الكمية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4f46e5), width: 2),
                    ),
                  ),
                  onSubmitted: (_) => _submitQuantity(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitQuantity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1e1b4b),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('تأكيد العملية', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final items = _searchQuery.isEmpty
            ? provider.inventory
            : provider.searchItems(_searchQuery);

        // Check if search query is entered but no matches found - show add option
        if (_searchQuery.isNotEmpty && items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('لم يتم العثور على نتائج'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _addNewItem(_searchQuery),
                  icon: const Icon(Icons.add),
                  label: Text('إضافة صنف جديد: $_searchQuery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4f46e5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'سجل الجرد',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e1b4b),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ميزة الطباعة ستكون متاحة قريباً')),
                        );
                      },
                      icon: const Icon(Icons.print, size: 20),
                      tooltip: 'طباعة',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                    columns: const [
                      DataColumn(label: Text('الكود', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('الصنف', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('النظام', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('الفعلي', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4f46e5)))),
                      DataColumn(label: Text('الفارق', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: items.map((item) {
                      final diff = item.difference;
                      final diffColor = diff == 0
                          ? Colors.green[500]
                          : (diff > 0 ? Colors.blue[500] : Colors.red[500]);
                      final diffSign = diff > 0 ? '+' : '';

                      return DataRow(
                        selected: _selectedItem?.code == item.code,
                        onSelectChanged: (_) => _selectItem(item),
                        cells: [
                          DataCell(Text(item.code, style: const TextStyle(fontFamily: 'monospace', color: Colors.grey))),
                          DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('${item.sysQty}', style: TextStyle(fontFamily: 'monospace', color: Colors.grey[400]))),
                          DataCell(Text('${item.actualQty}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, color: Color(0xFF1e1b4b)))),
                          DataCell(Text('$diffSign$diff', style: TextStyle(fontWeight: FontWeight.bold, color: diffColor))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
