using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using mobile.Models;

namespace mobile.Controllers;

public class CheckoutController : BaseStoreController
{
    public CheckoutController(MobileContext context, IConfiguration configuration)
        : base(context, configuration)
    {
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> AddToCart(int productId, int quantity = 1, string? returnUrl = null)
    {
        quantity = Math.Max(quantity, 1);

        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập trước khi thêm vào giỏ hàng.";
            return RedirectToAction("Login", "Account", new { returnUrl = returnUrl ?? Url.Action("Product", "Shop", new { id = productId }) });
        }

        var product = await _context.Products
            .AsNoTracking()
            .FirstOrDefaultAsync(item => item.ProductId == productId && item.IsActive != false);

        if (product is null)
        {
            TempData["ErrorMessage"] = "Không tìm thấy sản phẩm cần thêm vào giỏ hàng.";
            return RedirectToSafeLocal(returnUrl, "Shop", "Shop");
        }

        var cart = await GetOrCreateCartAsync(userId.Value);
        var cartItem = await _context.CartItems
            .FirstOrDefaultAsync(item => item.CartId == cart.CartId && item.ProductId == productId);

        var finalPrice = CalculateFinalPrice(product);

        if (cartItem is null)
        {
            _context.CartItems.Add(new CartItem
            {
                CartId = cart.CartId,
                ProductId = productId,
                Quantity = quantity,
                Price = finalPrice
            });
        }
        else
        {
            cartItem.Quantity = Math.Max((cartItem.Quantity ?? 0) + quantity, 1);
            cartItem.Price = finalPrice;
        }

        await _context.SaveChangesAsync();
        TempData["SuccessMessage"] = $"Đã thêm \"{product.Name}\" vào giỏ hàng.";
        return RedirectToSafeLocal(returnUrl, nameof(Cart), "Checkout");
    }

    [HttpGet]
    public async Task<IActionResult> Cart()
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập để xem giỏ hàng.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Cart), "Checkout") });
        }

        var items = await BuildCartItemsAsync(userId.Value);
        return View("~/Views/Home/Cart.cshtml", new CartPageViewModel
        {
            Items = items,
            Subtotal = items.Sum(item => item.LineTotal),
            IsLoggedIn = true
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> UpdateCartItem(int cartItemId, int quantity)
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập để cập nhật giỏ hàng.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Cart), "Checkout") });
        }

        var cartItem = await _context.CartItems
            .Include(item => item.Cart)
            .Include(item => item.Product)
            .FirstOrDefaultAsync(item => item.CartItemId == cartItemId && item.Cart!.UserId == userId.Value);

        if (cartItem is null)
        {
            TempData["ErrorMessage"] = "Không tìm thấy sản phẩm trong giỏ hàng.";
            return RedirectToAction(nameof(Cart));
        }

        if (quantity <= 0)
        {
            _context.CartItems.Remove(cartItem);
            TempData["SuccessMessage"] = "Đã xóa sản phẩm khỏi giỏ hàng.";
        }
        else
        {
            cartItem.Quantity = quantity;
            if (cartItem.Product is not null)
            {
                cartItem.Price = CalculateFinalPrice(cartItem.Product);
            }

            TempData["SuccessMessage"] = "Đã cập nhật số lượng trong giỏ hàng.";
        }

        await _context.SaveChangesAsync();
        return RedirectToAction(nameof(Cart));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> RemoveCartItem(int cartItemId, string? returnUrl = null)
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập để thao tác giỏ hàng.";
            return RedirectToAction("Login", "Account", new { returnUrl = returnUrl ?? Url.Action(nameof(Cart), "Checkout") });
        }

        var cartItem = await _context.CartItems
            .Include(item => item.Cart)
            .FirstOrDefaultAsync(item => item.CartItemId == cartItemId && item.Cart!.UserId == userId.Value);

        if (cartItem is not null)
        {
            _context.CartItems.Remove(cartItem);
            await _context.SaveChangesAsync();
            TempData["SuccessMessage"] = "Đã xóa sản phẩm khỏi giỏ hàng.";
        }

        return RedirectToSafeLocal(returnUrl, nameof(Cart), "Checkout");
    }

    [HttpGet]
    public async Task<IActionResult> Checkout()
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập trước khi thanh toán.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Checkout), "Checkout") });
        }

        var user = await _context.Users.AsNoTracking().FirstOrDefaultAsync(item => item.UserId == userId.Value);
        if (user is null)
        {
            HttpContext.Session.Remove(SessionUserIdKey);
            TempData["ErrorMessage"] = "Phiên đăng nhập không còn hợp lệ, vui lòng đăng nhập lại.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Checkout), "Checkout") });
        }

        var items = await BuildCartItemsAsync(userId.Value);
        if (items.Count == 0)
        {
            TempData["ErrorMessage"] = "Giỏ hàng đang trống, chưa thể thanh toán.";
            return RedirectToAction(nameof(Cart));
        }

        return View("~/Views/Home/Checkout.cshtml", new CheckoutPageViewModel
        {
            FullName = user.FullName ?? string.Empty,
            Email = user.Email ?? string.Empty,
            Phone = user.Phone ?? string.Empty,
            ShippingAddress = user.Address ?? string.Empty,
            Items = items,
            Subtotal = items.Sum(item => item.LineTotal),
            PaymentMethod = PaymentMethodBankQr
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Checkout(CheckoutPageViewModel model)
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập trước khi thanh toán.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Checkout), "Checkout") });
        }

        var user = await _context.Users.FirstOrDefaultAsync(item => item.UserId == userId.Value);
        if (user is null)
        {
            HttpContext.Session.Remove(SessionUserIdKey);
            TempData["ErrorMessage"] = "Phiên đăng nhập không còn hợp lệ, vui lòng đăng nhập lại.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(Checkout), "Checkout") });
        }

        var items = await BuildCartItemsAsync(userId.Value);
        if (items.Count == 0)
        {
            TempData["ErrorMessage"] = "Giỏ hàng đang trống, chưa thể thanh toán.";
            return RedirectToAction(nameof(Cart));
        }

        if (!ModelState.IsValid)
        {
            model.Items = items;
            model.Subtotal = items.Sum(item => item.LineTotal);
            return View("~/Views/Home/Checkout.cshtml", model);
        }

        var paymentMethod = NormalizePaymentMethod(model.PaymentMethod);
        var paymentStatus = BuildPaymentStatus(paymentMethod);
        var orderStatus = paymentMethod switch
        {
            "Bank QR" => "Awaiting Payment",
            "Pay At Store" => "Awaiting Store Payment",
            _ => "Pending"
        };

        var order = new Order
        {
            UserId = userId.Value,
            TotalAmount = items.Sum(item => item.LineTotal),
            ShippingAddress = model.ShippingAddress.Trim(),
            Phone = model.Phone.Trim(),
            Note = string.IsNullOrWhiteSpace(model.Note) ? null : model.Note.Trim(),
            Status = orderStatus,
            CreatedAt = DateTime.Now
        };

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        foreach (var item in items)
        {
            _context.OrderDetails.Add(new OrderDetail
            {
                OrderId = order.OrderId,
                ProductId = item.Product.ProductId,
                Quantity = item.Quantity,
                Price = item.UnitPrice
            });

            var product = await _context.Products.FirstOrDefaultAsync(productItem => productItem.ProductId == item.Product.ProductId);
            if (product is not null && product.Stock.HasValue)
            {
                product.Stock = Math.Max(product.Stock.Value - item.Quantity, 0);
            }
        }

        _context.Payments.Add(new Payment
        {
            OrderId = order.OrderId,
            PaymentMethod = paymentMethod,
            PaymentStatus = paymentStatus
        });

        var cartItems = await _context.CartItems
            .Include(item => item.Cart)
            .Where(item => item.Cart!.UserId == userId.Value)
            .ToListAsync();

        _context.CartItems.RemoveRange(cartItems);

        user.FullName = model.FullName.Trim();
        user.Email = model.Email.Trim();
        user.Phone = model.Phone.Trim();
        user.Address = model.ShippingAddress.Trim();

        await _context.SaveChangesAsync();

        if (paymentMethod == "Bank QR")
        {
            TempData["SuccessMessage"] = $"Đơn hàng #{order.OrderId} đã được tạo. Vui lòng quét QR để thanh toán.";
            return RedirectToAction(nameof(PaymentQr), new { orderId = order.OrderId });
        }

        TempData["SuccessMessage"] = paymentMethod == "Pay At Store"
            ? $"Đơn hàng #{order.OrderId} đã được tạo. Bạn sẽ thanh toán tại cửa hàng khi đến nhận."
            : $"Đặt hàng thành công. Mã đơn của bạn là #{order.OrderId}.";

        return RedirectToAction(nameof(Cart));
    }

    [HttpGet]
    public async Task<IActionResult> PaymentQr(int orderId)
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập để xem mã QR thanh toán.";
            return RedirectToAction("Login", "Account", new { returnUrl = Url.Action(nameof(PaymentQr), "Checkout", new { orderId }) });
        }

        var order = await _context.Orders
            .AsNoTracking()
            .Include(item => item.Payments)
            .FirstOrDefaultAsync(item => item.OrderId == orderId && item.UserId == userId.Value);

        if (order is null)
        {
            return NotFound();
        }

        var payment = order.Payments
            .OrderByDescending(item => item.PaymentId)
            .FirstOrDefault();

        if (!string.Equals(payment?.PaymentMethod, "Bank QR", StringComparison.OrdinalIgnoreCase))
        {
            TempData["ErrorMessage"] = "Đơn hàng này không sử dụng thanh toán QR ngân hàng.";
            return RedirectToAction(nameof(Cart));
        }

        var bankQr = GetBankQrSettings();

        return View("~/Views/Home/PaymentQr.cshtml", new PaymentQrPageViewModel
        {
            OrderId = order.OrderId,
            Amount = order.TotalAmount ?? 0m,
            BankId = bankQr.BankId,
            BankName = bankQr.BankName,
            AccountNumber = bankQr.AccountNumber,
            AccountName = bankQr.AccountName,
            TransferContent = BuildTransferContent(order.OrderId),
            QrImageUrl = BuildBankQrImageUrl(bankQr, order.OrderId, order.TotalAmount ?? 0m),
            PaymentStatus = payment?.PaymentStatus ?? "Pending",
            OrderStatus = order.Status ?? "Pending"
        });
    }
}
