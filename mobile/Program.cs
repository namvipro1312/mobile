using Microsoft.EntityFrameworkCore;
using mobile.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<MobileContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddControllersWithViews();
builder.Services.AddHttpClient("GeminiChatbox", client =>
{
    client.Timeout = TimeSpan.FromSeconds(30);
});
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.IdleTimeout = TimeSpan.FromHours(8);
});

var app = builder.Build();
await EnsureAdminBootstrapAsync(app);

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseSession();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();

static async Task EnsureAdminBootstrapAsync(WebApplication app)
{
    using var scope = app.Services.CreateScope();
    var configuration = scope.ServiceProvider.GetRequiredService<IConfiguration>();
    var dbContext = scope.ServiceProvider.GetRequiredService<MobileContext>();

    var section = configuration.GetSection("AdminBootstrap");
    if (!section.GetValue("Enabled", false))
    {
        return;
    }

    var username = section["Username"]?.Trim();
    var password = section["Password"];
    var email = section["Email"]?.Trim();
    var fullName = section["FullName"]?.Trim();

    if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
    {
        return;
    }

    var adminUser = await dbContext.Users.FirstOrDefaultAsync(user =>
        (user.Username != null && user.Username == username) ||
        (!string.IsNullOrWhiteSpace(email) && user.Email == email));

    if (adminUser is null)
    {
        dbContext.Users.Add(new User
        {
            Username = username,
            Password = password,
            FullName = string.IsNullOrWhiteSpace(fullName) ? "System Admin" : fullName,
            Email = string.IsNullOrWhiteSpace(email) ? null : email,
            Role = "Admin",
            CreatedAt = DateTime.Now
        });
    }
    else
    {
        adminUser.Role = "Admin";

        if (string.IsNullOrWhiteSpace(adminUser.Password))
        {
            adminUser.Password = password;
        }
    }

    await dbContext.SaveChangesAsync();
}
