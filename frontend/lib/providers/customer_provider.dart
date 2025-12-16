import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class CustomerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setApiToken(String? token) {
    _apiService.setToken(token);
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getCustomers();

      if (response.success && response.data != null) {
        _customers = response.data!;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Failed to load customers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCustomer(Customer customer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.createCustomer(customer);

      if (response.success && response.data != null) {
        _customers.insert(0, response.data!);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to create customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(int customerNumber, Customer customer) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.updateCustomer(customerNumber, customer);

      if (response.success && response.data != null) {
        final index = _customers
            .indexWhere((c) => c.customerNumber == customerNumber);
        if (index != -1) {
          _customers[index] = response.data!;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCustomer(int customerNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.deleteCustomer(customerNumber);

      if (response.success) {
        _customers.removeWhere((c) => c.customerNumber == customerNumber);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete customer: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
