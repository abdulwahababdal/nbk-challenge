using BankingBackOffice.Api.Models.DTOs;

namespace BankingBackOffice.Api.Services;

public interface IAuthService
{
    Task<LoginResponseDto?> AuthenticateAsync(LoginRequestDto loginRequest);
    Task SeedDefaultUserAsync();
}
