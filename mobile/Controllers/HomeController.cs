using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using mobile.Models;

namespace mobile.Controllers;

public class HomeController : Controller
{
    private readonly MobileContext _context;

    public HomeController(MobileContext context)
    {
        _context = context;
    }

    public IActionResult Index() => View();

    public async Task<IActionResult> Blog()
    {
        var blogRows = await _context.Blogs
            .AsNoTracking()
            .Include(item => item.BlogComments)
            .OrderByDescending(item => item.CreatedAt ?? DateTime.MinValue)
            .ToListAsync();

        var articles = blogRows
            .Select(item => new BlogArticleViewModel
            {
                Id = item.BlogId,
                Title = string.IsNullOrWhiteSpace(item.Title) ? "Bai viet chua co tieu de" : item.Title,
                Summary = BuildSummary(item.Content),
                Content = item.Content ?? string.Empty,
                ImageUrl = string.IsNullOrWhiteSpace(item.Image) ? "~/assets/img/blog/blog1.jpg" : item.Image,
                Author = string.IsNullOrWhiteSpace(item.Author) ? "Mobile Store" : item.Author,
                CreatedAt = item.CreatedAt ?? DateTime.Today,
                CommentCount = item.BlogComments.Count
            })
            .ToList();

        return View(articles.Count > 0 ? articles : BuildFallbackArticles());
    }

    public async Task<IActionResult> BlogDetails(int id)
    {
        BlogArticleViewModel? article = null;

        if (id > 0)
        {
            var blog = await _context.Blogs
                .AsNoTracking()
                .Include(item => item.BlogComments)
                .FirstOrDefaultAsync(item => item.BlogId == id);

            if (blog is not null)
            {
                article = new BlogArticleViewModel
                {
                    Id = blog.BlogId,
                    Title = string.IsNullOrWhiteSpace(blog.Title) ? "Bai viet chua co tieu de" : blog.Title,
                    Summary = BuildSummary(blog.Content),
                    Content = blog.Content ?? string.Empty,
                    ImageUrl = string.IsNullOrWhiteSpace(blog.Image) ? "~/assets/img/blog/blog1.jpg" : blog.Image,
                    Author = string.IsNullOrWhiteSpace(blog.Author) ? "Mobile Store" : blog.Author,
                    CreatedAt = blog.CreatedAt ?? DateTime.Today,
                    CommentCount = blog.BlogComments.Count
                };
            }
        }
        else
        {
            article = BuildFallbackArticles().FirstOrDefault(item => item.Id == id);
        }

        if (article is null)
        {
            return NotFound();
        }

        return View(article);
    }

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

    private static string BuildSummary(string? content)
    {
        if (string.IsNullOrWhiteSpace(content))
        {
            return "Bai viet dang duoc cap nhat noi dung.";
        }

        var normalized = content.Trim();
        return normalized.Length <= 150 ? normalized : normalized[..150] + "...";
    }

    private static List<BlogArticleViewModel> BuildFallbackArticles()
    {
        var date = new DateTime(2026, 4, 1);

        return
        [
            new()
            {
                Id = -1,
                Title = "Nen chon dien thoai pin trau hay sac nhanh?",
                Summary = "Pin lon phu hop nguoi di chuyen nhieu, con sac nhanh hop voi nguoi can nap gap trong ngay.",
                Content = "Khi mua dien thoai, dung chi nhin vao dung luong pin. May co pin 5000 mAh nhung toi uu kem van co the thua may 4500 mAh co chip tiet kiem dien va man hinh hieu qua. Neu ban hay di hoc, di lam ca ngay, hay uu tien pin lon, man hinh tiet kiem dien va sac tu 30W tro len. Neu ban thuong o gan o cam, sac nhanh lai quan trong hon vi chi can 20 den 30 phut la co the dung them nua ngay.",
                ImageUrl = "~/assets/img/blog/blog1.jpg",
                Author = "Mobile Store",
                CreatedAt = date
            },
            new()
            {
                Id = -2,
                Title = "Laptop sinh vien nen uu tien nhung thong so nao?",
                Summary = "CPU tiet kiem dien, RAM 16GB va SSD nhanh thuong quan trong hon card do hoa neu nhu cau la hoc tap.",
                Content = "Voi sinh vien, cau hinh can on dinh va de mang theo. RAM 16GB giup may ben hon trong vai nam, SSD 512GB du cho tai lieu, ung dung va mot phan du lieu ca nhan. Neu hoc lap trinh, ke toan, marketing hoac van phong, CPU Intel Core i5/Ryzen 5 doi moi la diem bat dau hop ly. Neu hoc do hoa, kien truc hoac dung phan mem 3D, luc do moi nen uu tien GPU roi moi can nhac den trong luong va pin.",
                ImageUrl = "~/assets/img/blog/blog2.jpg",
                Author = "Mobile Store",
                CreatedAt = date.AddDays(-2)
            },
            new()
            {
                Id = -3,
                Title = "Kiem tra may truoc khi thanh toan",
                Summary = "Hay kiem tra man hinh, loa, camera, sac, IMEI va tinh trang bao hanh truoc khi nhan hang.",
                Content = "Truoc khi thanh toan, ban nen mo may va kiem tra cac diem co ban: man hinh co diem chet hay am mau khong, loa va micro co ro khong, camera co lay net binh thuong khong, cong sac co nhan on dinh khong. Voi dien thoai, kiem tra them IMEI tren hop va trong may. Voi laptop, kiem tra ban phim, touchpad, pin va nhiet do khi chay tac vu nhe.",
                ImageUrl = "~/assets/img/blog/blog3.jpg",
                Author = "Mobile Store",
                CreatedAt = date.AddDays(-4)
            },
            new()
            {
                Id = -4,
                Title = "Khi nao nen nang cap RAM?",
                Summary = "Neu may thuong day RAM khi mo trinh duyet, Office va ung dung lam viec, nang RAM se thay doi ro nhat.",
                Content = "Nang RAM phu hop khi may bi cham do phai mo nhieu ung dung cung luc. Neu ban chi dung tac vu nhe ma may van cham, hay kiem tra o cung va phan mem chay nen truoc. Laptop con dung HDD nen uu tien len SSD truoc, sau do moi nang RAM. Muc 16GB hien la diem can bang tot cho hoc tap, van phong va lap trinh co ban.",
                ImageUrl = "~/assets/img/blog/blog4.jpg",
                Author = "Mobile Store",
                CreatedAt = date.AddDays(-6)
            },
            new()
            {
                Id = -5,
                Title = "Dien thoai chup anh dep can nhin gi?",
                Summary = "Cam bien, chong rung, xu ly anh va chat luong ong kinh quan trong hon so cham megapixel.",
                Content = "Megapixel cao khong dong nghia anh dep hon. Camera tot can cam bien thu sang on, chong rung hieu qua va thuat toan xu ly mau da, HDR, dem. Neu hay quay video, hay xem may co OIS, mic tot va kha nang quay 4K on dinh khong. Neu hay chup chan dung, nen thu truc tiep mau da va tach nen trong dieu kien anh sang trong nha.",
                ImageUrl = "~/assets/img/blog/blog5.jpg",
                Author = "Mobile Store",
                CreatedAt = date.AddDays(-8)
            },
            new()
            {
                Id = -6,
                Title = "Thanh toan QR can luu y noi dung chuyen khoan",
                Summary = "Nhap dung noi dung chuyen khoan giup cua hang doi soat don hang nhanh va tranh cham xac nhan.",
                Content = "Khi thanh toan QR, so tien va noi dung chuyen khoan nen khop voi don hang. Noi dung chuyen khoan thuong gom ma don de he thong hoac nhan vien doi soat nhanh. Sau khi chuyen khoan, ban nen giu lai bien lai neu can ho tro. Neu nhap sai noi dung, hay lien he cua hang som de duoc kiem tra thu cong.",
                ImageUrl = "~/assets/img/blog/blog6.jpg",
                Author = "Mobile Store",
                CreatedAt = date.AddDays(-10)
            }
        ];
    }
}
