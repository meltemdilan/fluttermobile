import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../invoice/presentation/views/invoice_list_view.dart';

class TokenLoginView extends StatefulWidget {
  const TokenLoginView({super.key});

  @override
  State<TokenLoginView> createState() => _TokenLoginViewState();
}

class _TokenLoginViewState extends State<TokenLoginView> {
  final TextEditingController _tokenController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  Future<void> _loginWithToken() async {
    final token = _tokenController.text.trim();

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir Bearer Token giriniz!')),
      );
      return;
    }

    // Token'ı cihaza güvenli şekilde kaydet
    await _storage.write(key: 'jwt_token', value: token);

    if (!mounted) return;

    // Fatura Listesi Paneline Yönlendir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InvoiceListView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Token ile Giriş')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.vpn_key, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text(
              'Swagger veya Login yanıtından aldığınız JWT Token\'ı aşağıya yapıştırın:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6...',
                labelText: 'JWT Authorization Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.indigo,
              ),
              onPressed: _loginWithToken,
              child: const Text(
                'Token İle Doğrula ve Gir',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}