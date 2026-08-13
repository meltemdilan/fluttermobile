class InvoiceModel {
  final int? id;
  final String? userId;
  final String customerName;
  final double amount;
  final double? taxAmount;
  final double? totalAmount;
  final String? city;
  final String? invoiceType;
  final String? scenario;
  final String? invoiceDate;
  final String? currency;
  final String? vknTckn;
  final String? taxOffice;

  InvoiceModel({
    this.id,
    this.userId,
    required this.customerName,
    required this.amount,
    this.taxAmount,
    this.totalAmount,
    this.city,
    this.invoiceType,
    this.scenario,
    this.invoiceDate,
    this.currency,
    this.vknTckn,
    this.taxOffice,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id']?.toString() ?? ''),
      userId: json['userId']?.toString() ?? json['UserId']?.toString(),
      customerName: json['customerName']?.toString() ?? json['CustomerName']?.toString() ?? '',
      amount: double.tryParse((json['amount'] ?? json['Amount'])?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse((json['taxAmount'] ?? json['TaxAmount'])?.toString() ?? ''),
      totalAmount: double.tryParse((json['totalAmount'] ?? json['TotalAmount'])?.toString() ?? ''),
      city: json['city']?.toString() ?? json['City']?.toString(),
      invoiceType: json['invoiceType']?.toString() ?? json['InvoiceType']?.toString() ?? 'SATIŞ',
      scenario: json['scenario']?.toString() ?? json['Scenario']?.toString() ?? 'TİCARİ FATURA',
      invoiceDate: json['invoiceDate']?.toString(),
      currency: json['currency']?.toString() ?? json['Currency']?.toString() ?? 'TRY',
      vknTckn: json['vknTckn']?.toString() ?? json['VknTckn']?.toString(),
      taxOffice: json['taxOffice']?.toString() ?? json['TaxOffice']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'customerName': customerName,
      'amount': amount,
      'city': (city != null && city!.isNotEmpty) ? city : 'İstanbul',
      'invoiceType': (invoiceType != null && invoiceType!.isNotEmpty) ? invoiceType : 'SATIŞ',
      'scenario': (scenario != null && scenario!.isNotEmpty) ? scenario : 'TİCARİ FATURA',
      'currency': currency ?? 'TRY',
      'vknTckn': vknTckn ?? '',
      'taxOffice': taxOffice ?? '',
      'taxAmount': taxAmount ?? (amount * 0.20),
      'totalAmount': totalAmount ?? (amount * 1.20),
    };

    if (id != null && id! > 0) {
      data['id'] = id;
    }

    if (userId != null && userId!.isNotEmpty) {
      data['userId'] = userId;
    }

    return data;
  }
}