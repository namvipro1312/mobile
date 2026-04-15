namespace mobile.Models;

public class ShopPageViewModel
{
    public IReadOnlyList<Product> Products { get; init; } = [];

    public IReadOnlyList<ShopFilterItemViewModel> Categories { get; init; } = [];

    public IReadOnlyList<ShopFilterItemViewModel> Brands { get; init; } = [];

    public decimal? MinPrice { get; init; }

    public decimal? MaxPrice { get; init; }

    public decimal? SelectedMinPrice { get; init; }

    public decimal? SelectedMaxPrice { get; init; }

    public string SortBy { get; init; } = "newest";

    public string? Keyword { get; init; }
}
