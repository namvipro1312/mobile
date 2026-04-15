using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using mobile.Models;

namespace mobile.Controllers;

public class HomeController : Controller
{
    public IActionResult Index() => View();

    public IActionResult Blog() => View();

    public IActionResult About() => View();

    public IActionResult Contact() => View();

    public IActionResult Privacy() => View();

    public IActionResult Shop() => RedirectToAction("Shop", "Shop");

    public IActionResult Product(int id) => RedirectToAction("Product", "Shop", new { id });

    public IActionResult Compare() => RedirectToAction("Compare", "Shop");

    public IActionResult Wishlist() => RedirectToAction("Wishlist", "Shop");

    public IActionResult Cart() => RedirectToAction("Cart", "Checkout");

    public IActionResult Checkout() => RedirectToAction("Checkout", "Checkout");

    public IActionResult PaymentQr(int orderId) => RedirectToAction("PaymentQr", "Checkout", new { orderId });

    public IActionResult Login(string? returnUrl = null) => RedirectToAction("Login", "Account", new { returnUrl });

    public IActionResult Register() => RedirectToAction("Register", "Account");

    public IActionResult MyAccount() => RedirectToAction("MyAccount", "Account");

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
