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
      customerName: json['customerName'] ?? json['CustomerName'] ?? '',
      amount: (json['amount'] ?? json['Amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] ?? json['TaxAmount'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] ?? json['TotalAmount'] as num?)?.toDouble(),
      city: json['city'] ?? json['City'],
      invoiceType: json['invoiceType'] ?? json['InvoiceType'] ?? 'SATIŞ',
      scenario: json['scenario'] ?? json['Scenario'] ?? 'TİCARİ FATURA',
      invoiceDate: json['invoiceDate']?.toString(),
      currency: json['currency'] ?? json['Currency'] ?? 'TRY',
      vknTckn: json['vknTckn'] ?? json['VknTckn'],
      taxOffice: json['taxOffice'] ?? json['TaxOffice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null && id != 0) 'id': id,
      if (userId != null && userId!.isNotEmpty) 'userId': userId,
      'customerName': customerName,
      'amount': amount,
      'city': city ?? 'İstanbul',
      'invoiceType': invoiceType ?? 'SATIŞ',
      'scenario': scenario ?? 'TİCARİ FATURA',
      'invoiceDate': invoiceDate ?? DateTime.now().toIso8601String(),
      'currency': currency ?? 'TRY',
      'vknTckn': vknTckn ?? '',
      'taxOffice': taxOffice ?? '',
      'filePath': '',
      'taxAmount': taxAmount ?? (amount * 0.20),
      'totalAmount': totalAmount ?? (amount * 1.20),
    };
  }
}