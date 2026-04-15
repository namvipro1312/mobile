namespace mobile.Models;

public class ProductPageViewModel
{
    public required Product Product { get; init; }

    public IReadOnlyList<string> ImageUrls { get; init; } = [];

    public decimal FinalPrice { get; init; }

    public decimal? OriginalPrice { get; init; }

    public decimal DiscountPercent { get; init; }

    public bool InStock { get; init; }

    public double AverageRating { get; init; }

    public int ReviewCount { get; init; }

    public IReadOnlyList<ProductSpecItemViewModel> OverviewItems { get; init; } = [];

    public IReadOnlyList<ProductSpecItemViewModel> SpecificationItems { get; init; } = [];

    public IReadOnlyList<ProductVariant> Variants { get; init; } = [];

    public IReadOnlyList<Review> Reviews { get; init; } = [];

    public IReadOnlyList<Product> RelatedProducts { get; init; } = [];
}
