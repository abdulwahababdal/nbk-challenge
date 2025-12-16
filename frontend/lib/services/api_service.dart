import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/customer.dart';
import '../models/user.dart';

class ApiService {
  // Update this URL to match your backend API endpoint
  // For Android Emulator: http://10.0.2.2:5000
  // For iOS Simulator: http://localhost:5000
  // For physical device: http://YOUR_COMPUTER_IP:5000
  static const String baseUrl = 'http://localhost:5000/api';

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _getHeaders({bool includeAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<ApiResponse<User>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<User>.fromJson(
          json,
          (data) => User.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResponse<User>(
          success: false,
          message: json['message'] ?? 'Login failed',
          errors: json['errors'] != null
              ? List<String>.from(json['errors'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<List<Customer>>> getCustomers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers'),
        headers: _getHeaders(includeAuth: true),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<List<Customer>>.fromJson(
          json,
          (data) => (data as List)
              .map((item) => Customer.fromJson(item as Map<String, dynamic>))
              .toList(),
        );
      } else {
        return ApiResponse<List<Customer>>(
          success: false,
          message: json['message'] ?? 'Failed to fetch customers',
          errors: json['errors'] != null
              ? List<String>.from(json['errors'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<List<Customer>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Customer>> getCustomer(int customerNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/customers/$customerNumber'),
        headers: _getHeaders(includeAuth: true),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<Customer>.fromJson(
          json,
          (data) => Customer.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResponse<Customer>(
          success: false,
          message: json['message'] ?? 'Failed to fetch customer',
          errors: json['errors'] != null
              ? List<String>.from(json['errors'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<Customer>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Customer>> createCustomer(Customer customer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/customers'),
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(customer.toJson()),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<Customer>.fromJson(
          json,
          (data) => Customer.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResponse<Customer>(
          success: false,
          message: json['message'] ?? 'Failed to create customer',
          errors: json['errors'] != null
              ? List<String>.from(json['errors'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<Customer>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<Customer>> updateCustomer(
      int customerNumber, Customer customer) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/customers/$customerNumber'),
        headers: _getHeaders(includeAuth: true),
        body: jsonEncode(customer.toJson()),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<Customer>.fromJson(
          json,
          (data) => Customer.fromJson(data as Map<String, dynamic>),
        );
      } else {
        return ApiResponse<Customer>(
          success: false,
          message: json['message'] ?? 'Failed to update customer',
          errors: json['errors'] != null
              ? List<String>.from(json['errors'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<Customer>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> deleteCustomer(int customerNumber) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/customers/$customerNumber'),
        headers: _getHeaders(includeAuth: true),
      );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: json['message'] ?? 'Customer deleted successfully',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: json['message'] ?? 'Failed to delete customer',
          errors: json['errors'] != null
              ? List<String>.from(json['errors'])
              : null,
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
