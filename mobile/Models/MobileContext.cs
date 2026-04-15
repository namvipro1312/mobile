using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace mobile.Models;

public partial class MobileContext : DbContext
{
    public MobileContext()
    {
    }

    public MobileContext(DbContextOptions<MobileContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Blog> Blogs { get; set; }

    public virtual DbSet<BlogComment> BlogComments { get; set; }

    public virtual DbSet<Cart> Carts { get; set; }

    public virtual DbSet<CartItem> CartItems { get; set; }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<Contact> Contacts { get; set; }

    public virtual DbSet<Coupon> Coupons { get; set; }

    public virtual DbSet<Order> Orders { get; set; }

    public virtual DbSet<OrderDetail> OrderDetails { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<Product> Products { get; set; }

    public virtual DbSet<ProductDetail> ProductDetails { get; set; }

    public virtual DbSet<ProductImage> ProductImages { get; set; }

    public virtual DbSet<ProductVariant> ProductVariants { get; set; }

    public virtual DbSet<Review> Reviews { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<Wishlist> Wishlists { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        // DbContext is configured via dependency injection in Program.cs.
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Blog>(entity =>
        {
            entity.HasKey(e => e.BlogId).HasName("PK__Blogs__54379E503CB3EE23");

            entity.Property(e => e.BlogId).HasColumnName("BlogID");
            entity.Property(e => e.Author).HasMaxLength(100);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Image).HasMaxLength(255);
            entity.Property(e => e.Title).HasMaxLength(255);
        });

        modelBuilder.Entity<BlogComment>(entity =>
        {
            entity.HasKey(e => e.CommentId).HasName("PK__BlogComm__C3B4DFAA88C0D0F2");

            entity.Property(e => e.CommentId).HasColumnName("CommentID");
            entity.Property(e => e.BlogId).HasColumnName("BlogID");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Blog).WithMany(p => p.BlogComments)
                .HasForeignKey(d => d.BlogId)
                .HasConstraintName("FK__BlogComme__BlogI__72C60C4A");

            entity.HasOne(d => d.User).WithMany(p => p.BlogComments)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__BlogComme__UserI__73BA3083");
        });

        modelBuilder.Entity<Cart>(entity =>
        {
            entity.HasKey(e => e.CartId).HasName("PK__Cart__51BCD797F1CBD4F8");

            entity.ToTable("Cart");

            entity.HasIndex(e => e.UserId, "UQ__Cart__1788CCAD16A53031").IsUnique();

            entity.Property(e => e.CartId).HasColumnName("CartID");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithOne(p => p.Cart)
                .HasForeignKey<Cart>(d => d.UserId)
                .HasConstraintName("FK__Cart__UserID__52593CB8");
        });

        modelBuilder.Entity<CartItem>(entity =>
        {
            entity.HasKey(e => e.CartItemId).HasName("PK__CartItem__488B0B2A7E26923D");

            entity.Property(e => e.CartItemId).HasColumnName("CartItemID");
            entity.Property(e => e.CartId).HasColumnName("CartID");
            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ProductId).HasColumnName("ProductID");
            entity.Property(e => e.Quantity).HasDefaultValue(1);

            entity.HasOne(d => d.Cart).WithMany(p => p.CartItems)
                .HasForeignKey(d => d.CartId)
                .HasConstraintName("FK__CartItems__CartI__5629CD9C");

            entity.HasOne(d => d.Product).WithMany(p => p.CartItems)
                .HasForeignKey(d => d.ProductId)
                .HasConstraintName("FK__CartItems__Produ__571DF1D5");
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.CategoryId).HasName("PK__Categori__19093A2B2CE1C8B0");

            entity.Property(e => e.CategoryId).HasColumnName("CategoryID");
            entity.Property(e => e.CategoryName).HasMaxLength(100);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Description).HasMaxLength(255);
        });

        modelBuilder.Entity<Contact>(entity =>
        {
            entity.HasKey(e => e.ContactId).HasName("PK__Contacts__5C6625BBE90173AD");

            entity.Property(e => e.ContactId).HasColumnName("ContactID");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.Name).HasMaxLength(100);
        });

        modelBuilder.Entity<Coupon>(entity =>
        {
            entity.HasKey(e => e.CouponId).HasName("PK__Coupons__384AF1DA6F4E8848");

            entity.HasIndex(e => e.Code, "UQ__Coupons__A25C5AA795BCF8E8").IsUnique();

            entity.Property(e => e.CouponId).HasColumnName("CouponID");
            entity.Property(e => e.Code).HasMaxLength(50);
            entity.Property(e => e.Discount).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.ExpiryDate).HasColumnType("datetime");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.OrderId).HasName("PK__Orders__C3905BAF8F836BF6");

            entity.Property(e => e.OrderId).HasColumnName("OrderID");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Note).HasMaxLength(255);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.ShippingAddress).HasMaxLength(255);
            entity.Property(e => e.Status)
                .HasMaxLength(50)
                .HasDefaultValue("Pending");
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.User).WithMany(p => p.Orders)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Orders__UserID__5BE2A6F2");
        });

        modelBuilder.Entity<OrderDetail>(entity =>
        {
            entity.HasKey(e => e.OrderDetailId).HasName("PK__OrderDet__D3B9D30C0F8DDE57");

            entity.Property(e => e.OrderDetailId).HasColumnName("OrderDetailID");
            entity.Property(e => e.OrderId).HasColumnName("OrderID");
            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ProductId).HasColumnName("ProductID");

            entity.HasOne(d => d.Order).WithMany(p => p.OrderDetails)
                .HasForeignKey(d => d.OrderId)
                .HasConstraintName("FK__OrderDeta__Order__5EBF139D");

            entity.HasOne(d => d.Product).WithMany(p => p.OrderDetails)
                .HasForeignKey(d => d.ProductId)
                .HasConstraintName("FK__OrderDeta__Produ__5FB337D6");
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.PaymentId).HasName("PK__Payments__9B556A584378B26D");

            entity.Property(e => e.PaymentId).HasColumnName("PaymentID");
            entity.Property(e => e.OrderId).HasColumnName("OrderID");
            entity.Property(e => e.PaidAt).HasColumnType("datetime");
            entity.Property(e => e.PaymentMethod).HasMaxLength(50);
            entity.Property(e => e.PaymentStatus).HasMaxLength(50);

            entity.HasOne(d => d.Order).WithMany(p => p.Payments)
                .HasForeignKey(d => d.OrderId)
                .HasConstraintName("FK__Payments__OrderI__628FA481");
        });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.ProductId).HasName("PK__Products__B40CC6ED48822040");

            entity.Property(e => e.ProductId).HasColumnName("ProductID");
            entity.Property(e => e.Brand).HasMaxLength(100);
            entity.Property(e => e.CategoryId).HasColumnName("CategoryID");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Discount)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(5, 2)");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(255);
            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Stock).HasDefaultValue(0);
            entity.Property(e => e.Thumbnail).HasMaxLength(255);

            entity.HasOne(d => d.Category).WithMany(p => p.Products)
                .HasForeignKey(d => d.CategoryId)
                .HasConstraintName("FK__Products__Catego__3E52440B");
        });

        modelBuilder.Entity<ProductDetail>(entity =>
        {
            entity.HasKey(e => e.DetailId).HasName("PK__ProductD__135C314DA4AD3A7E");

            entity.HasIndex(e => e.ProductId, "UQ__ProductD__B40CC6ECC6D8C3A3").IsUnique();

            entity.Property(e => e.DetailId).HasColumnName("DetailID");
            entity.Property(e => e.Battery).HasMaxLength(50);
            entity.Property(e => e.Cpu)
                .HasMaxLength(100)
                .HasColumnName("CPU");
            entity.Property(e => e.Gpu)
                .HasMaxLength(100)
                .HasColumnName("GPU");
            entity.Property(e => e.Os)
                .HasMaxLength(50)
                .HasColumnName("OS");
            entity.Property(e => e.ProductId).HasColumnName("ProductID");
            entity.Property(e => e.Ram)
                .HasMaxLength(50)
                .HasColumnName("RAM");
            entity.Property(e => e.Screen).HasMaxLength(100);
            entity.Property(e => e.Storage).HasMaxLength(50);

            entity.HasOne(d => d.Product).WithOne(p => p.ProductDetail)
                .HasForeignKey<ProductDetail>(d => d.ProductId)
                .HasConstraintName("FK__ProductDe__Produ__4222D4EF");
        });

        modelBuilder.Entity<ProductImage>(entity =>
        {
            entity.HasKey(e => e.ImageId).HasName("PK__ProductI__7516F4EC724B7940");

            entity.Property(e => e.ImageId).HasColumnName("ImageID");
            entity.Property(e => e.ImageUrl)
                .HasMaxLength(255)
                .HasColumnName("ImageURL");
            entity.Property(e => e.IsMain).HasDefaultValue(false);
            entity.Property(e => e.ProductId).HasColumnName("ProductID");

            entity.HasOne(d => d.Product).WithMany(p => p.ProductImages)
                .HasForeignKey(d => d.ProductId)
                .HasConstraintName("FK__ProductIm__Produ__45F365D3");
        });

        modelBuilder.Entity<ProductVariant>(entity =>
        {
            entity.HasKey(e => e.VariantId).HasName("PK__ProductV__0EA233E4F1544D8E");

            entity.Property(e => e.VariantId).HasColumnName("VariantID");
            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ProductId).HasColumnName("ProductID");
            entity.Property(e => e.VariantName).HasMaxLength(100);

            entity.HasOne(d => d.Product).WithMany(p => p.ProductVariants)
                .HasForeignKey(d => d.ProductId)
                .HasConstraintName("FK__ProductVa__Produ__48CFD27E");
        });

        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.ReviewId).HasName("PK__Reviews__74BC79AE964BB3CD");

            entity.Property(e => e.ReviewId).HasColumnName("ReviewID");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.ProductId).HasColumnName("ProductID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Product).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.ProductId)
                .HasConstraintName("FK__Reviews__Product__6754599E");

            entity.HasOne(d => d.User).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Reviews__UserID__68487DD7");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("PK__Users__1788CCAC9143F8FF");

            entity.HasIndex(e => e.Username, "UQ__Users__536C85E42F3ECED1").IsUnique();

            entity.Property(e => e.UserId).HasColumnName("UserID");
            entity.Property(e => e.Address).HasMaxLength(255);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.FullName).HasMaxLength(150);
            entity.Property(e => e.Password).HasMaxLength(255);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.Role)
                .HasMaxLength(20)
                .HasDefaultValue("User");
            entity.Property(e => e.Username).HasMaxLength(100);
        });

        modelBuilder.Entity<Wishlist>(entity =>
        {
            entity.HasKey(e => e.WishlistId).HasName("PK__Wishlist__233189CBA746DD90");

            entity.ToTable("Wishlist");

            entity.Property(e => e.WishlistId).HasColumnName("WishlistID");
            entity.Property(e => e.ProductId).HasColumnName("ProductID");
            entity.Property(e => e.UserId).HasColumnName("UserID");

            entity.HasOne(d => d.Product).WithMany(p => p.Wishlists)
                .HasForeignKey(d => d.ProductId)
                .HasConstraintName("FK__Wishlist__Produc__6C190EBB");

            entity.HasOne(d => d.User).WithMany(p => p.Wishlists)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__Wishlist__UserID__6B24EA82");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
