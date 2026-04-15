using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using mobile.Models;

namespace mobile.Controllers;

public class ShopController : BaseStoreController
{
    public ShopController(MobileContext context, IConfiguration configuration)
        : base(context, configuration)
    {
    }

    public async Task<IActionResult> Shop(
        [FromQuery(Name = "category")] string[]? category,
        [FromQuery(Name = "brand")] string[]? brand,
        decimal? minPrice,
        decimal? maxPrice,
        string? sortBy,
        string? keyword)
    {
        var selectedCategories = NormalizeSelections(category);
        var selectedBrands = NormalizeSelections(brand);
        var normalizedKeyword = string.IsNullOrWhiteSpace(keyword) ? null : keyword.Trim();
        var selectedSort = string.IsNullOrWhiteSpace(sortBy) ? "newest" : sortBy.Trim().ToLowerInvariant();

        ViewData["CurrentCategoryName"] = selectedCategories.Count == 1
            ? selectedCategories.First()
            : null;

        var allProducts = await _context.Products
            .AsNoTracking()
            .Include(product => product.Category)
            .Where(product => product.IsActive != false)
            .ToListAsync();

        var query = _context.Products
            .AsNoTracking()
            .Include(product => product.Category)
            .Include(product => product.ProductImages)
            .Where(product => product.IsActive != false);

        if (selectedCategories.Count > 0)
        {
            query = query.Where(product =>
                product.Category != null &&
                selectedCategories.Contains(product.Category.CategoryName));
        }

        if (selectedBrands.Count > 0)
        {
            query = query.Where(product =>
                product.Brand != null &&
                selectedBrands.Contains(product.Brand));
        }

        if (!string.IsNullOrWhiteSpace(normalizedKeyword))
        {
            query = query.Where(product =>
                product.Name.Contains(normalizedKeyword) ||
                (product.Brand != null && product.Brand.Contains(normalizedKeyword)) ||
                (product.Category != null && product.Category.CategoryName.Contains(normalizedKeyword)) ||
                (product.Description != null && product.Description.Contains(normalizedKeyword)));
        }

        if (minPrice.HasValue)
        {
            query = query.Where(product =>
                ((product.Discount ?? 0m) > 0m
                    ? product.Price * (1m - ((product.Discount ?? 0m) / 100m))
                    : product.Price) >= minPrice.Value);
        }

        if (maxPrice.HasValue)
        {
            query = query.Where(product =>
                ((product.Discount ?? 0m) > 0m
                    ? product.Price * (1m - ((product.Discount ?? 0m) / 100m))
                    : product.Price) <= maxPrice.Value);
        }

        query = selectedSort switch
        {
            "price-asc" => query
                .OrderBy(product => (product.Discount ?? 0m) > 0m
                    ? product.Price * (1m - ((product.Discount ?? 0m) / 100m))
                    : product.Price)
                .ThenBy(product => product.Name),
            "price-desc" => query
                .OrderByDescending(product => (product.Discount ?? 0m) > 0m
                    ? product.Price * (1m - ((product.Discount ?? 0m) / 100m))
                    : product.Price)
                .ThenBy(product => product.Name),
            "name-asc" => query
                .OrderBy(product => product.Name)
                .ThenByDescending(product => product.CreatedAt ?? DateTime.MinValue),
            _ => query
                .OrderByDescending(product => product.CreatedAt ?? DateTime.MinValue)
                .ThenByDescending(product => product.ProductId)
        };

        var products = await query.ToListAsync();

        var categories = allProducts
            .Where(product => product.Category is not null)
            .GroupBy(product => product.Category!.CategoryName)
            .Select(group => new ShopFilterItemViewModel
            {
                Name = group.Key,
                Count = group.Count(),
                IsSelected = selectedCategories.Contains(group.Key)
            })
            .OrderByDescending(item => item.Count)
            .ThenBy(item => item.Name)
            .ToList();

        var brands = allProducts
            .Where(product => !string.IsNullOrWhiteSpace(product.Brand))
            .GroupBy(product => product.Brand!)
            .Select(group => new ShopFilterItemViewModel
            {
                Name = group.Key,
                Count = group.Count(),
                IsSelected = selectedBrands.Contains(group.Key)
            })
            .OrderByDescending(item => item.Count)
            .ThenBy(item => item.Name)
            .ToList();

        var viewModel = new ShopPageViewModel
        {
            Products = products,
            Categories = categories,
            Brands = brands,
            MinPrice = allProducts.Count == 0 ? null : allProducts.Min(CalculateFinalPrice),
            MaxPrice = allProducts.Count == 0 ? null : allProducts.Max(CalculateFinalPrice),
            SelectedMinPrice = minPrice,
            SelectedMaxPrice = maxPrice,
            SortBy = selectedSort,
            Keyword = normalizedKeyword
        };

        return View("~/Views/Home/Shop.cshtml", viewModel);
    }

    public async Task<IActionResult> Product(int id)
    {
        if (id <= 0)
        {
            id = await _context.Products
                .AsNoTracking()
                .Where(product => product.IsActive != false)
                .OrderByDescending(product => product.CreatedAt ?? DateTime.MinValue)
                .ThenByDescending(product => product.ProductId)
                .Select(product => product.ProductId)
                .FirstOrDefaultAsync();

            if (id <= 0)
            {
                return RedirectToAction(nameof(Shop));
            }
        }

        var product = await _context.Products
            .AsNoTracking()
            .Include(item => item.Category)
            .Include(item => item.ProductDetail)
            .Include(item => item.ProductImages)
            .Include(item => item.ProductVariants)
            .Include(item => item.Reviews)
                .ThenInclude(review => review.User)
            .FirstOrDefaultAsync(item => item.ProductId == id && item.IsActive != false);

        if (product is null)
        {
            return NotFound();
        }

        var relatedQuery = _context.Products
            .AsNoTracking()
            .Include(item => item.Category)
            .Include(item => item.ProductImages)
            .Where(item => item.IsActive != false && item.ProductId != product.ProductId);

        if (product.CategoryId.HasValue)
        {
            relatedQuery = relatedQuery.Where(item => item.CategoryId == product.CategoryId);
        }
        else if (!string.IsNullOrWhiteSpace(product.Brand))
        {
            relatedQuery = relatedQuery.Where(item => item.Brand == product.Brand);
        }

        var relatedProducts = await relatedQuery
            .OrderByDescending(item => item.CreatedAt ?? DateTime.MinValue)
            .ThenByDescending(item => item.ProductId)
            .Take(6)
            .ToListAsync();

        ViewData["CurrentCategoryName"] = product.Category?.CategoryName;

        var ratingValues = product.Reviews
            .Where(review => review.Rating.HasValue)
            .Select(review => review.Rating!.Value)
            .ToList();

        var viewModel = new ProductPageViewModel
        {
            Product = product,
            ImageUrls = BuildImageUrls(product),
            FinalPrice = CalculateFinalPrice(product),
            OriginalPrice = product.Discount.HasValue && product.Discount.Value > 0 ? product.Price : null,
            DiscountPercent = product.Discount ?? 0m,
            InStock = (product.Stock ?? 0) > 0,
            AverageRating = ratingValues.Count == 0 ? 0 : ratingValues.Average(),
            ReviewCount = product.Reviews.Count,
            OverviewItems = BuildOverviewItems(product),
            SpecificationItems = BuildSpecificationItems(product),
            Variants = product.ProductVariants
                .OrderByDescending(variant => variant.Stock ?? 0)
                .ThenBy(variant => variant.VariantName)
                .ToList(),
            Reviews = product.Reviews
                .OrderByDescending(review => review.CreatedAt ?? DateTime.MinValue)
                .ToList(),
            RelatedProducts = relatedProducts
        };

        return View("~/Views/Home/Product.cshtml", viewModel);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> AddToWishlist(int productId, string? returnUrl = null)
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập để thêm vào yêu thích.";
            return RedirectToAction("Login", "Account", new { returnUrl = returnUrl ?? Url.Action(nameof(Product), new { id = productId }) });
        }

        var product = await _context.Products
            .AsNoTracking()
            .FirstOrDefaultAsync(item => item.ProductId == productId && item.IsActive != false);

        if (product is null)
        {
            TempData["ErrorMessage"] = "Không tìm thấy sản phẩm yêu thích.";
            return RedirectToSafeLocal(returnUrl, nameof(Shop), "Shop");
        }

        var existed = await _context.Wishlists
            .AnyAsync(item => item.UserId == userId.Value && item.ProductId == productId);

        if (!existed)
        {
            _context.Wishlists.Add(new Wishlist
            {
                UserId = userId.Value,
                ProductId = productId
            });

            await _context.SaveChangesAsync();
        }

        TempData["SuccessMessage"] = $"Đã thêm \"{product.Name}\" vào yêu thích.";
        return RedirectToSafeLocal(returnUrl, nameof(Wishlist), "Shop");
    }

    [HttpGet]
    public async Task<IActionResult> Wishlist()
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập để xem danh sách yêu thích.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Wishlist), "Shop") });
        }

        var products = await _context.Wishlists
            .AsNoTracking()
            .Include(item => item.Product!)
                .ThenInclude(product => product.Category)
            .Include(item => item.Product!)
                .ThenInclude(product => product.ProductImages)
            .Where(item => item.UserId == userId.Value)
            .Select(item => item.Product!)
            .Where(product => product.IsActive != false)
            .OrderByDescending(product => product.CreatedAt ?? DateTime.MinValue)
            .ToListAsync();

        return View("~/Views/Home/Wishlist.cshtml", new WishlistPageViewModel
        {
            Products = products,
            IsLoggedIn = true
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> RemoveFromWishlist(int productId, string? returnUrl = null)
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập để thao tác yêu thích.";
            return RedirectToAction("Login", "Account", new { returnUrl = returnUrl ?? Url.Action(nameof(Wishlist), "Shop") });
        }

        var item = await _context.Wishlists
            .FirstOrDefaultAsync(wishlist => wishlist.UserId == userId.Value && wishlist.ProductId == productId);

        if (item is not null)
        {
            _context.Wishlists.Remove(item);
            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Đã xóa sản phẩm khỏi yêu thích.";
        }

        return RedirectToSafeLocal(returnUrl, nameof(Wishlist), "Shop");
    }

    [HttpGet]
    public async Task<IActionResult> Compare()
    {
        var compareIds = GetCompareProductIds();
        var products = await _context.Products
            .AsNoTracking()
            .Include(product => product.Category)
            .Include(product => product.ProductImages)
            .Include(product => product.ProductDetail)
            .Include(product => product.Reviews)
            .Where(product => compareIds.Contains(product.ProductId) && product.IsActive != false)
            .ToListAsync();

        products = products
            .OrderBy(product => compareIds.IndexOf(product.ProductId))
            .ToList();

        return View("~/Views/Home/Compare.cshtml", new ComparePageViewModel
        {
            Products = products
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult AddToCompare(int productId, string? returnUrl = null)
    {
        var compareIds = GetCompareProductIds();
        if (!compareIds.Contains(productId))
        {
            compareIds.Insert(0, productId);
            if (compareIds.Count > 4)
            {
                compareIds = compareIds.Take(4).ToList();
            }

            SaveCompareProductIds(compareIds);
        }

        TempData["SuccessMessage"] = "Đã thêm sản phẩm vào danh sách so sánh.";
        return RedirectToSafeLocal(returnUrl, nameof(Compare), "Shop");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult RemoveFromCompare(int productId)
    {
        var compareIds = GetCompareProductIds();
        compareIds.Remove(productId);
        SaveCompareProductIds(compareIds);
        TempData["SuccessMessage"] = "Đã xóa sản phẩm khỏi so sánh.";
        return RedirectToAction(nameof(Compare));
    }
}
