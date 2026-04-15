namespace mobile.Models;

public class CartPageViewModel
{
    public IReadOnlyList<CartSummaryItemViewModel> Items { get; init; } = [];

    public decimal Subtotal { get; init; }

    public bool IsLoggedIn { get; init; }
}
