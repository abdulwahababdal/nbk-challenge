using System.ComponentModel.DataAnnotations;

namespace BankingBackOffice.Api.Models.DTOs;

public class CustomerDto
{
    public int? CustomerNumber { get; set; }

    [Required(ErrorMessage = "Customer name is required")]
    [MaxLength(255, ErrorMessage = "Customer name cannot exceed 255 characters")]
    public string CustomerName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Date of birth is required")]
    public DateTime DateOfBirth { get; set; }

    [Required(ErrorMessage = "Gender is required")]
    [RegularExpression("^[MF]$", ErrorMessage = "Gender must be 'M' or 'F'")]
    public string Gender { get; set; } = string.Empty;
}
