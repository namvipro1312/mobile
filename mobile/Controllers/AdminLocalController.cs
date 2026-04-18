using Microsoft.AspNetCore.Mvc;
using mobile.Models;

namespace mobile.Controllers;

public sealed class AdminLocalController : Controller
{
    private const string SessionAdminLocalUserKey = "AdminLocalUser";

    private readonly IConfiguration _configuration;

    public AdminLocalController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [HttpGet("/admin-local")]
    public IActionResult Index()
    {
        var currentUser = HttpContext.Session.GetString(SessionAdminLocalUserKey);
        if (string.IsNullOrWhiteSpace(currentUser))
        {
            return RedirectToAction(nameof(Login), new { returnUrl = Url.Action(nameof(Index), "AdminLocal") });
        }

        ViewData["AdminLocalUser"] = currentUser;
        return View("~/Views/AdminLocal/Index.cshtml");
    }

    [HttpGet("/admin-local/login")]
    public IActionResult Login(string? returnUrl = null)
    {
        if (IsLoggedIn())
        {
            return RedirectToSafeLocal(returnUrl);
        }

        return View("~/Views/AdminLocal/Login.cshtml", new AdminLocalLoginViewModel
        {
            ReturnUrl = returnUrl
        });
    }

    [HttpPost("/admin-local/login")]
    [ValidateAntiForgeryToken]
    public IActionResult Login(AdminLocalLoginViewModel model)
    {
        if (!ModelState.IsValid)
        {
            return View("~/Views/AdminLocal/Login.cshtml", model);
        }

        var expectedUsername = _configuration["AdminLocalAuth:Username"] ?? "admin";
        var expectedPassword = _configuration["AdminLocalAuth:Password"] ?? "admin123";

        if (!string.Equals(model.Username?.Trim(), expectedUsername, StringComparison.Ordinal) ||
            !string.Equals(model.Password, expectedPassword, StringComparison.Ordinal))
        {
            ModelState.AddModelError(string.Empty, "Tai khoan hoac mat khau khong dung.");
            return View("~/Views/AdminLocal/Login.cshtml", model);
        }

        HttpContext.Session.SetString(SessionAdminLocalUserKey, expectedUsername);
        TempData["SuccessMessage"] = "Da dang nhap khu admin local.";

        return RedirectToSafeLocal(model.ReturnUrl);
    }

    [HttpPost("/admin-local/logout")]
    [ValidateAntiForgeryToken]
    public IActionResult Logout()
    {
        HttpContext.Session.Remove(SessionAdminLocalUserKey);
        TempData["SuccessMessage"] = "Da dang xuat admin local.";
        return RedirectToAction(nameof(Login));
    }

    private bool IsLoggedIn() => !string.IsNullOrWhiteSpace(HttpContext.Session.GetString(SessionAdminLocalUserKey));

    private IActionResult RedirectToSafeLocal(string? returnUrl)
    {
        if (!string.IsNullOrWhiteSpace(returnUrl) && Url.IsLocalUrl(returnUrl))
        {
            return Redirect(returnUrl);
        }

        return RedirectToAction(nameof(Index))!;
    }
}
