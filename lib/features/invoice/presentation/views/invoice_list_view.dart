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
                    return const Center(child: Text('Kayıtlı fatura bulunamadı.'));
                  }
                  return ListView.builder(
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
                            if (inv.id != null) {
                              context.read<InvoiceCubit>().fetchInvoiceById(inv.id!);
                            }
                          },
                        ),
                      );
                    },
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