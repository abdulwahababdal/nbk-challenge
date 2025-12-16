using BankingBackOffice.Api.Models;
using BankingBackOffice.Api.Models.DTOs;

namespace BankingBackOffice.Api.Services;

public interface ICustomerService
{
    Task<List<Customer>> GetAllCustomersAsync();
    Task<Customer?> GetCustomerByNumberAsync(int customerNumber);
    Task<(bool Success, string Message, Customer? Customer)> CreateCustomerAsync(CustomerDto customerDto);
    Task<(bool Success, string Message, Customer? Customer)> UpdateCustomerAsync(int customerNumber, CustomerDto customerDto);
    Task<(bool Success, string Message)> DeleteCustomerAsync(int customerNumber);
    Task<bool> CustomerNumberExistsAsync(int customerNumber);
}
