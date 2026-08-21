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

  void _showInvoiceDetailBottomSheet(BuildContext context, InvoiceModel invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fatura #${invoice.id ?? "-"}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    invoice.invoiceType ?? 'SATIŞ',
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 16),
            _buildDetailRow('Müşteri / Firma', invoice.customerName.isNotEmpty ? invoice.customerName : 'Belirtilmedi'),
            _buildDetailRow('VKN / TCKN', invoice.vknTckn ?? 'Belirtilmedi'),
            _buildDetailRow('Vergi Dairesi', invoice.taxOffice ?? 'Belirtilmedi'),
            _buildDetailRow('Şehir', invoice.city ?? 'Belirtilmedi'),
            _buildDetailRow('Senaryo', invoice.scenario ?? 'TİCARİ FATURA'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Ara Tutar', '${invoice.amount ?? 0.0} ₺'),
                  const SizedBox(height: 6),
                  _buildDetailRow('KDV (%20)', '${invoice.taxAmount ?? 0.0} ₺'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Genel Toplam',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        '${invoice.totalAmount ?? invoice.amount ?? 0.0} ₺',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(bottomSheetContext),
                child: const Text('Kapat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 13)),
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
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF1E293B)),
                tooltip: 'Giriş Ekranına Dön',
                onPressed: () => _logout(context),
              ),
              title: const Text(
                'Faturalarım',
                style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 18),
              ),
              actions: [
                Builder(
                  builder: (btnContext) => IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF1E293B)),
                    onPressed: () => _showSearchDialog(btnContext),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  tooltip: 'Çıkış Yap',
                  onPressed: () => _logout(context),
                ),
              ],
            ),
            // Sade yuvarlak buton: ekranı kapatmaz
            floatingActionButton: Builder(
              builder: (fabContext) => FloatingActionButton(
                backgroundColor: const Color(0xFF2563EB),
                elevation: 4,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
                onPressed: () => _showAddInvoiceBottomSheet(fabContext),
              ),
            ),
            // Alt kısımda sabit, temiz ve şık Daha Fazla Yükle paneli
            bottomNavigationBar: BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                if (state is InvoiceLoaded && state.invoices.isNotEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: SafeArea(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFFEFF6FF),
                        ),
                        onPressed: () {
                          context.read<InvoiceCubit>().loadMoreInvoices();
                        },
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2563EB), size: 22),
                        label: const Text(
                          'Daha Fazla Yükle',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
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
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
                } else if (state is InvoiceError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 48),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFFEF4444), fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => context.read<InvoiceCubit>().fetchMyInvoices(),
                            child: const Text('Tekrar Deneyin', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is InvoiceLoaded) {
                  if (state.invoices.isEmpty) {
                    return RefreshIndicator(
                      color: const Color(0xFF2563EB),
                      onRefresh: () async {
                        await context.read<InvoiceCubit>().fetchMyInvoices();
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Text(
                              'Kayıtlı fatura bulunamadı.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF2563EB),
                    onRefresh: () async {
                      await context.read<InvoiceCubit>().fetchMyInvoices();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: state.invoices.length,
                      itemBuilder: (context, index) {
                        final inv = state.invoices[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => _showInvoiceDetailBottomSheet(context, inv),
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB), size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            inv.customerName.isNotEmpty ? inv.customerName : 'Müşteri Belirtilmedi',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '#${inv.id ?? "-"} • ${inv.city ?? "Şehir Yok"}',
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${inv.totalAmount ?? inv.amount} ₺',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF2563EB),
                                          ),
                                        ),
                                        if (inv.taxAmount != null)
                                          Text(
                                            'KDV: ${inv.taxAmount} ₺',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Fatura ID ile Ara', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Örn: 24148',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final id = int.tryParse(controller.text.trim());
              if (id != null) {
                context.read<InvoiceCubit>().fetchInvoiceById(id);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Ara', style: TextStyle(color: Colors.white)),
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

    InputDecoration inputDeco(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetBuilderContext, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: SingleChildScrollView(
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
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Yeni Fatura Ekle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: userIdController,
                  decoration: inputDeco('Kullanıcı ID (User ID)', Icons.person_outline),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: customerNameController,
                  decoration: inputDeco('Müşteri / Firma Adı', Icons.business_outlined),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: vknTcknController,
                  keyboardType: TextInputType.number,
                  decoration: inputDeco('VKN / TCKN', Icons.badge_outlined),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: taxOfficeController,
                  decoration: inputDeco('Vergi Dairesi', Icons.account_balance_outlined),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: inputDeco('Tutar (₺)', Icons.currency_lira_outlined),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cityController,
                  decoration: inputDeco('Şehir', Icons.location_city_outlined),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: inputDeco('Fatura Tipi', Icons.category_outlined),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
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
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        }
                      } catch (e) {
                        if (parentContext.mounted) {
                          showDialog(
                            context: parentContext,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Backend Hata Detayı (400)', style: TextStyle(color: Colors.red)),
                              content: SingleChildScrollView(child: Text(e.toString())),
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
                    child: const Text('Kaydet ve Gönder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}