import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/inventory_item.dart';
import '../models/batch.dart';
import '../providers/inventory_provider.dart';
import '../widgets/search_field.dart';

class ExpiryScreen extends StatefulWidget {
  const ExpiryScreen({Key? key}) : super(key: key);

  @override
  State<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends State<ExpiryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _durationController = TextEditingController(text: '12');
  String _searchQuery = '';
  InventoryItem? _selectedItem;
  DateTime? _selectedDate;
  int? _editingBatchId;

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _selectItem(InventoryItem item) {
    setState(() {
      _selectedItem = item;
      _searchQuery = '';
      _searchController.clear();
      _cancelBatchEdit();
    });
  }

  void _addOrUpdateBatch() {
    if (_selectedItem == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التاريخ والكمية')),
      );
      return;
    }

    final qty = int.tryParse(_qtyController.text);
    final duration = int.tryParse(_durationController.text) ?? 12;

    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كمية صحيحة')),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    if (_editingBatchId != null) {
      // Update existing batch
      final updatedBatch = Batch(
        id: _editingBatchId!,
        date: dateStr,
        qty: qty,
        duration: duration,
      );
      context.read<InventoryProvider>().updateBatch(
        _selectedItem!.code,
        _editingBatchId!,
        updatedBatch,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الدفعة')),
      );
    } else {
      // Add new batch
      final newBatch = Batch(
        id: DateTime.now().millisecondsSinceEpoch,
        date: dateStr,
        qty: qty,
        duration: duration,
      );
      context.read<InventoryProvider>().addBatch(_selectedItem!.code, newBatch);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الدفعة')),
      );
    }

    setState(() {
      _selectedItem = context.read<InventoryProvider>().findByCode(_selectedItem!.code);
      _qtyController.clear();
      _selectedDate = null;
      _durationController.text = '12';
      _editingBatchId = null;
    });
  }

  void _editBatch(Batch batch) {
    setState(() {
      _editingBatchId = batch.id;
      _selectedDate = DateTime.parse(batch.date);
      _qtyController.text = batch.qty.toString();
      _durationController.text = batch.duration.toString();
    });
  }

  void _cancelBatchEdit() {
    setState(() {
      _editingBatchId = null;
      _qtyController.clear();
      _selectedDate = null;
      _durationController.text = '12';
    });
  }

  void _deleteBatch(int batchId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('حذف هذا التاريخ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<InventoryProvider>().deleteBatch(_selectedItem!.code, batchId);
              Navigator.pop(context);
              setState(() {
                _selectedItem = context.read<InventoryProvider>().findByCode(_selectedItem!.code);
                if (_editingBatchId == batchId) {
                  _cancelBatchEdit();
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الدفعة')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateExpiry(String dateStr, int durationMonths) {
    try {
      final prodDate = DateTime.parse(dateStr);
      final expDate = DateTime(
        prodDate.year,
        prodDate.month + durationMonths,
        prodDate.day,
      );
      final today = DateTime.now();
      final diffDays = expDate.difference(today).inDays;

      String label;
      Color color;

      if (diffDays < 0) {
        label = 'منتهي (${diffDays.abs()} يوم)';
        color = Colors.red[100]!;
      } else if (diffDays <= 30) {
        label = 'باقي $diffDays يوم';
        color = Colors.amber[100]!;
      } else {
        final months = (diffDays / 30).floor();
        label = 'باقي $months شهر';
        color = Colors.green[100]!;
      }

      return {
        'label': label,
        'color': color,
        'expDate': DateFormat('dd/MM/yyyy').format(expDate),
        'remainingDays': diffDays,
      };
    } catch (e) {
      return {
        'label': '-',
        'color': Colors.grey[100]!,
        'expDate': '-',
        'remainingDays': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1b4b),
        title: const Text(
          'تنبيهات الصلاحية',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Left panel
          Container(
            width: 420,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.amber[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إدارة التواريخ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SearchField(
                        hintText: 'بحث عن صنف...',
                        icon: Icons.search,
                        controller: _searchController,
                        borderColor: Colors.amber[200],
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
                                foregroundColor: Colors.amber[700],
                                side: BorderSide(color: Colors.amber[200]!),
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
                                foregroundColor: Colors.amber[700],
                                side: BorderSide(color: Colors.amber[200]!),
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
                              content: const Text('هل أنت متأكد من حذف جميع تواريخ الصلاحية المسجلة؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await context.read<InventoryProvider>().clearAllBatches();
                            setState(() {
                              _selectedItem = null;
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم حذف سجل التواريخ')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('حذف سجل التواريخ فقط', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[600],
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
                              Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'اختر صنفاً لإدارة تواريخه',
                                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : _buildBatchManagement(),
                ),
              ],
            ),
          ),
          // Right panel - Table
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _buildExpiryTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedItem!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'إدارة الدفعات والتواريخ',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تاريخ التحميص',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.amber[200]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                              : 'اختر التاريخ',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Icon(Icons.calendar_today, size: 20, color: Colors.amber),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'مدة الصلاحية (أشهر)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.amber[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.amber[500]!, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'الكمية لهذه الدفعة',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'مثلاً: 12',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.amber[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.amber[500]!, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addOrUpdateBatch,
                        icon: Icon(_editingBatchId != null ? Icons.save : Icons.add),
                        label: Text(_editingBatchId != null ? 'حفظ التعديل' : 'إضافة التاريخ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_editingBatchId != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cancelBatchEdit,
                          child: const Text('إلغاء'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.grey[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'الدفعات والتواريخ المسجلة:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildBatchesList(),
        ],
      ),
    );
  }

  Widget _buildBatchesList() {
    if (_selectedItem == null || _selectedItem!.batches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'لا توجد دفعات مسجلة',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: _selectedItem!.batches.map((batch) {
        final expiryInfo = _calculateExpiry(batch.date, batch.duration);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[100]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحميص: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(batch.date))}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      'انتهاء: ${expiryInfo['expDate']}',
                      style: const TextStyle(fontSize: 10, color: Colors.red),
                    ),
                    Text(
                      'الكمية: ${batch.qty}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: expiryInfo['color'],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      expiryInfo['label'],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _editBatch(batch),
                        child: const Text('تعديل', style: TextStyle(fontSize: 10)),
                      ),
                      TextButton(
                        onPressed: () => _deleteBatch(batch.id),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('حذف', style: TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpiryTable() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final items = _searchQuery.isEmpty
            ? provider.inventory
            : provider.searchItems(_searchQuery);

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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تقرير الصلاحية التفصيلي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                      columns: const [
                        DataColumn(label: Text('الكود', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الصنف', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('تاريخ التحميص', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('تاريخ الانتهاء', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _buildTableRows(items),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DataRow> _buildTableRows(List<InventoryItem> items) {
    final List<DataRow> rows = [];

    for (var item in items) {
      if (item.batches.isEmpty) {
        rows.add(
          DataRow(
            selected: _selectedItem?.code == item.code,
            onSelectChanged: (_) => _selectItem(item),
            cells: [
              DataCell(Text(item.code, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.grey))),
              DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
              const DataCell(Text('-', style: TextStyle(color: Colors.grey))),
              const DataCell(Text('-', style: TextStyle(color: Colors.grey))),
              const DataCell(Text('0', style: TextStyle(color: Colors.grey))),
              const DataCell(Text('اضغط لإضافة تاريخ', style: TextStyle(fontSize: 10, color: Colors.grey))),
            ],
          ),
        );
      } else {
        for (var batch in item.batches) {
          final expiryInfo = _calculateExpiry(batch.date, batch.duration);
          rows.add(
            DataRow(
              selected: _selectedItem?.code == item.code,
              onSelectChanged: (_) => _selectItem(item),
              cells: [
                DataCell(Text(item.code, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.grey))),
                DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(batch.date)), style: const TextStyle(fontFamily: 'monospace'))),
                DataCell(Text(expiryInfo['expDate'], style: const TextStyle(fontFamily: 'monospace', color: Colors.red, fontWeight: FontWeight.bold))),
                DataCell(Text('${batch.qty}', style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: expiryInfo['color'],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      expiryInfo['label'],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }

    return rows;
  }
}
