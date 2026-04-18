using System.ComponentModel.DataAnnotations;

namespace mobile.Models;

public sealed class AdminLocalLoginViewModel
{
    [Required(ErrorMessage = "Vui long nhap tai khoan admin.")]
    [Display(Name = "Tai khoan")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui long nhap mat khau.")]
    [DataType(DataType.Password)]
    [Display(Name = "Mat khau")]
    public string Password { get; set; } = string.Empty;

    public string? ReturnUrl { get; set; }
}
