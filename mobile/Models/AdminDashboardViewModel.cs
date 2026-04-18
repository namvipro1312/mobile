namespace mobile.Models;

public sealed class AdminDashboardViewModel
{
    public User AdminUser { get; set; } = null!;

    public decimal GrossRevenue { get; set; }

    public decimal RevenueThisMonth { get; set; }

    public decimal AverageOrderValue { get; set; }

    public int OrdersTotal { get; set; }

    public int OrdersThisMonth { get; set; }

    public int PendingOrders { get; set; }

    public int ProductsActive { get; set; }

    public int LowStockProductsCount { get; set; }

    public int CustomersTotal { get; set; }

    public int NewCustomersThisMonth { get; set; }

    public int ContactMessagesCount { get; set; }

    public IReadOnlyList<AdminRecentOrderItemViewModel> RecentOrders { get; set; } = [];

    public IReadOnlyList<AdminInventoryItemViewModel> LowStockProducts { get; set; } = [];

    public IReadOnlyList<AdminTopProductItemViewModel> TopProducts { get; set; } = [];

    public IReadOnlyList<AdminBreakdownItemViewModel> OrderStatusItems { get; set; } = [];

    public IReadOnlyList<AdminBreakdownItemViewModel> PaymentMethodItems { get; set; } = [];
}

public sealed class AdminRecentOrderItemViewModel
{
    public int OrderId { get; set; }

    public string CustomerName { get; set; } = string.Empty;

    public string Status { get; set; } = string.Empty;

    public string PaymentMethod { get; set; } = string.Empty;

    public decimal TotalAmount { get; set; }

    public DateTime? CreatedAt { get; set; }
}

public sealed class AdminInventoryItemViewModel
{
    public int ProductId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string Brand { get; set; } = string.Empty;

    public string CategoryName { get; set; } = string.Empty;

    public int Stock { get; set; }

    public decimal FinalPrice { get; set; }
}

public sealed class AdminTopProductItemViewModel
{
    public int ProductId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string Brand { get; set; } = string.Empty;

    public int UnitsSold { get; set; }

    public decimal Revenue { get; set; }
}

public sealed class AdminBreakdownItemViewModel
{
    public string Label { get; set; } = string.Empty;

    public int Count { get; set; }

    public decimal Percentage { get; set; }
}
