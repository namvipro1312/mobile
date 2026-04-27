using Microsoft.AspNetCore.Http;

namespace mobile.Models;

public sealed class AdminProductListViewModel
{
    public IReadOnlyList<Product> Products { get; init; } = [];

    public IReadOnlyList<Category> Categories { get; init; } = [];

    public string? Keyword { get; init; }

    public int? CategoryId { get; init; }
}

public sealed class AdminProductFormViewModel
{
    public int? ProductId { get; set; }

    public string Name { get; set; } = string.Empty;

    public decimal Price { get; set; }

    public decimal? Discount { get; set; }

    public int? Stock { get; set; }

    public string? Description { get; set; }

    public int? CategoryId { get; set; }

    public string? NewCategoryName { get; set; }

    public string? Brand { get; set; }

    public string? Thumbnail { get; set; }

    public bool IsActive { get; set; } = true;

    public List<IFormFile> UploadedImages { get; set; } = [];

    public IReadOnlyList<Category> Categories { get; set; } = [];

    public IReadOnlyList<ProductImage> ExistingImages { get; set; } = [];
}
