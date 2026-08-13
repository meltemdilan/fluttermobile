import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/invoice_remote_data_source.dart';
import '../../data/models/invoice_model.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final InvoiceRemoteDataSource _dataSource;

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasReachedMax = false;
  bool _isFetchingMore = false;
  List<InvoiceModel> _allInvoices = [];

  InvoiceCubit(this._dataSource) : super(InvoiceInitial());

  Future<void> fetchMyInvoices({bool isRefresh = false}) async {
    _currentPage = 1;
    _hasReachedMax = false;

    if (isRefresh) {
      _allInvoices.clear();
    }

    emit(InvoiceLoading());

    try {
      final invoices = await _dataSource.getMyInvoices(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      _allInvoices = List.from(invoices);
      _hasReachedMax = invoices.length < _pageSize;

      emit(
        InvoiceLoaded(
          invoices: List<InvoiceModel>.unmodifiable(_allInvoices),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } catch (e) {
      emit(
        InvoiceError(
          'Faturalar yüklenirken hata oluştu: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> loadMoreInvoices() async {
    if (_isFetchingMore || _hasReachedMax) return;

    _isFetchingMore = true;

    try {
      _currentPage++;

      final newInvoices = await _dataSource.getMyInvoices(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (newInvoices.isEmpty) {
        _hasReachedMax = true;
      } else {
        _allInvoices.addAll(newInvoices);
        _hasReachedMax = newInvoices.length < _pageSize;
      }

      emit(
        InvoiceLoaded(
          invoices: List<InvoiceModel>.unmodifiable(_allInvoices),
          hasReachedMax: _hasReachedMax,
        ),
      );
    } catch (e) {
      _currentPage--;
      if (state is InvoiceLoaded) {
        emit(
          (state as InvoiceLoaded).copyWith(
            hasReachedMax: _hasReachedMax,
          ),
        );
      }
    } finally {
      _isFetchingMore = false;
    }
  }

  Future<void> fetchInvoiceById(int id) async {
    try {
      final invoice = await _dataSource.getInvoiceById(id);

      if (state is InvoiceLoaded) {
        emit(
          (state as InvoiceLoaded).copyWith(
            selectedInvoice: invoice,
          ),
        );
      } else {
        emit(
          InvoiceLoaded(
            invoices: List<InvoiceModel>.unmodifiable(_allInvoices),
            selectedInvoice: invoice,
          ),
        );
      }
    } catch (e) {
      emit(
        InvoiceError(
          'Fatura detayı alınamadı (ID: $id): ${e.toString()}',
        ),
      );
    }
  }

  Future<void> createInvoice(InvoiceModel invoice) async {
    try {
      await _dataSource.createInvoice(invoice);
      await fetchMyInvoices(isRefresh: true);
    } catch (e) {
      emit(
        InvoiceError(
          'Fatura eklenirken hata oluştu: ${e.toString()}',
        ),
      );
    }
  }
}