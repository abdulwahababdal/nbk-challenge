using BankingBackOffice.Api.Data;
using BankingBackOffice.Api.Models;
using BankingBackOffice.Api.Models.DTOs;
using Microsoft.EntityFrameworkCore;

namespace BankingBackOffice.Api.Services;

public class CustomerService : ICustomerService
{
    private readonly ApplicationDbContext _context;

    public CustomerService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Customer>> GetAllCustomersAsync()
    {
        return await _context.Customers
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    public async Task<Customer?> GetCustomerByNumberAsync(int customerNumber)
    {
        return await _context.Customers
            .FirstOrDefaultAsync(c => c.CustomerNumber == customerNumber);
    }

    public async Task<(bool Success, string Message, Customer? Customer)> CreateCustomerAsync(CustomerDto customerDto)
    {
        // Generate unique customer number if not provided
        int customerNumber;
        if (customerDto.CustomerNumber.HasValue)
        {
            customerNumber = customerDto.CustomerNumber.Value;

            // Validate customer number is 9 digits
            if (customerNumber < 100000000 || customerNumber > 999999999)
            {
                return (false, "Customer number must be exactly 9 digits", null);
            }

            // Check if customer number already exists
            if (await CustomerNumberExistsAsync(customerNumber))
            {
                return (false, "Customer number already exists", null);
            }
        }
        else
        {
            // Auto-generate unique 9-digit customer number
            customerNumber = await GenerateUniqueCustomerNumberAsync();
        }

        var customer = new Customer
        {
            CustomerNumber = customerNumber,
            CustomerName = customerDto.CustomerName,
            DateOfBirth = customerDto.DateOfBirth,
            Gender = customerDto.Gender,
            CreatedAt = DateTime.UtcNow
        };

        _context.Customers.Add(customer);
        await _context.SaveChangesAsync();

        return (true, "Customer created successfully", customer);
    }

    public async Task<(bool Success, string Message, Customer? Customer)> UpdateCustomerAsync(int customerNumber, CustomerDto customerDto)
    {
        var customer = await GetCustomerByNumberAsync(customerNumber);
        if (customer == null)
        {
            return (false, "Customer not found", null);
        }

        customer.CustomerName = customerDto.CustomerName;
        customer.DateOfBirth = customerDto.DateOfBirth;
        customer.Gender = customerDto.Gender;
        customer.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return (true, "Customer updated successfully", customer);
    }

    public async Task<(bool Success, string Message)> DeleteCustomerAsync(int customerNumber)
    {
        var customer = await GetCustomerByNumberAsync(customerNumber);
        if (customer == null)
        {
            return (false, "Customer not found");
        }

        _context.Customers.Remove(customer);
        await _context.SaveChangesAsync();

        return (true, "Customer deleted successfully");
    }

    public async Task<bool> CustomerNumberExistsAsync(int customerNumber)
    {
        return await _context.Customers
            .AnyAsync(c => c.CustomerNumber == customerNumber);
    }

    private async Task<int> GenerateUniqueCustomerNumberAsync()
    {
        var random = new Random();
        int customerNumber;

        do
        {
            customerNumber = random.Next(100000000, 999999999);
        } while (await CustomerNumberExistsAsync(customerNumber));

        return customerNumber;
    }
}
