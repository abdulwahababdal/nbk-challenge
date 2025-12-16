import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _customerNumberController.text =
          widget.customer!.customerNumber.toString();
      _customerNameController.text = widget.customer!.customerName;
      _selectedDate = widget.customer!.dateOfBirth;
      _selectedGender = widget.customer!.gender;
    }
  }

  @override
  void dispose() {
    _customerNumberController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select date of birth'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select gender'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);

      final customer = Customer(
        customerNumber: isEditing
            ? widget.customer!.customerNumber
            : (_customerNumberController.text.isEmpty
                ? 0
                : int.parse(_customerNumberController.text)),
        customerName: _customerNameController.text,
        dateOfBirth: _selectedDate!,
        gender: _selectedGender!,
      );

      bool success;
      if (isEditing) {
        success = await customerProvider.updateCustomer(
          widget.customer!.customerNumber,
          customer,
        );
      } else {
        success = await customerProvider.createCustomer(customer);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing
                    ? 'Customer updated successfully'
                    : 'Customer created successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                customerProvider.errorMessage ??
                    'Failed to ${isEditing ? "update" : "create"} customer',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEditing)
                TextFormField(
                  controller: _customerNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Number (Optional)',
                    helperText:
                        'Leave empty to auto-generate a 9-digit number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length != 9) {
                        return 'Customer number must be exactly 9 digits';
                      }
                    }
                    return null;
                  },
                ),
              if (!isEditing) const SizedBox(height: 16),
              if (isEditing)
                TextFormField(
                  controller: _customerNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  enabled: false,
                ),
              if (isEditing) const SizedBox(height: 16),
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter customer name';
                  }
                  if (value.length > 255) {
                    return 'Customer name cannot exceed 255 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : 'Select date',
                    style: TextStyle(
                      color: _selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gender *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Male'),
                      value: 'M',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedGender == 'M'
                              ? Colors.blue.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Female'),
                      value: 'F',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: _selectedGender == 'F'
                              ? Colors.blue.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<CustomerProvider>(
                builder: (context, customerProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: customerProvider.isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: customerProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isEditing ? 'Update Customer' : 'Create Customer',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
