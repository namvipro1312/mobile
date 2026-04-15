namespace mobile.Models;

public class PaymentQrPageViewModel
{
    public int OrderId { get; init; }

    public decimal Amount { get; init; }

    public string BankId { get; init; } = string.Empty;

    public string BankName { get; init; } = string.Empty;

    public string AccountNumber { get; init; } = string.Empty;

    public string AccountName { get; init; } = string.Empty;

    public string TransferContent { get; init; } = string.Empty;

    public string QrImageUrl { get; init; } = string.Empty;

    public string PaymentStatus { get; init; } = string.Empty;

    public string OrderStatus { get; init; } = string.Empty;
}
