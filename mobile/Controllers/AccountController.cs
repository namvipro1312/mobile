using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using mobile.Models;

namespace mobile.Controllers;

public class AccountController : BaseStoreController
{
    public AccountController(MobileContext context, IConfiguration configuration)
        : base(context, configuration)
    {
    }

    [HttpGet]
    public IActionResult Login(string? returnUrl = null)
    {
        if (GetCurrentUserId().HasValue)
        {
            return RedirectToSafeLocal(returnUrl, "Index", "Home");
        }

        return View("~/Views/Home/Login.cshtml", new LoginViewModel
        {
            ReturnUrl = returnUrl
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(LoginViewModel model)
    {
        if (!ModelState.IsValid)
        {
            return View("~/Views/Home/Login.cshtml", model);
        }

        var normalized = model.EmailOrUsername.Trim();
        var user = await _context.Users
            .FirstOrDefaultAsync(item =>
                (item.Email != null && item.Email == normalized) ||
                (item.Username != null && item.Username == normalized));

        if (user is null || string.IsNullOrWhiteSpace(user.Password) || user.Password != model.Password)
        {
            ModelState.AddModelError(string.Empty, "Email/tên đăng nhập hoặc mật khẩu không đúng.");
            return View("~/Views/Home/Login.cshtml", model);
        }

        HttpContext.Session.SetInt32(SessionUserIdKey, user.UserId);
        TempData["SuccessMessage"] = $"Xin chào {user.FullName ?? user.Username ?? "bạn"}, bạn đã đăng nhập thành công.";

        return RedirectToSafeLocal(model.ReturnUrl, "Index", "Home");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Logout()
    {
        HttpContext.Session.Remove(SessionUserIdKey);
        TempData["SuccessMessage"] = "Bạn đã đăng xuất.";
        return RedirectToAction("Index", "Home");
    }

    [HttpGet]
    public IActionResult Register()
    {
        if (GetCurrentUserId().HasValue)
        {
            return RedirectToAction("Index", "Home");
        }

        return View("~/Views/Home/Register.cshtml", new RegisterViewModel());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Register(RegisterViewModel model)
    {
        if (!ModelState.IsValid)
        {
            return View("~/Views/Home/Register.cshtml", model);
        }

        var username = model.Username.Trim();
        var email = model.Email.Trim();

        if (await _context.Users.AnyAsync(item => item.Username == username))
        {
            ModelState.AddModelError(nameof(model.Username), "Tên đăng nhập đã tồn tại.");
        }

        if (await _context.Users.AnyAsync(item => item.Email == email))
        {
            ModelState.AddModelError(nameof(model.Email), "Email đã được sử dụng.");
        }

        if (!ModelState.IsValid)
        {
            return View("~/Views/Home/Register.cshtml", model);
        }

        var user = new User
        {
            Username = username,
            Password = model.Password,
            FullName = model.FullName.Trim(),
            Email = email,
            Phone = string.IsNullOrWhiteSpace(model.Phone) ? null : model.Phone.Trim(),
            Address = string.IsNullOrWhiteSpace(model.Address) ? null : model.Address.Trim(),
            Role = "User",
            CreatedAt = DateTime.Now
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        HttpContext.Session.SetInt32(SessionUserIdKey, user.UserId);
        TempData["SuccessMessage"] = "Tạo tài khoản thành công và đã đăng nhập.";
        return RedirectToAction("Index", "Home");
    }

    [HttpGet]
    public async Task<IActionResult> MyAccount()
    {
        var userId = GetCurrentUserId();
        if (!userId.HasValue)
        {
            TempData["ErrorMessage"] = "Bạn cần đăng nhập để xem tài khoản.";
            return RedirectToAction(nameof(Login), new { returnUrl = Url.Action(nameof(MyAccount), "Account") });
        }

        var user = await _context.Users
            .AsNoTracking()
            .Include(item => item.Orders)
                .ThenInclude(order => order.Payments)
            .FirstOrDefaultAsync(item => item.UserId == userId.Value);

        if (user is null)
        {
            HttpContext.Session.Remove(SessionUserIdKey);
            TempData["ErrorMessage"] = "Phiên đăng nhập không còn hợp lệ, vui lòng đăng nhập lại.";
            return RedirectToAction(nameof(Login), new { returnUrl = Url.Action(nameof(MyAccount), "Account") });
        }

        var recentOrders = user.Orders
            .OrderByDescending(item => item.CreatedAt ?? DateTime.MinValue)
            .Take(6)
            .ToList();

        var cartItemCount = await _context.CartItems
            .AsNoTracking()
            .Include(item => item.Cart)
            .Where(item => item.Cart!.UserId == userId.Value)
            .SumAsync(item => item.Quantity ?? 0);

        var wishlistCount = await _context.Wishlists
            .AsNoTracking()
            .CountAsync(item => item.UserId == userId.Value);

        var pendingAmount = recentOrders
            .Where(item => !string.Equals(item.Status, "Completed", StringComparison.OrdinalIgnoreCase))
            .Sum(item => item.TotalAmount ?? 0m);

        return View("~/Views/Home/MyAccount.cshtml", new MyAccountPageViewModel
        {
            User = user,
            RecentOrders = recentOrders,
            WishlistCount = wishlistCount,
            CartItemCount = cartItemCount,
            PendingAmount = pendingAmount
        });
    }
}
