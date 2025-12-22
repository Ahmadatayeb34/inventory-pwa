import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _activeTab = 'showroom';
  String _activeSource = 'showroom';
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedType = 'أمر شراء';
  DateTime _selectedDate = DateTime.now();
  int? _editingOrderId;

  final List<String> _orderTypes = [
    'أمر شراء',
    'طلب مواد',
    'طلب تحويل بين الفروع',
    'مستودع بضاعة في الطريق',
  ];

  @override
  void dispose() {
    _numberController.dispose();
    _companyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _setSource(String source) {
    setState(() {
      _activeSource = source;
    });
  }

  void _setTab(String tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _saveOrder() {
    if (_numberController.text.isEmpty ||
        _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول')),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (_editingOrderId != null) {
      // Update existing order
      final updatedOrder = Order(
        id: _editingOrderId!,
        number: _numberController.text,
        company: _companyController.text,
        type: _selectedType,
        date: dateStr,
        notes: _notesController.text,
        status: context.read<OrdersProvider>().findOrder(_activeSource, _editingOrderId!)?.status ?? 'pending',
      );
      context.read<OrdersProvider>().updateOrder(_activeSource, _editingOrderId!, updatedOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الطلب بنجاح')),
      );
      _cancelEdit();
    } else {
      // Add new order
      final newOrder = Order(
        id: DateTime.now().millisecondsSinceEpoch,
        number: _numberController.text,
        company: _companyController.text,
        type: _selectedType,
        date: dateStr,
        notes: _notesController.text,
        status: 'pending',
      );
      context.read<OrdersProvider>().addOrder(_activeSource, newOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة الطلب بنجاح')),
      );
    }

    _clearForm();
  }

  void _clearForm() {
    setState(() {
      _numberController.clear();
      _companyController.clear();
      _notesController.clear();
      _selectedType = 'أمر شراء';
      _selectedDate = DateTime.now();
      _editingOrderId = null;
    });
  }

  void _editOrder(Order order) {
    setState(() {
      _setSource(_activeTab);
      _numberController.text = order.number;
      _companyController.text = order.company;
      _selectedType = order.type;
      _selectedDate = DateTime.parse(order.date);
      _notesController.text = order.notes;
      _editingOrderId = order.id;
    });
  }

  void _cancelEdit() {
    _clearForm();
  }

  void _deleteOrder(int orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الطلب نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrdersProvider>().deleteOrder(_activeTab, orderId);
              Navigator.pop(context);
              if (_editingOrderId == orderId) {
                _cancelEdit();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الطلب')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
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
          'إدارة الطلبات',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Left panel - Order form
          Container(
            width: 380,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.purple[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            _editingOrderId != null ? 'تعديل الطلب' : 'إضافة طلب جديد',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Source selector
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _setSource('showroom'),
                                  icon: const Icon(Icons.store, size: 16),
                                  label: const Text('المعرض', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _activeSource == 'showroom'
                                        ? const Color(0xFF0f766e)
                                        : Colors.transparent,
                                    foregroundColor: _activeSource == 'showroom'
                                        ? Colors.white
                                        : Colors.grey[500],
                                    elevation: _activeSource == 'showroom' ? 2 : 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _setSource('cafe'),
                                  icon: const Icon(Icons.coffee, size: 16),
                                  label: const Text('الكافيه', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _activeSource == 'cafe'
                                        ? const Color(0xFF8c6b5d)
                                        : Colors.transparent,
                                    foregroundColor: _activeSource == 'cafe'
                                        ? Colors.white
                                        : Colors.grey[500],
                                    elevation: _activeSource == 'cafe' ? 2 : 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Order number
                        const Text(
                          'رقم الطلب',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _numberController,
                          decoration: InputDecoration(
                            hintText: 'مثلاً: PO-2024-001',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Company
                        const Text(
                          'اسم المحمصة أو الشركة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _companyController,
                          decoration: InputDecoration(
                            hintText: 'اسم المورد...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Order type
                        const Text(
                          'نوع الطلب',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          items: _orderTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Date
                        const Text(
                          'تاريخ الطلب',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const Icon(Icons.calendar_today, size: 20, color: Colors.purple),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Notes
                        const Text(
                          'ملاحظات إضافية',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'أي تفاصيل إضافية...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.purple, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _editingOrderId != null ? 'حفظ التعديلات' : 'تسجيل الطلب',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (_editingOrderId != null) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _cancelEdit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.grey[700],
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('إلغاء التعديل'),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('تأكيد'),
                                content: const Text('هل أنت متأكد من حذف جميع بيانات الطلبات؟'),
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
                              await context.read<OrdersProvider>().clearAllOrders();
                              _cancelEdit();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم حذف بيانات الطلبات')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('حذف بيانات الطلبات', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Right panel - Orders table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Tabs
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _setTab('showroom'),
                          icon: const Icon(Icons.store),
                          label: const Text('طلبات المعرض'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _activeTab == 'showroom'
                                ? Colors.white
                                : Colors.white,
                            foregroundColor: _activeTab == 'showroom'
                                ? const Color(0xFF0f766e)
                                : Colors.grey[400],
                            side: BorderSide(
                              color: _activeTab == 'showroom'
                                  ? const Color(0xFF0f766e)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _setTab('cafe'),
                          icon: const Icon(Icons.coffee),
                          label: const Text('طلبات الكافيه'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _activeTab == 'cafe'
                                ? Colors.white
                                : Colors.white,
                            foregroundColor: _activeTab == 'cafe'
                                ? const Color(0xFF8c6b5d)
                                : Colors.grey[400],
                            side: BorderSide(
                              color: _activeTab == 'cafe'
                                  ? const Color(0xFF8c6b5d)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Table
                  Expanded(
                    child: _buildOrdersTable(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable() {
    return Consumer<OrdersProvider>(
      builder: (context, provider, child) {
        final orders = provider.getOrders(_activeTab);

        if (orders.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد طلبات مسجلة في هذا القسم',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
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
                    Row(
                      children: [
                        Icon(
                          _activeTab == 'showroom' ? Icons.store : Icons.coffee,
                          color: _activeTab == 'showroom'
                              ? const Color(0xFF0f766e)
                              : const Color(0xFF8c6b5d),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'قائمة الطلبات الجارية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 16,
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                      columns: const [
                        DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('رقم الطلب', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الجهة / المحمصة', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('نوع الطلب', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('ملاحظات', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('تاريخ الطلب', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('المدة', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('إجراء', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: orders.map((order) {
                        final isCompleted = order.status == 'completed';
                        final daysSince = provider.calculateDaysSince(order.date);
                        final isOverdue = !isCompleted && daysSince > 7;

                        return DataRow(
                          color: MaterialStateProperty.all(
                            isCompleted
                                ? Colors.grey[50]
                                : (isOverdue ? Colors.red[50] : null),
                          ),
                          cells: [
                            DataCell(
                              IconButton(
                                onPressed: () {
                                  provider.toggleOrderStatus(_activeTab, order.id);
                                },
                                icon: Icon(
                                  Icons.check_circle,
                                  color: isCompleted ? Colors.green : Colors.grey[300],
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                order.number,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  color: isCompleted ? Colors.grey : Colors.grey[700],
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                order.company,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.grey[500] : Colors.grey[800],
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey[200]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  order.type,
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  order.notes.isNotEmpty ? order.notes : '-',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat('dd/MM/yyyy').format(DateTime.parse(order.date)),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Text(
                                    '$daysSince يوم',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isOverdue
                                          ? Colors.red[600]
                                          : (isCompleted ? Colors.grey[400] : Colors.grey[600]),
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  if (isOverdue) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.warning, size: 16, color: Colors.red[500]),
                                  ],
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _editOrder(order),
                                    icon: const Icon(Icons.edit, size: 18),
                                    color: Colors.blue[500],
                                    tooltip: 'تعديل',
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteOrder(order.id),
                                    icon: const Icon(Icons.delete, size: 18),
                                    color: Colors.grey[400],
                                    tooltip: 'حذف',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
}
