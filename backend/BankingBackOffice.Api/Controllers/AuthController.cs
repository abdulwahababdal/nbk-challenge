using BankingBackOffice.Api.Models.DTOs;
using BankingBackOffice.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace BankingBackOffice.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    public async Task<ActionResult<ApiResponse<LoginResponseDto>>> Login([FromBody] LoginRequestDto loginRequest)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .ToList();
            return BadRequest(ApiResponse<LoginResponseDto>.ErrorResponse("Invalid request", errors));
        }

        var result = await _authService.AuthenticateAsync(loginRequest);

        if (result == null)
        {
            return Unauthorized(ApiResponse<LoginResponseDto>.ErrorResponse("Invalid username or password"));
        }

        return Ok(ApiResponse<LoginResponseDto>.SuccessResponse(result, "Login successful"));
    }
}
