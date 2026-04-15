namespace mobile.Models;

public class CartSummaryItemViewModel
{
    public required Product Product { get; init; }

    public required int CartItemId { get; init; }

    public required int Quantity { get; init; }

    public required decimal UnitPrice { get; init; }

    public required decimal LineTotal { get; init; }

    public required string ImageUrl { get; init; }
}
