import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';
import 'customer_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);

      if (authProvider.user != null) {
        customerProvider.setApiToken(authProvider.user!.token);
        customerProvider.loadCustomers();
      }
    });
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _handleDeleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
            'Are you sure you want to delete ${customer.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      final success =
          await customerProvider.deleteCustomer(customer.customerNumber);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Customer deleted successfully'
                  : customerProvider.errorMessage ?? 'Failed to delete customer',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToAddCustomer() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerFormScreen(),
      ),
    );

    if (result == true && mounted) {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      customerProvider.loadCustomers();
    }
  }

  Future<void> _navigateToEditCustomer(Customer customer) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerFormScreen(customer: customer),
      ),
    );

    if (result == true && mounted) {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      customerProvider.loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      authProvider.user?.fullName ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          if (customerProvider.isLoading && customerProvider.customers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (customerProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    customerProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => customerProvider.loadCustomers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (customerProvider.customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No customers yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first customer using the + button',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => customerProvider.loadCustomers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: customerProvider.customers.length,
              itemBuilder: (context, index) {
                final customer = customerProvider.customers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: customer.gender == 'M'
                          ? Colors.blue.shade100
                          : Colors.pink.shade100,
                      child: Text(
                        customer.customerName.isNotEmpty
                            ? customer.customerName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: customer.gender == 'M'
                              ? Colors.blue.shade800
                              : Colors.pink.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      customer.customerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('ID: ${customer.customerNumber}'),
                        Text(
                          'DOB: ${DateFormat('MMM dd, yyyy').format(customer.dateOfBirth)}',
                        ),
                        Text('Gender: ${customer.gender == "M" ? "Male" : "Female"}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateToEditCustomer(customer),
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _handleDeleteCustomer(customer),
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCustomer,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
