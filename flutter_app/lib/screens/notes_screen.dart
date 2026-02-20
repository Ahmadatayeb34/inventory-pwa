import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inventory_item.dart';
import '../providers/inventory_provider.dart';
import '../widgets/search_field.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _roasteryController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _searchQuery = '';
  InventoryItem? _selectedItem;

  @override
  void dispose() {
    _searchController.dispose();
    _roasteryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectItem(InventoryItem item) {
    setState(() {
      _selectedItem = item;
      _searchQuery = '';
      _searchController.clear();
      _roasteryController.text = item.roastery;
      _notesController.text = item.notes;
    });
  }

  void _saveNotes() {
    if (_selectedItem == null) return;

    context.read<InventoryProvider>().updateNotes(
          _selectedItem!.code,
          _roasteryController.text,
          _notesController.text,
        );

    setState(() {
      _selectedItem = context.read<InventoryProvider>().findByCode(_selectedItem!.code);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الملاحظات')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1b4b),
        title: const Text(
          'دليل القهوة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Left panel
          Container(
            width: 400,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'سجل الإيحاءات',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SearchField(
                        hintText: 'ابحث بالإيحاء...',
                        icon: Icons.coffee,
                        controller: _searchController,
                        borderColor: Colors.green[200],
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
                                foregroundColor: Colors.green[700],
                                side: BorderSide(color: Colors.green[200]!),
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
                                foregroundColor: Colors.green[700],
                                side: BorderSide(color: Colors.green[200]!),
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
                              content: const Text('هل أنت متأكد من حذف جميع الإيحاءات والملاحظات؟'),
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
                            await context.read<InventoryProvider>().clearAllNotes();
                            setState(() {
                              _selectedItem = null;
                              _roasteryController.clear();
                              _notesController.clear();
                            });
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم حذف سجل الإيحاءات')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('تصفير سجل الإيحاءات فقط', style: TextStyle(fontSize: 12)),
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
                              Icon(Icons.edit_note, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'اختر صنفاً لتعديل بياناته',
                                style: TextStyle(color: Colors.grey[400], fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : _buildNotesEditor(),
                ),
              ],
            ),
          ),
          // Right panel - Table
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _buildNotesTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesEditor() {
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
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedItem!.code,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'اسم المحمصة',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _roasteryController,
            decoration: InputDecoration(
              hintText: 'مثلاً: محمصة الرياض',
              prefixIcon: const Icon(Icons.local_fire_department, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'الإيحاءات / الملاحظات',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'أدخل الإيحاءات هنا...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveNotes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'حفظ التعديلات',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTable() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        List<InventoryItem> items;
        
        if (_searchQuery.isEmpty) {
          items = provider.inventory;
        } else {
          items = provider.inventory.where((item) {
            final searchStr = (item.name + item.roastery + item.notes).toLowerCase();
            return searchStr.contains(_searchQuery);
          }).toList();
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'دليل القهوة',
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
                        DataColumn(label: Text('المحمصة', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الإيحاءات / الملاحظات', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: items.map((item) {
                        return DataRow(
                          selected: _selectedItem?.code == item.code,
                          onSelectChanged: (_) => _selectItem(item),
                          cells: [
                            DataCell(Text(
                              item.code,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            )),
                            DataCell(Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(
                              item.roastery.isNotEmpty
                                  ? Row(
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department,
                                          size: 14,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.roastery,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      '-',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                            ),
                            DataCell(
                              item.notes.isNotEmpty
                                  ? SizedBox(
                                      width: 300,
                                      child: Text(
                                        item.notes,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  : const Text(
                                      'لا توجد ملاحظات',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
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
