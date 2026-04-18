using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using mobile.Models;

namespace mobile.Controllers;

public sealed class AdminController : BaseStoreController
{
    public AdminController(MobileContext context, IConfiguration configuration)
        : base(context, configuration)
    {
    }

    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập tài khoản admin để truy cập khu quản trị.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Index), "Admin") });
        }

        var adminUser = await _context.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(item => item.UserId == userId.Value);

        if (adminUser is null)
        {
            HttpContext.Session.Remove(SessionUserIdKey);
            TempData["ErrorMessage"] = "Phiên đăng nhập không còn hợp lệ. Vui lòng đăng nhập lại.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Index), "Admin") });
        }

        if (!string.Equals(adminUser.Role, "Admin", StringComparison.OrdinalIgnoreCase))
        {
            TempData["ErrorMessage"] = "Tài khoản hiện tại không có quyền truy cập trang quản trị.";
            return RedirectToAction("Index", "Home");
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
                string.IsNullOrWhiteSpace(item.Status) ||
                (!string.Equals(item.Status, "Completed", StringComparison.OrdinalIgnoreCase) &&
                 !string.Equals(item.Status, "Cancelled", StringComparison.OrdinalIgnoreCase)));

        var productsActive = await _context.Products
            .AsNoTracking()
            .CountAsync(item => item.IsActive != false);

        var customersTotal = await _context.Users
            .AsNoTracking()
            .CountAsync(item => !string.Equals(item.Role, "Admin", StringComparison.OrdinalIgnoreCase));

        var newCustomersThisMonth = await _context.Users
            .AsNoTracking()
            .CountAsync(item =>
                !string.Equals(item.Role, "Admin", StringComparison.OrdinalIgnoreCase) &&
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
                Status = string.IsNullOrWhiteSpace(item.Status) ? "Pending" : item.Status!,
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
            AdminUser = adminUser,
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

    private async Task<List<AdminBreakdownItemViewModel>> BuildOrderStatusItemsAsync(int ordersTotal)
    {
        var rawItems = await _context.Orders
            .AsNoTracking()
            .GroupBy(item => string.IsNullOrWhiteSpace(item.Status) ? "Pending" : item.Status!)
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
