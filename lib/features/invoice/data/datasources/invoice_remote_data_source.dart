import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/invoice_model.dart';

class InvoiceRemoteDataSource {
  final DioClient _dioClient;

  InvoiceRemoteDataSource(this._dioClient);

  // 1. Faturaları Sayfalı Getir (/api/Invoice?pageNumber=1&pageSize=10)
  Future<List<InvoiceModel>> getMyInvoices({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      print(">>> [REMOTE REQ]: Page: $pageNumber | Size: $pageSize");

      final response = await _dioClient.get(
        'Invoice',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      print(">>> [REMOTE RESPONSE REAL URI]: ${response.realUri}");

      dynamic responseData = response.data;

      // Backend yanıtı doğrudan List değil de { data: [...], items: [...] } gibi sarmalanmışsa:
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data') && responseData['data'] is List) {
          responseData = responseData['data'];
        } else if (responseData.containsKey('items') && responseData['items'] is List) {
          responseData = responseData['items'];
        }
      }

      if (responseData is List) {
        return responseData
            .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      print("========== GET ERROR ==========");
      print("Status Code: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      print("===============================");
      rethrow;
    }
  }

  // 2. Tek Fatura Getir (/api/Invoice/{id})
  Future<InvoiceModel> getInvoiceById(int id) async {
    try {
      final response = await _dioClient.get('Invoice/$id');
      return InvoiceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print("========== GET BY ID ERROR ==========");
      print("Status Code: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      print("=====================================");
      rethrow;
    }
  }

  // 3. Fatura Ekle (/api/Invoice)
  Future<void> createInvoice(InvoiceModel invoice) async {
    try {
      final payload = invoice.toJson();

      print("========== GÖNDERİLEN JSON ==========");
      print(jsonEncode(payload));
      print("=====================================");

      final response = await _dioClient.post(
        'Invoice',
        data: payload,
      );

      print("POST SUCCESS");
      print(response.data);
    } on DioException catch (e) {
      print("========== POST ERROR ==========");
      print("Status Code: ${e.response?.statusCode}");
      print("Response Data: ${e.response?.data}");
      print("Request Data: ${jsonEncode(invoice.toJson())}");
      print("================================");
      rethrow;
    }
  }
}