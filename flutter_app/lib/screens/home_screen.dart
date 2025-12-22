import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/dashboard_card.dart';
import 'inventory_screen.dart';
import 'expiry_screen.dart';
import 'notes_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e1b4b),
        elevation: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نظام الإدارة المتكامل - تطوير أحمد الطيب',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            Text(
              'نسخة محسنة V2.4',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () async {
              await context.read<InventoryProvider>().saveInventory();
              await context.read<OrdersProvider>().saveOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ جميع البيانات بنجاح'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'لوحة القيادة والمتابعة',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1e1b4b),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'نظرة عامة على حالة العمل',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            Consumer2<InventoryProvider, OrdersProvider>(
              builder: (context, inventoryProvider, ordersProvider, child) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    DashboardCard(
                      title: 'الجرد العام',
                      subtitle: 'إدارة الكميات وحذف الأصناف',
                      count: '${inventoryProvider.itemCount}',
                      icon: Icons.inventory_2,
                      iconBgColor: Colors.blue[50]!,
                      iconColor: Colors.blue[600]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InventoryScreen(),
                          ),
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'تنبيهات الصلاحية',
                      subtitle: 'متابعة التواريخ والدفعات',
                      count: '${inventoryProvider.expiryAlertsCount}',
                      icon: Icons.warning_amber,
                      iconBgColor: Colors.amber[50]!,
                      iconColor: Colors.amber[600]!,
                      countColor: Colors.amber[600],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExpiryScreen(),
                          ),
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'دليل القهوة',
                      subtitle: 'الوصفات والإيحاءات',
                      count: '${inventoryProvider.notesCount}',
                      icon: Icons.book,
                      iconBgColor: Colors.emerald[50] ?? Colors.green[50]!,
                      iconColor: Colors.emerald[600] ?? Colors.green[600]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotesScreen(),
                          ),
                        );
                      },
                    ),
                    DashboardCard(
                      title: 'طلبات قيد الانتظار',
                      subtitle: 'تشمل المعرض والكافيه',
                      count: '${ordersProvider.totalPendingCount}',
                      icon: Icons.shopping_cart,
                      iconBgColor: Colors.purple[50]!,
                      iconColor: Colors.purple[600]!,
                      countColor: Colors.purple[600],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrdersScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Import functionality placeholder
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ميزة الاستيراد ستكون متاحة قريباً'),
              ),
            );
          },
          icon: const Icon(Icons.file_upload),
          label: const Text('استيراد (الجرد فقط)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4f46e5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            // Export functionality placeholder
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ميزة التصدير ستكون متاحة قريباً'),
              ),
            );
          },
          icon: const Icon(Icons.file_download),
          label: const Text('تصدير (التقرير الشامل)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('تأكيد الحذف'),
                content: const Text(
                  'هل أنت متأكد تماماً من حذف جميع بيانات التطبيق بالكامل؟ لا يمكن التراجع عن هذا الإجراء!',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('حذف'),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await context.read<InventoryProvider>().clearQuantities();
              await context.read<InventoryProvider>().clearAllBatches();
              await context.read<InventoryProvider>().clearAllNotes();
              await context.read<OrdersProvider>().clearAllOrders();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف جميع بيانات التطبيق بنجاح'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.delete_forever),
          label: const Text('حذف جميع بيانات التطبيق'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

// Define emerald color since it's not in Flutter's default Colors
extension CustomColors on Colors {
  static MaterialColor get emerald => const MaterialColor(
        0xFF10b981,
        <int, Color>{
          50: Color(0xFFecfdf5),
          100: Color(0xFFd1fae5),
          200: Color(0xFFa7f3d0),
          300: Color(0xFF6ee7b7),
          400: Color(0xFF34d399),
          500: Color(0xFF10b981),
          600: Color(0xFF059669),
          700: Color(0xFF047857),
          800: Color(0xFF065f46),
          900: Color(0xFF064e3b),
        },
      );
}
