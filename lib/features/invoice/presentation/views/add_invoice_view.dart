import 'package:flutter/material.dart';

class AddInvoiceView extends StatefulWidget {
  const AddInvoiceView({super.key});

  @override
  State<AddInvoiceView> createState() => _AddInvoiceViewState();
}

class _AddInvoiceViewState extends State<AddInvoiceView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userIdController = TextEditingController(text: "1");
  final TextEditingController _vknTcknController = TextEditingController();
  final TextEditingController _taxOfficeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  double _amount = 0.0;
  double _taxAmount = 0.0;
  double _totalAmount = 0.0;

  void _calculateAmounts(String value) {
    double parsedAmount = double.tryParse(value) ?? 0.0;
    setState(() {
      _amount = parsedAmount;
      _taxAmount = _amount * 0.20;
      _totalAmount = _amount + _taxAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Fatura Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // User ID Alanı
              TextFormField(
                controller: _userIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı ID (User ID)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.isEmpty ? 'User ID boş olamaz' : null,
              ),
              const SizedBox(height: 12),

              // VKN / TCKN
              TextFormField(
                controller: _vknTcknController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'VKN / TCKN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (val) => val == null || val.isEmpty ? 'VKN/TCKN giriniz' : null,
              ),
              const SizedBox(height: 12),

              // Vergi Dairesi
              TextFormField(
                controller: _taxOfficeController,
                decoration: const InputDecoration(
                  labelText: 'Vergi Dairesi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Vergi dairesi giriniz' : null,
              ),
              const SizedBox(height: 12),

              // Tutar (KDV Hariç)
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Matrah Tutar (₺)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                onChanged: _calculateAmounts,
                validator: (val) => val == null || val.isEmpty ? 'Tutar giriniz' : null,
              ),
              const SizedBox(height: 16),

              // Otomatik KDV & Toplam Kartı
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("KDV (%20):"),
                          Text("${_taxAmount.toStringAsFixed(2)} TRY"),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Genel Toplam:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "${_totalAmount.toStringAsFixed(2)} TRY",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Buradan Cubit / Bloc üzerindeki ekleme fonksiyonu tetiklenecek
                  }
                },
                child: const Text('Faturayı Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}