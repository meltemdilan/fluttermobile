import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/init/service_locator.dart';
import '../../../auth/presentation/views/login_view.dart';
import '../cubit/invoice_cubit.dart';
import '../cubit/invoice_state.dart';
import '../../data/models/invoice_model.dart';

class InvoiceListView extends StatelessWidget {
  const InvoiceListView({super.key});

  Future<void> _logout(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt_token');
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  // Fatura Detay Modalı
  void _showInvoiceDetailBottomSheet(BuildContext context, InvoiceModel invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fatura #${invoice.id ?? "-"}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    invoice.invoiceType ?? 'SATIŞ',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.indigo,
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Müşteri / Firma:', invoice.customerName.isNotEmpty ? invoice.customerName : 'Belirtilmedi'),
            _buildDetailRow('VKN / TCKN:', invoice.vknTckn ?? 'Belirtilmedi'),
            _buildDetailRow('Vergi Dairesi:', invoice.taxOffice ?? 'Belirtilmedi'),
            _buildDetailRow('Şehir:', invoice.city ?? 'Belirtilmedi'),
            _buildDetailRow('Senaryo:', invoice.scenario ?? 'TİCARİ FATURA'),
            const Divider(height: 24),
            _buildDetailRow('Ara Tutar:', '${invoice.amount ?? 0.0} ₺'),
            _buildDetailRow('KDV (%20):', '${invoice.taxAmount ?? 0.0} ₺'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Genel Toplam:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '${invoice.totalAmount ?? invoice.amount ?? 0.0} ₺',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                onPressed: () => Navigator.pop(bottomSheetContext),
                child: const Text('Kapat', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InvoiceCubit>()..fetchMyInvoices(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Giriş Ekranına Dön / Çıkış Yap',
                onPressed: () => _logout(context),
              ),
              title: const Text('Faturalarım'),
              centerTitle: true,
              actions: [
                Builder(
                  builder: (btnContext) => IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _showSearchDialog(btnContext),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  tooltip: 'Çıkış Yap',
                  onPressed: () => _logout(context),
                ),
              ],
            ),
            floatingActionButton: Builder(
              builder: (fabContext) => FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => _showAddInvoiceBottomSheet(fabContext),
              ),
            ),
            bottomNavigationBar: BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                if (state is InvoiceLoaded && state.invoices.isNotEmpty) {
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.read<InvoiceCubit>().loadMoreInvoices();
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'Daha Fazla Yükle',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            body: BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                if (state is InvoiceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InvoiceError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<InvoiceCubit>().fetchMyInvoices(),
                            child: const Text('Tekrar Deneyin'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is InvoiceLoaded) {
                  if (state.invoices.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<InvoiceCubit>().fetchMyInvoices();
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 200),
                          Center(child: Text('Kayıtlı fatura bulunamadı.')),
                        ],
                      ),
                    );
                  }
                  
                  // Ekranı aşağı kaydırınca (Pull to refresh) tüm listeyi tekrar çeker
                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<InvoiceCubit>().fetchMyInvoices();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: state.invoices.length,
                      itemBuilder: (context, index) {
                        final inv = state.invoices[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.receipt_long),
                            ),
                            title: Text(
                              inv.customerName.isNotEmpty ? inv.customerName : 'Müşteri Belirtilmedi',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('ID: ${inv.id ?? "-"} | Şehir: ${inv.city ?? "Belirtilmedi"}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${inv.totalAmount ?? inv.amount} ₺',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),
                                ),
                                if (inv.taxAmount != null)
                                  Text(
                                    'KDV: ${inv.taxAmount} ₺',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // Tıklandığında faturayı detay kartıyla gösterir
                              _showInvoiceDetailBottomSheet(context, inv);
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Fatura ID ile Ara'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Fatura ID giriniz (Örn: 1)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final id = int.tryParse(controller.text.trim());
              if (id != null) {
                context.read<InvoiceCubit>().fetchInvoiceById(id);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  void _showAddInvoiceBottomSheet(BuildContext context) {
    final cubit = context.read<InvoiceCubit>();
    final parentContext = context;

    final userIdController = TextEditingController();
    final customerNameController = TextEditingController();
    final vknTcknController = TextEditingController();
    final taxOfficeController = TextEditingController();
    final amountController = TextEditingController();
    final cityController = TextEditingController();
    String selectedType = 'SATIŞ';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetBuilderContext, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yeni Fatura Ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: userIdController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı ID (User ID)',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Müşteri / Firma Adı',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: vknTcknController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'VKN / TCKN',
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: taxOfficeController,
                  decoration: const InputDecoration(
                    labelText: 'Vergi Dairesi',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Tutar (₺)',
                    prefixIcon: Icon(Icons.currency_lira),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Şehir',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Fatura Tipi',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ['SATIŞ', 'İADE', 'TEVKİFAT'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedType = val!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                    onPressed: () async {
                      final customerName = customerNameController.text.trim();
                      final amountText = amountController.text.trim();
                      final userIdText = userIdController.text.trim();

                      if (customerName.isEmpty || amountText.isEmpty || userIdText.isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(content: Text('Lütfen Kullanıcı ID, Müşteri Adı ve Tutar giriniz.')),
                        );
                        return;
                      }

                      Navigator.of(sheetContext).pop();

                      final double parsedAmount = double.tryParse(amountText) ?? 0.0;

                      final newInvoice = InvoiceModel(
                        userId: userIdText,
                        customerName: customerName,
                        vknTckn: vknTcknController.text.trim(),
                        taxOffice: taxOfficeController.text.trim(),
                        amount: parsedAmount,
                        taxAmount: parsedAmount * 0.20,
                        totalAmount: parsedAmount * 1.20,
                        city: cityController.text.trim(),
                        invoiceType: selectedType,
                        scenario: 'TİCARİ FATURA',
                      );

                      try {
                        await cubit.createInvoice(newInvoice);
                        if (parentContext.mounted) {
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                              content: Text('Fatura başarıyla eklendi!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (parentContext.mounted) {
                          showDialog(
                            context: parentContext,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Backend Hata Detayı (400)', style: TextStyle(color: Colors.red)),
                              content: SingleChildScrollView(
                                child: Text(e.toString()),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Kapat'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Kaydet ve Gönder', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}