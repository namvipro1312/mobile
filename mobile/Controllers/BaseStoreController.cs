using System.Globalization;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using mobile.Models;

namespace mobile.Controllers;

public abstract class BaseStoreController : Controller
{
    protected const string SessionUserIdKey = "CurrentUserId";
    protected const string SessionCompareKey = "CompareProductIds";
    protected const string PaymentMethodCod = "COD";
    protected const string PaymentMethodBankQr = "BANK_QR";
    protected const string PaymentMethodStore = "STORE";

    protected readonly MobileContext _context;
    protected readonly IConfiguration _configuration;

    protected BaseStoreController(MobileContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    protected int? GetCurrentUserId() => HttpContext.Session.GetInt32(SessionUserIdKey);

    protected async Task<Cart> GetOrCreateCartAsync(int userId)
    {
        var cart = await _context.Carts.FirstOrDefaultAsync(item => item.UserId == userId);
        if (cart is not null)
        {
            return cart;
        }

        cart = new Cart
        {
            UserId = userId,
            CreatedAt = DateTime.Now
        };

        _context.Carts.Add(cart);
        await _context.SaveChangesAsync();
        return cart;
    }

    protected async Task<List<CartSummaryItemViewModel>> BuildCartItemsAsync(int userId)
    {
        var cartItems = await _context.CartItems
            .AsNoTracking()
            .Include(item => item.Product!)
                .ThenInclude(product => product.Category)
            .Include(item => item.Product!)
                .ThenInclude(product => product.ProductImages)
            .Include(item => item.Cart)
            .Where(item => item.Cart!.UserId == userId && item.Product != null && item.Product.IsActive != false)
            .OrderByDescending(item => item.CartItemId)
            .ToListAsync();

        return cartItems
            .Select(item =>
            {
                var quantity = Math.Max(item.Quantity ?? 1, 1);
                var unitPrice = item.Price ?? CalculateFinalPrice(item.Product!);
                return new CartSummaryItemViewModel
                {
                    CartItemId = item.CartItemId,
                    Product = item.Product!,
                    Quantity = quantity,
                    UnitPrice = unitPrice,
                    LineTotal = unitPrice * quantity,
                    ImageUrl = BuildPrimaryImage(item.Product!)
                };
            })
            .ToList();
    }

    protected List<int> GetCompareProductIds()
    {
        var raw = HttpContext.Session.GetString(SessionCompareKey);
        if (string.IsNullOrWhiteSpace(raw))
        {
            return [];
        }

        try
        {
            return JsonSerializer.Deserialize<List<int>>(raw) ?? [];
        }
        catch
        {
            return [];
        }
    }

    protected void SaveCompareProductIds(List<int> productIds)
    {
        HttpContext.Session.SetString(SessionCompareKey, JsonSerializer.Serialize(productIds.Distinct().ToList()));
    }

    protected IActionResult RedirectToSafeLocal(string? returnUrl, string fallbackAction, string fallbackController)
    {
        if (!string.IsNullOrWhiteSpace(returnUrl) && Url.IsLocalUrl(returnUrl))
        {
            return Redirect(returnUrl);
        }

        return RedirectToAction(fallbackAction, fallbackController)!;
    }

    protected static string NormalizePaymentMethod(string? paymentMethod)
    {
        return paymentMethod?.Trim().ToUpperInvariant() switch
        {
            PaymentMethodBankQr => "Bank QR",
            "BANK" => "Bank QR",
            PaymentMethodStore => "Pay At Store",
            "PAYPAL" => "Online Payment",
            _ => "Cash on Delivery"
        };
    }

    protected static string BuildPaymentStatus(string paymentMethod)
    {
        return paymentMethod switch
        {
            "Bank QR" => "Awaiting Transfer",
            "Pay At Store" => "Awaiting Store Payment",
            _ => "Pending"
        };
    }

    protected static HashSet<string> NormalizeSelections(IEnumerable<string>? values)
    {
        return values?
            .Where(value => !string.IsNullOrWhiteSpace(value))
            .Select(value => value.Trim())
            .ToHashSet(StringComparer.OrdinalIgnoreCase)
            ?? new HashSet<string>(StringComparer.OrdinalIgnoreCase);
    }

    protected static decimal CalculateFinalPrice(Product product)
    {
        var discount = product.Discount ?? 0m;
        return discount > 0m
            ? product.Price * (1m - (discount / 100m))
            : product.Price;
    }

    protected static string BuildPrimaryImage(Product product)
    {
        return BuildImageUrls(product).FirstOrDefault() ?? "~/assets/img/product/product-1.jpg";
    }

    protected static IReadOnlyList<string> BuildImageUrls(Product product)
    {
        var imageUrls = product.ProductImages
            .Where(image => !string.IsNullOrWhiteSpace(image.ImageUrl))
            .OrderByDescending(image => image.IsMain ?? false)
            .Select(image => image.ImageUrl!.Trim())
            .ToList();

        if (!string.IsNullOrWhiteSpace(product.Thumbnail))
        {
            imageUrls.Insert(0, product.Thumbnail.Trim());
        }

        var distinctImages = imageUrls
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        if (distinctImages.Count == 0)
        {
            distinctImages.Add("~/assets/img/product/product-1.jpg");
        }

        return distinctImages;
    }

    protected static IReadOnlyList<ProductSpecItemViewModel> BuildOverviewItems(Product product)
    {
        var items = new List<ProductSpecItemViewModel>
        {
            new()
            {
                Label = "Danh muc",
                Value = product.Category?.CategoryName ?? "Dang cap nhat"
            },
            new()
            {
                Label = "Thuong hieu",
                Value = string.IsNullOrWhiteSpace(product.Brand) ? "Dang cap nhat" : product.Brand
            },
            new()
            {
                Label = "Tinh trang",
                Value = (product.Stock ?? 0) > 0 ? "Con hang" : "Tam het hang"
            },
            new()
            {
                Label = "Ton kho",
                Value = $"{Math.Max(product.Stock ?? 0, 0)} san pham"
            }
        };

        if (product.Discount.HasValue && product.Discount.Value > 0)
        {
            items.Add(new ProductSpecItemViewModel
            {
                Label = "Uu dai",
                Value = $"Giam {product.Discount.Value:0.#}%"
            });
        }

        if (product.CreatedAt.HasValue)
        {
            items.Add(new ProductSpecItemViewModel
            {
                Label = "Cap nhat",
                Value = product.CreatedAt.Value.ToString("dd/MM/yyyy")
            });
        }

        return items;
    }

    protected static IReadOnlyList<ProductSpecItemViewModel> BuildSpecificationItems(Product product)
    {
        var detail = product.ProductDetail;
        var items = new List<ProductSpecItemViewModel>();

        AddSpec(items, "CPU", detail?.Cpu);
        AddSpec(items, "RAM", detail?.Ram);
        AddSpec(items, "Bo nho", detail?.Storage);
        AddSpec(items, "Man hinh", detail?.Screen);
        AddSpec(items, "GPU", detail?.Gpu);
        AddSpec(items, "Pin", detail?.Battery);
        AddSpec(items, "He dieu hanh", detail?.Os);

        if (items.Count == 0)
        {
            AddSpec(items, "Thong tin", "San pham chua co bang thong so chi tiet trong database.");
        }

        return items;
    }

    protected static void AddSpec(ICollection<ProductSpecItemViewModel> items, string label, string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return;
        }

        items.Add(new ProductSpecItemViewModel
        {
            Label = label,
            Value = value.Trim()
        });
    }

    protected (string BankId, string BankName, string AccountNumber, string AccountName, string Template) GetBankQrSettings()
    {
        var section = _configuration.GetSection("BankQr");

        return (
            section["BankId"] ?? "VCB",
            section["BankName"] ?? "Vietcombank",
            section["AccountNumber"] ?? "0123456789",
            section["AccountName"] ?? "MOBILE STORE",
            section["Template"] ?? "compact2"
        );
    }

    protected static string BuildTransferContent(int orderId) => $"DH{orderId}";

    protected static string BuildBankQrImageUrl(
        (string BankId, string BankName, string AccountNumber, string AccountName, string Template) bankQr,
        int orderId,
        decimal amount)
    {
        var roundedAmount = decimal.Round(amount, 0, MidpointRounding.AwayFromZero)
            .ToString(CultureInfo.InvariantCulture);
        var transferContent = Uri.EscapeDataString(BuildTransferContent(orderId));
        var accountName = Uri.EscapeDataString(bankQr.AccountName);

        return $"https://img.vietqr.io/image/{bankQr.BankId}-{bankQr.AccountNumber}-{bankQr.Template}.png?amount={roundedAmount}&addInfo={transferContent}&accountName={accountName}";
    }
}
