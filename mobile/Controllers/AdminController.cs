using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using mobile.Models;

namespace mobile.Controllers;

public sealed class AdminController : BaseStoreController
{
    private const long MaxProductImageBytes = 8 * 1024 * 1024;
    private static readonly HashSet<string> AllowedProductImageExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".jpg",
        ".jpeg",
        ".png",
        ".webp",
        ".gif"
    };

    private readonly IWebHostEnvironment _environment;

    public AdminController(
        MobileContext context,
        IConfiguration configuration,
        IWebHostEnvironment environment)
        : base(context, configuration)
    {
        _environment = environment;
    }

    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var guard = await RequireAdminAsync();
        if (guard.Result is not null)
        {
            return guard.Result;
        }

        var now = DateTime.Now;
        var monthStart = new DateTime(now.Year, now.Month, 1);

        var grossRevenue = await _context.Orders
            .AsNoTracking()
            .SumAsync(item => item.TotalAmount ?? 0m);

        var revenueThisMonth = await _context.Orders
            .AsNoTracking()
            .Where(item => item.CreatedAt.HasValue && item.CreatedAt.Value >= monthStart)
            .SumAsync(item => item.TotalAmount ?? 0m);

        var ordersTotal = await _context.Orders.AsNoTracking().CountAsync();

        var ordersThisMonth = await _context.Orders
            .AsNoTracking()
            .CountAsync(item => item.CreatedAt.HasValue && item.CreatedAt.Value >= monthStart);

        var pendingOrders = await _context.Orders
            .AsNoTracking()
            .CountAsync(item =>
                item.Status == null ||
                item.Status.Trim() == string.Empty ||
                (item.Status.ToUpper() != "COMPLETED" &&
                 item.Status.ToUpper() != "CANCELLED"));

        var productsActive = await _context.Products
            .AsNoTracking()
            .CountAsync(item => item.IsActive != false);

        var customersTotal = await _context.Users
            .AsNoTracking()
            .CountAsync(item => item.Role == null || item.Role.ToUpper() != "ADMIN");

        var newCustomersThisMonth = await _context.Users
            .AsNoTracking()
            .CountAsync(item =>
                (item.Role == null || item.Role.ToUpper() != "ADMIN") &&
                item.CreatedAt.HasValue &&
                item.CreatedAt.Value >= monthStart);

        var contactMessagesCount = await _context.Contacts
            .AsNoTracking()
            .CountAsync();

        var lowStockProducts = await _context.Products
            .AsNoTracking()
            .Include(item => item.Category)
            .Where(item => item.IsActive != false && (item.Stock ?? 0) <= 5)
            .OrderBy(item => item.Stock ?? 0)
            .ThenBy(item => item.Name)
            .Take(6)
            .Select(item => new AdminInventoryItemViewModel
            {
                ProductId = item.ProductId,
                Name = item.Name,
                Brand = item.Brand ?? "Đang cập nhật",
                CategoryName = item.Category != null ? item.Category.CategoryName : "Chưa phân loại",
                Stock = item.Stock ?? 0,
                FinalPrice = item.Discount.HasValue && item.Discount.Value > 0m
                    ? item.Price * (1m - (item.Discount.Value / 100m))
                    : item.Price
            })
            .ToListAsync();

        var topProducts = await _context.OrderDetails
            .AsNoTracking()
            .Where(item => item.Product != null)
            .Select(item => new
            {
                item.ProductId,
                ProductName = item.Product!.Name,
                Brand = item.Product.Brand,
                Quantity = item.Quantity ?? 0,
                Revenue = (item.Price ?? 0m) * (item.Quantity ?? 0)
            })
            .ToListAsync();

        var topProductItems = topProducts
            .GroupBy(item => new { item.ProductId, item.ProductName, item.Brand })
            .Select(group => new AdminTopProductItemViewModel
            {
                ProductId = group.Key.ProductId ?? 0,
                Name = group.Key.ProductName,
                Brand = string.IsNullOrWhiteSpace(group.Key.Brand) ? "Đang cập nhật" : group.Key.Brand!,
                UnitsSold = group.Sum(item => item.Quantity),
                Revenue = group.Sum(item => item.Revenue)
            })
            .OrderByDescending(item => item.UnitsSold)
            .ThenByDescending(item => item.Revenue)
            .Take(6)
            .ToList();

        var recentOrders = await _context.Orders
            .AsNoTracking()
            .Include(item => item.User)
            .Include(item => item.Payments)
            .OrderByDescending(item => item.CreatedAt ?? DateTime.MinValue)
            .Take(8)
            .Select(item => new AdminRecentOrderItemViewModel
            {
                OrderId = item.OrderId,
                CustomerName = item.User != null
                    ? (item.User.FullName ?? item.User.Username ?? "Khách vãng lai")
                    : "Khách vãng lai",
                Status = item.Status == null || item.Status.Trim() == string.Empty ? "Pending" : item.Status,
                PaymentMethod = item.Payments
                    .OrderByDescending(payment => payment.PaymentId)
                    .Select(payment => payment.PaymentMethod)
                    .FirstOrDefault() ?? "Chưa cập nhật",
                TotalAmount = item.TotalAmount ?? 0m,
                CreatedAt = item.CreatedAt
            })
            .ToListAsync();

        var orderStatusItems = await BuildOrderStatusItemsAsync(ordersTotal);
        var paymentMethodItems = await BuildPaymentMethodItemsAsync();

        return View("~/Views/Admin/Index.cshtml", new AdminDashboardViewModel
        {
            AdminUser = guard.AdminUser!,
            GrossRevenue = grossRevenue,
            RevenueThisMonth = revenueThisMonth,
            AverageOrderValue = ordersTotal > 0 ? decimal.Round(grossRevenue / ordersTotal, 0, MidpointRounding.AwayFromZero) : 0m,
            OrdersTotal = ordersTotal,
            OrdersThisMonth = ordersThisMonth,
            PendingOrders = pendingOrders,
            ProductsActive = productsActive,
            LowStockProductsCount = lowStockProducts.Count,
            CustomersTotal = customersTotal,
            NewCustomersThisMonth = newCustomersThisMonth,
            ContactMessagesCount = contactMessagesCount,
            RecentOrders = recentOrders,
            LowStockProducts = lowStockProducts,
            TopProducts = topProductItems,
            OrderStatusItems = orderStatusItems,
            PaymentMethodItems = paymentMethodItems
        });
    }

    [HttpGet]
    public async Task<IActionResult> Products(string? keyword, int? categoryId)
    {
        var guard = await RequireAdminAsync();
        if (guard.Result is not null)
        {
            return guard.Result;
        }

        var normalizedKeyword = string.IsNullOrWhiteSpace(keyword) ? null : keyword.Trim();
        var query = _context.Products
            .AsNoTracking()
            .Include(item => item.Category)
            .Include(item => item.ProductImages)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(normalizedKeyword))
        {
            query = query.Where(item =>
                item.Name.Contains(normalizedKeyword) ||
                (item.Brand != null && item.Brand.Contains(normalizedKeyword)));
        }

        if (categoryId.HasValue)
        {
            query = query.Where(item => item.CategoryId == categoryId.Value);
        }

        var viewModel = new AdminProductListViewModel
        {
            Products = await query
                .OrderByDescending(item => item.CreatedAt ?? DateTime.MinValue)
                .ThenByDescending(item => item.ProductId)
                .ToListAsync(),
            Categories = await LoadCategoriesAsync(),
            Keyword = normalizedKeyword,
            CategoryId = categoryId
        };

        return View("~/Views/Admin/Products.cshtml", viewModel);
    }

    [HttpGet]
    public async Task<IActionResult> CreateProduct()
    {
        var guard = await RequireAdminAsync();
        if (guard.Result is not null)
        {
            return guard.Result;
        }

        return View("~/Views/Admin/ProductForm.cshtml", await BuildProductFormModelAsync(new AdminProductFormViewModel()));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CreateProduct(AdminProductFormViewModel model)
    {
        var guard = await RequireAdminAsync();
        if (guard.Result is not null)
        {
            return guard.Result;
        }

        ValidateProductForm(model);
        ValidateUploadedImages(model.UploadedImages);

        if (!ModelState.IsValid)
        {
            return View("~/Views/Admin/ProductForm.cshtml", await BuildProductFormModelAsync(model));
        }

        var categoryId = await ResolveCategoryIdAsync(model);
        var product = new Product
        {
            Name = model.Name.Trim(),
            Price = model.Price,
            Discount = model.Discount ?? 0m,
            Stock = model.Stock ?? 0,
            Description = string.IsNullOrWhiteSpace(model.Description) ? null : model.Description.Trim(),
            CategoryId = categoryId,
            Brand = string.IsNullOrWhiteSpace(model.Brand) ? null : model.Brand.Trim(),
            Thumbnail = string.IsNullOrWhiteSpace(model.Thumbnail) ? null : model.Thumbnail.Trim(),
            IsActive = model.IsActive,
            CreatedAt = DateTime.Now
        };

        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        await SaveUploadedImagesAsync(product.ProductId, model.UploadedImages);
        await NormalizeMainProductImageAsync(product.ProductId);

        TempData["SuccessMessage"] = "Đã tạo sản phẩm.";
        return RedirectToAction(nameof(EditProduct), new { id = product.ProductId });
    }

    [HttpGet]
    public async Task<IActionResult> EditProduct(int id)
    {
        var guard = await RequireAdminAsync();
        if (guard.Result is not null)
        {
            return guard.Result;
        }

        var product = await _context.Products
            .AsNoTracking()
            .Include(item => item.ProductImages)
            .FirstOrDefaultAsync(item => item.ProductId == id);

        if (product is null)
        {
            return NotFound();
        }

        var model = new AdminProductFormViewModel
        {
            ProductId = product.ProductId,
            Name = product.Name,
            Price = product.Price,
            Discount = product.Discount,
            Stock = product.Stock,
            Description = product.Description,
            CategoryId = product.CategoryId,
            Brand = product.Brand,
            Thumbnail = product.Thumbnail,
            IsActive = product.IsActive != false,
            ExistingImages = product.ProductImages
                .OrderByDescending(image => image.IsMain ?? false)
                .ThenBy(image => image.ImageId)
                .ToList()
        };

        return View("~/Views/Admin/ProductForm.cshtml", await BuildProductFormModelAsync(model));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> EditProduct(int id, AdminProductFormViewModel model)
    {
        var guard = await RequireAdminAsync();
        if (guard.Result is not null)
        {
            return guard.Result;
        }

        var product = await _context.Products
            .Include(item => item.ProductImages)
            .FirstOrDefaultAsync(item => item.ProductId == id);

        if (product is null)
        {
            return NotFound();
        }

        model.ProductId = id;
        ValidateProductForm(model);
        ValidateUploadedImages(model.UploadedImages);

        if (!ModelState.IsValid)
        {
            model.ExistingImages = product.ProductImages
                .OrderByDescending(image => image.IsMain ?? false)
                .ThenBy(image => image.ImageId)
                .ToList();
            return View("~/Views/Admin/ProductForm.cshtml", await BuildProductFormModelAsync(model));
        }

        var categoryId = await ResolveCategoryIdAsync(model);
        product.Name = model.Name.Trim();
        product.Price = model.Price;
        product.Discount = model.Discount ?? 0m;
        product.Stock = model.Stock ?? 0;
        product.Description = string.IsNullOrWhiteSpace(model.Description) ? null : model.Description.Trim();
        product.CategoryId = categoryId;
        product.Brand = string.IsNullOrWhiteSpace(model.Brand) ? null : model.Brand.Trim();
        product.Thumbnail = string.IsNullOrWhiteSpace(model.Thumbnail) ? null : model.Thumbnail.Trim();
        product.IsActive = model.IsActive;

        await SaveUploadedImagesAsync(product.ProductId, model.UploadedImages);
        await _context.SaveChangesAsync();
        await NormalizeMainProductImageAsync(product.ProductId);

        TempData["SuccessMessage"] = "Đã cập nhật sản phẩm.";
        return RedirectToAction(nameof(EditProduct), new { id = product.ProductId });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> SetMainProductImage(int imageId)
    {
        var guard = await RequireAdminAsync();
        if (guard.Result is not null)
        {
            return guard.Result;
        }

        var image = await _context.ProductImages.FirstOrDefaultAsync(item => item.ImageId == imageId);
        if (image is null || !image.ProductId.HasValue)
        {
            return NotFound();
        }

        var siblingImages = await _context.ProductImages
            .Where(item => item.ProductId == image.ProductId)
            .ToListAsync();

        foreach (var sibling in siblingImages)
        {
            sibling.IsMain = sibling.ImageId == imageId;
        }

        var product = await _context.Products.FirstOrDefaultAsync(item => item.ProductId == image.ProductId.Value);
        if (product is not null)
        {
            product.Thumbnail = image.ImageUrl;
        }

        await _context.SaveChangesAsync();
        TempData["SuccessMessage"] = "Đã đặt ảnh chính.";
        return RedirectToAction(nameof(EditProduct), new { id = image.ProductId });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteProductImage(int imageId)
    {
        var guard = await RequireAdminAsync();
        if (guard.Result is not null)
        {
            return guard.Result;
        }

        var image = await _context.ProductImages.FirstOrDefaultAsync(item => item.ImageId == imageId);
        if (image is null || !image.ProductId.HasValue)
        {
            return NotFound();
        }

        var productId = image.ProductId.Value;
        TryDeleteUploadedImageFile(image.ImageUrl);
        _context.ProductImages.Remove(image);
        await _context.SaveChangesAsync();
        await NormalizeMainProductImageAsync(productId);

        TempData["SuccessMessage"] = "Đã xóa ảnh sản phẩm.";
        return RedirectToAction(nameof(EditProduct), new { id = productId });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ToggleProductStatus(int id)
    {
        var guard = await RequireAdminAsync();
        if (guard.Result is not null)
        {
            return guard.Result;
        }

        var product = await _context.Products.FirstOrDefaultAsync(item => item.ProductId == id);
        if (product is null)
        {
            return NotFound();
        }

        product.IsActive = product.IsActive == false;
        await _context.SaveChangesAsync();

        TempData["SuccessMessage"] = product.IsActive == false
            ? "Đã ẩn sản phẩm khỏi cửa hàng."
            : "Đã bật lại sản phẩm trên cửa hàng.";

        return RedirectToAction(nameof(Products));
    }

    private async Task<(User? AdminUser, IActionResult? Result)> RequireAdminAsync()
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập tài khoản admin để truy cập khu quản trị.";
            return (null, RedirectToAction("Login", "Account", new { returnUrl = HttpContext.Request.Path + HttpContext.Request.QueryString }));
        }

        var adminUser = await _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(item => item.UserId == userId.Value);

        if (adminUser is null)
        {
            HttpContext.Session.Remove(SessionUserIdKey);
            TempData["ErrorMessage"] = "Phiên đăng nhập không còn hợp lệ. Vui lòng đăng nhập lại.";
            return (null, RedirectToAction("Login", "Account", new { returnUrl = HttpContext.Request.Path + HttpContext.Request.QueryString }));
        }

        if (!string.Equals(adminUser.Role, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            TempData["ErrorMessage"] = "Tài khoản hiện tại không có quyền truy cập trang quản trị.";
            return (null, RedirectToAction("Index", "Home"));
        }

        return (adminUser, null);
    }

    private async Task<AdminProductFormViewModel> BuildProductFormModelAsync(AdminProductFormViewModel model)
    {
        model.Categories = await LoadCategoriesAsync();
        return model;
    }

    private async Task<List<Category>> LoadCategoriesAsync()
    {
        return await _context.Categories
            .AsNoTracking()
            .OrderBy(item => item.CategoryName)
            .ToListAsync();
    }

    private void ValidateProductForm(AdminProductFormViewModel model)
    {
        if (string.IsNullOrWhiteSpace(model.Name))
        {
            ModelState.AddModelError(nameof(model.Name), "Vui lòng nhập tên sản phẩm.");
        }

        if (model.Price <= 0)
        {
            ModelState.AddModelError(nameof(model.Price), "Giá sản phẩm phải lớn hơn 0.");
        }

        if (model.Discount is < 0 or > 100)
        {
            ModelState.AddModelError(nameof(model.Discount), "Giảm giá phải từ 0 đến 100%.");
        }

        if (model.Stock is < 0)
        {
            ModelState.AddModelError(nameof(model.Stock), "Tồn kho không được âm.");
        }
    }

    private void ValidateUploadedImages(IEnumerable<IFormFile>? files)
    {
        foreach (var file in files ?? [])
        {
            if (file.Length <= 0)
            {
                continue;
            }

            var extension = Path.GetExtension(file.FileName);
            if (!AllowedProductImageExtensions.Contains(extension))
            {
                ModelState.AddModelError(nameof(AdminProductFormViewModel.UploadedImages), "Chỉ hỗ trợ ảnh JPG, PNG, WEBP hoặc GIF.");
            }

            if (file.Length > MaxProductImageBytes)
            {
                ModelState.AddModelError(nameof(AdminProductFormViewModel.UploadedImages), "Mỗi ảnh tối đa 8MB.");
            }
        }
    }

    private async Task<int?> ResolveCategoryIdAsync(AdminProductFormViewModel model)
    {
        var newCategoryName = model.NewCategoryName?.Trim();
        if (string.IsNullOrWhiteSpace(newCategoryName))
        {
            return model.CategoryId;
        }

        var existingCategory = await _context.Categories
            .FirstOrDefaultAsync(item => item.CategoryName == newCategoryName);

        if (existingCategory is not null)
        {
            return existingCategory.CategoryId;
        }

        var category = new Category
        {
            CategoryName = newCategoryName,
            CreatedAt = DateTime.Now
        };

        _context.Categories.Add(category);
        await _context.SaveChangesAsync();
        return category.CategoryId;
    }

    private async Task SaveUploadedImagesAsync(int productId, IEnumerable<IFormFile>? files)
    {
        var imageFiles = (files ?? [])
            .Where(file => file.Length > 0)
            .ToList();

        if (imageFiles.Count == 0)
        {
            return;
        }

        var uploadRoot = Path.Combine(_environment.WebRootPath, "uploads", "products");
        Directory.CreateDirectory(uploadRoot);

        var productHasMainImage = await _context.ProductImages
            .AnyAsync(item => item.ProductId == productId && item.IsMain == true);

        foreach (var file in imageFiles)
        {
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var fileName = $"{productId}-{Guid.NewGuid():N}{extension}";
            var fullPath = Path.Combine(uploadRoot, fileName);

            await using var stream = System.IO.File.Create(fullPath);
            await file.CopyToAsync(stream);

            _context.ProductImages.Add(new ProductImage
            {
                ProductId = productId,
                ImageUrl = $"~/uploads/products/{fileName}",
                IsMain = !productHasMainImage
            });

            productHasMainImage = true;
        }

        await _context.SaveChangesAsync();
    }

    private async Task NormalizeMainProductImageAsync(int productId)
    {
        var product = await _context.Products
            .Include(item => item.ProductImages)
            .FirstOrDefaultAsync(item => item.ProductId == productId);

        if (product is null)
        {
            return;
        }

        var images = product.ProductImages
            .Where(item => !string.IsNullOrWhiteSpace(item.ImageUrl))
            .OrderByDescending(item => item.IsMain ?? false)
            .ThenBy(item => item.ImageId)
            .ToList();

        if (images.Count == 0)
        {
            await _context.SaveChangesAsync();
            return;
        }

        var mainImage = images.First();
        foreach (var image in images)
        {
            image.IsMain = image.ImageId == mainImage.ImageId;
        }

        product.Thumbnail = mainImage.ImageUrl;
        await _context.SaveChangesAsync();
    }

    private void TryDeleteUploadedImageFile(string? imageUrl)
    {
        if (string.IsNullOrWhiteSpace(imageUrl) ||
            !imageUrl.StartsWith("~/uploads/products/", StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        var uploadRoot = Path.GetFullPath(Path.Combine(_environment.WebRootPath, "uploads", "products"));
        var relativePath = imageUrl[2..].Replace('/', Path.DirectorySeparatorChar);
        var fullPath = Path.GetFullPath(Path.Combine(_environment.WebRootPath, relativePath));

        if (!fullPath.StartsWith(uploadRoot, StringComparison.OrdinalIgnoreCase) ||
            !System.IO.File.Exists(fullPath))
        {
            return;
        }

        System.IO.File.Delete(fullPath);
    }

    private async Task<List<AdminBreakdownItemViewModel>> BuildOrderStatusItemsAsync(int ordersTotal)
    {
        var rawItems = await _context.Orders
            .AsNoTracking()
            .GroupBy(item => item.Status == null || item.Status.Trim() == string.Empty ? "Pending" : item.Status)
            .Select(group => new
            {
                Label = group.Key,
                Count = group.Count()
            })
            .OrderByDescending(group => group.Count)
            .ToListAsync();

        return rawItems
            .Select(item => new AdminBreakdownItemViewModel
            {
                Label = item.Label,
                Count = item.Count,
                Percentage = ordersTotal > 0
                    ? decimal.Round((decimal)item.Count * 100m / ordersTotal, 1, MidpointRounding.AwayFromZero)
                    : 0m
            })
            .ToList();
    }

    private async Task<List<AdminBreakdownItemViewModel>> BuildPaymentMethodItemsAsync()
    {
        var rawItems = await _context.Payments
            .AsNoTracking()
            .Select(item => item.PaymentMethod)
            .ToListAsync();

        var total = rawItems.Count;

        return rawItems
            .GroupBy(item => NormalizePaymentMethod(item))
            .Select(group => new AdminBreakdownItemViewModel
            {
                Label = group.Key,
                Count = group.Count(),
                Percentage = total > 0
                    ? decimal.Round((decimal)group.Count() * 100m / total, 1, MidpointRounding.AwayFromZero)
                    : 0m
            })
            .OrderByDescending(item => item.Count)
            .ToList();
    }
}
