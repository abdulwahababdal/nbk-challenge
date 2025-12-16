using BankingBackOffice.Api.Models;
using BankingBackOffice.Api.Models.DTOs;
using BankingBackOffice.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BankingBackOffice.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class CustomersController : ControllerBase
{
    private readonly ICustomerService _customerService;

    public CustomersController(ICustomerService customerService)
    {
        _customerService = customerService;
    }

    [HttpGet]
    public async Task<ActionResult<ApiResponse<List<Customer>>>> GetAllCustomers()
    {
        var customers = await _customerService.GetAllCustomersAsync();
        return Ok(ApiResponse<List<Customer>>.SuccessResponse(customers, "Customers retrieved successfully"));
    }

    [HttpGet("{customerNumber}")]
    public async Task<ActionResult<ApiResponse<Customer>>> GetCustomer(int customerNumber)
    {
        var customer = await _customerService.GetCustomerByNumberAsync(customerNumber);

        if (customer == null)
        {
            return NotFound(ApiResponse<Customer>.ErrorResponse("Customer not found"));
        }

        return Ok(ApiResponse<Customer>.SuccessResponse(customer, "Customer retrieved successfully"));
    }

    [HttpPost]
    public async Task<ActionResult<ApiResponse<Customer>>> CreateCustomer([FromBody] CustomerDto customerDto)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<Customer>.ErrorResponse("Invalid request", errors));
        }

        var (success, message, customer) = await _customerService.CreateCustomerAsync(customerDto);

        if (!success)
        {
            return BadRequest(ApiResponse<Customer>.ErrorResponse(message));
        }

        return CreatedAtAction(nameof(GetCustomer), new { customerNumber = customer!.CustomerNumber },
            ApiResponse<Customer>.SuccessResponse(customer, message));
    }

    [HttpPut("{customerNumber}")]
    public async Task<ActionResult<ApiResponse<Customer>>> UpdateCustomer(int customerNumber, [FromBody] CustomerDto customerDto)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<Customer>.ErrorResponse("Invalid request", errors));
        }

        var (success, message, customer) = await _customerService.UpdateCustomerAsync(customerNumber, customerDto);

        if (!success)
        {
            return NotFound(ApiResponse<Customer>.ErrorResponse(message));
        }

        return Ok(ApiResponse<Customer>.SuccessResponse(customer, message));
    }

    [HttpDelete("{customerNumber}")]
    public async Task<ActionResult<ApiResponse<object>>> DeleteCustomer(int customerNumber)
    {
        var (success, message) = await _customerService.DeleteCustomerAsync(customerNumber);

        if (!success)
        {
            return NotFound(ApiResponse<object>.ErrorResponse(message));
        }

        return Ok(ApiResponse<object>.SuccessResponse(null, message));
    }
}
