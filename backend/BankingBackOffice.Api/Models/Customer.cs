using System.ComponentModel.DataAnnotations;

namespace BankingBackOffice.Api.Models;

public class Customer
{
    [Key]
    public int CustomerNumber { get; set; }

    [Required]
    [MaxLength(255)]
    public string CustomerName { get; set; } = string.Empty;

    [Required]
    public DateTime DateOfBirth { get; set; }

    [Required]
    [MaxLength(1)]
    public string Gender { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}
