using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using BankingBackOffice.Api.Data;
using BankingBackOffice.Api.Models;
using BankingBackOffice.Api.Models.DTOs;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace BankingBackOffice.Api.Services;

public class AuthService : IAuthService
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthService(ApplicationDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<LoginResponseDto?> AuthenticateAsync(LoginRequestDto loginRequest)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Username == loginRequest.Username);

        if (user == null)
            return null;

        // Verify password
        if (!BCrypt.Net.BCrypt.Verify(loginRequest.Password, user.PasswordHash))
            return null;

        // Generate JWT token
        var token = GenerateJwtToken(user);
        var expirationMinutes = int.Parse(_configuration["JwtSettings:ExpirationInMinutes"] ?? "60");

        return new LoginResponseDto
        {
            Token = token,
            Username = user.Username,
            FullName = user.FullName,
            ExpiresAt = DateTime.UtcNow.AddMinutes(expirationMinutes)
        };
    }

    public async Task SeedDefaultUserAsync()
    {
        if (!await _context.Users.AnyAsync())
        {
            var defaultUser = new User
            {
                Username = "admin",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                FullName = "System Administrator"
            };

            _context.Users.Add(defaultUser);
            await _context.SaveChangesAsync();
        }
    }

    private string GenerateJwtToken(User user)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey not configured");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var expirationMinutes = int.Parse(jwtSettings["ExpirationInMinutes"] ?? "60");

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.GivenName, user.FullName),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: jwtSettings["Issuer"],
            audience: jwtSettings["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expirationMinutes),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
