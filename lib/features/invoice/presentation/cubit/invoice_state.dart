import '../../data/models/invoice_model.dart';

abstract class InvoiceState {}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<InvoiceModel> invoices;
  final InvoiceModel? selectedInvoice;
  final bool hasReachedMax;

  InvoiceLoaded({
    required this.invoices,
    this.selectedInvoice,
    this.hasReachedMax = false,
  });

  InvoiceLoaded copyWith({
    List<InvoiceModel>? invoices,
    InvoiceModel? selectedInvoice,
    bool? hasReachedMax,
  }) {
    return InvoiceLoaded(
      invoices: invoices ?? this.invoices,
      selectedInvoice: selectedInvoice ?? this.selectedInvoice,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class InvoiceError extends InvoiceState {
  final String message;

  InvoiceError(this.message);
}