using System.ComponentModel.DataAnnotations;

namespace mobile.Models;

public class CheckoutPageViewModel
{
    [Required(ErrorMessage = "Vui lòng nhập họ tên.")]
    public string FullName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập email.")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ.")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập số điện thoại.")]
    public string Phone { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập địa chỉ giao hàng.")]
    public string ShippingAddress { get; set; } = string.Empty;

    public string? Note { get; set; }

    [Required(ErrorMessage = "Vui lòng chọn phương thức thanh toán.")]
    public string PaymentMethod { get; set; } = "BANK_QR";

    public IReadOnlyList<CartSummaryItemViewModel> Items { get; set; } = [];

    public decimal Subtotal { get; set; }
}
