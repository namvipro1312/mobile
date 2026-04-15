namespace mobile.Models;

public class MyAccountPageViewModel
{
    public required User User { get; init; }

    public IReadOnlyList<Order> RecentOrders { get; init; } = [];

    public int WishlistCount { get; init; }

    public int CartItemCount { get; init; }

    public decimal PendingAmount { get; init; }
}
