namespace mobile.Models;

public class WishlistPageViewModel
{
    public IReadOnlyList<Product> Products { get; init; } = [];

    public bool IsLoggedIn { get; init; }
}
