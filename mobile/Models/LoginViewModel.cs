using System.ComponentModel.DataAnnotations;

namespace mobile.Models;

public class LoginViewModel
{
    [Required(ErrorMessage = "Vui lòng nhập email hoặc tên đăng nhập.")]
    public string EmailOrUsername { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập mật khẩu.")]
    [DataType(DataType.Password)]
    public string Password { get; set; } = string.Empty;

    public string? ReturnUrl { get; set; }
}
