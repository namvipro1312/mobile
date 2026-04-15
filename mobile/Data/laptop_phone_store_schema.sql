/*
====================================================================
DATABASE DESIGN - WEBSITE BAN LAPTOP VA DIEN THOAI (DINH HUONG FPT)
Project: ASP.NET Core MVC - mobile
Database engine: SQL Server
File muc tieu: Mot file duy nhat de mo ta schema chi tiet
Ngay tao: 2026-04-11
====================================================================

1. CHUC NANG HIEN TAI DOC TU WEBSITE
   - Home: banner/slider, san pham noi bat, brand carousel, newsletter
   - Shop: danh sach san pham
   - Product Detail: gallery, gia, bien the, mo ta, review, related products
   - Cart: gio hang, coupon, uoc tinh phi giao hang
   - Checkout: billing, shipping, login nhanh, tao tai khoan, thanh toan
   - Wishlist, Compare, Login, Register, My Account, Contact, Blog

2. DINH HUONG MOI CHO WEBSITE
   - Chi ban 2 nhom chinh: LAPTOP va DIEN THOAI
   - Phu hop mo hinh nhu FPT Shop:
     + Brand / category / product / variant
     + Ton kho theo chi nhanh
     + Gia khuyen mai, coupon, tra gop
     + Danh gia san pham
     + Wishlist / compare
     + Order / payment / shipment
     + Banner, blog, contact, newsletter

3. GHI CHU THIET KE
   - Product = dong san pham / model
   - ProductVariant = SKU ban thuc te theo mau sac, RAM, SSD, storage...
   - Tach bang thong so rieng cho Laptop va Phone
   - Bang Downloads trong template MyAccount la chuc nang mau, khong phai core
     cho website ban laptop/dien thoai, nen khong tao bang rieng.
*/

IF DB_ID(N'LaptopPhoneStoreDB') IS NULL
BEGIN
    CREATE DATABASE [LaptopPhoneStoreDB];
END
GO

USE [LaptopPhoneStoreDB];
GO

/* ================================================================
   DROP THEO THU TU NGUOC PHU THUOC DE CHAY LAI SCRIPT AN TOAN
   ================================================================ */

DROP TABLE IF EXISTS dbo.BlogPosts;
DROP TABLE IF EXISTS dbo.BannerSliders;
DROP TABLE IF EXISTS dbo.NewsletterSubscriptions;
DROP TABLE IF EXISTS dbo.ContactMessages;
DROP TABLE IF EXISTS dbo.ProductReviews;
DROP TABLE IF EXISTS dbo.Shipments;
DROP TABLE IF EXISTS dbo.OrderInstallments;
DROP TABLE IF EXISTS dbo.Payments;
DROP TABLE IF EXISTS dbo.OrderStatusHistories;
DROP TABLE IF EXISTS dbo.OrderItems;
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.CouponUsages;
DROP TABLE IF EXISTS dbo.Coupons;
DROP TABLE IF EXISTS dbo.PromotionTargets;
DROP TABLE IF EXISTS dbo.Promotions;
DROP TABLE IF EXISTS dbo.CompareItems;
DROP TABLE IF EXISTS dbo.CompareLists;
DROP TABLE IF EXISTS dbo.WishlistItems;
DROP TABLE IF EXISTS dbo.Wishlists;
DROP TABLE IF EXISTS dbo.CartItems;
DROP TABLE IF EXISTS dbo.Carts;
DROP TABLE IF EXISTS dbo.InstallmentPlans;
DROP TABLE IF EXISTS dbo.InstallmentProviders;
DROP TABLE IF EXISTS dbo.WarrantyPackages;
DROP TABLE IF EXISTS dbo.InventoryStocks;
DROP TABLE IF EXISTS dbo.StoreBranches;
DROP TABLE IF EXISTS dbo.PhoneSpecifications;
DROP TABLE IF EXISTS dbo.LaptopSpecifications;
DROP TABLE IF EXISTS dbo.ProductRelations;
DROP TABLE IF EXISTS dbo.ProductTagMappings;
DROP TABLE IF EXISTS dbo.ProductTags;
DROP TABLE IF EXISTS dbo.ProductFeatureBullets;
DROP TABLE IF EXISTS dbo.ProductImages;
DROP TABLE IF EXISTS dbo.ProductVariants;
DROP TABLE IF EXISTS dbo.Products;
DROP TABLE IF EXISTS dbo.Colors;
DROP TABLE IF EXISTS dbo.Brands;
DROP TABLE IF EXISTS dbo.Categories;
DROP TABLE IF EXISTS dbo.UserAddresses;
DROP TABLE IF EXISTS dbo.UserRoles;
DROP TABLE IF EXISTS dbo.Users;
DROP TABLE IF EXISTS dbo.Roles;
GO

/* ================================================================
   1. BAO MAT VA NGUOI DUNG
   ================================================================ */

IF OBJECT_ID(N'dbo.Roles', N'U') IS NOT NULL DROP TABLE dbo.Roles;
CREATE TABLE dbo.Roles
(
    RoleId               INT IDENTITY(1,1) PRIMARY KEY,
    RoleCode             NVARCHAR(50)  NOT NULL UNIQUE,
    RoleName             NVARCHAR(100) NOT NULL,
    CreatedAt            DATETIME2(0)  NOT NULL CONSTRAINT DF_Roles_CreatedAt DEFAULT SYSDATETIME()
);
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
CREATE TABLE dbo.Users
(
    UserId               INT IDENTITY(1,1) PRIMARY KEY,
    Email                NVARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber          NVARCHAR(20)  NULL UNIQUE,
    PasswordHash         NVARCHAR(255) NOT NULL,
    FullName             NVARCHAR(150) NOT NULL,
    DateOfBirth          DATE          NULL,
    Gender               NVARCHAR(10)  NULL,
    AvatarUrl            NVARCHAR(500) NULL,
    Status               NVARCHAR(20)  NOT NULL CONSTRAINT DF_Users_Status DEFAULT N'ACTIVE',
    EmailConfirmed       BIT           NOT NULL CONSTRAINT DF_Users_EmailConfirmed DEFAULT 0,
    PhoneConfirmed       BIT           NOT NULL CONSTRAINT DF_Users_PhoneConfirmed DEFAULT 0,
    ReceivePartnerOffers BIT           NOT NULL CONSTRAINT DF_Users_ReceivePartnerOffers DEFAULT 0,
    IsNewsletterSubscribed BIT         NOT NULL CONSTRAINT DF_Users_IsNewsletterSubscribed DEFAULT 0,
    LastLoginAt          DATETIME2(0)  NULL,
    CreatedAt            DATETIME2(0)  NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSDATETIME(),
    UpdatedAt            DATETIME2(0)  NOT NULL CONSTRAINT DF_Users_UpdatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Users_Status CHECK (Status IN (N'ACTIVE', N'LOCKED', N'DELETED')),
    CONSTRAINT CK_Users_Gender CHECK (Gender IS NULL OR Gender IN (N'MALE', N'FEMALE', N'OTHER'))
);
GO

IF OBJECT_ID(N'dbo.UserRoles', N'U') IS NOT NULL DROP TABLE dbo.UserRoles;
CREATE TABLE dbo.UserRoles
(
    UserId               INT NOT NULL,
    RoleId               INT NOT NULL,
    AssignedAt           DATETIME2(0) NOT NULL CONSTRAINT DF_UserRoles_AssignedAt DEFAULT SYSDATETIME(),
    PRIMARY KEY (UserId, RoleId),
    CONSTRAINT FK_UserRoles_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_UserRoles_Roles FOREIGN KEY (RoleId) REFERENCES dbo.Roles(RoleId)
);
GO

IF OBJECT_ID(N'dbo.UserAddresses', N'U') IS NOT NULL DROP TABLE dbo.UserAddresses;
CREATE TABLE dbo.UserAddresses
(
    AddressId            INT IDENTITY(1,1) PRIMARY KEY,
    UserId               INT            NOT NULL,
    AddressType          NVARCHAR(20)   NOT NULL,
    ReceiverName         NVARCHAR(150)  NOT NULL,
    ReceiverPhone        NVARCHAR(20)   NOT NULL,
    ProvinceCode         NVARCHAR(20)   NULL,
    ProvinceName         NVARCHAR(100)  NOT NULL,
    DistrictCode         NVARCHAR(20)   NULL,
    DistrictName         NVARCHAR(100)  NOT NULL,
    WardCode             NVARCHAR(20)   NULL,
    WardName             NVARCHAR(100)  NULL,
    AddressLine          NVARCHAR(255)  NOT NULL,
    PostalCode           NVARCHAR(20)   NULL,
    IsDefaultBilling     BIT            NOT NULL CONSTRAINT DF_UserAddresses_IsDefaultBilling DEFAULT 0,
    IsDefaultShipping    BIT            NOT NULL CONSTRAINT DF_UserAddresses_IsDefaultShipping DEFAULT 0,
    CreatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_UserAddresses_CreatedAt DEFAULT SYSDATETIME(),
    UpdatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_UserAddresses_UpdatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_UserAddresses_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_UserAddresses_AddressType CHECK (AddressType IN (N'BILLING', N'SHIPPING', N'OTHER'))
);
GO

/* ================================================================
   2. DANH MUC / THUONG HIEU / THUOC TINH CO BAN
   ================================================================ */

IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL DROP TABLE dbo.Categories;
CREATE TABLE dbo.Categories
(
    CategoryId           INT IDENTITY(1,1) PRIMARY KEY,
    ParentCategoryId     INT            NULL,
    CategoryName         NVARCHAR(150)  NOT NULL,
    Slug                 NVARCHAR(180)  NOT NULL UNIQUE,
    Description          NVARCHAR(500)  NULL,
    DisplayOrder         INT            NOT NULL CONSTRAINT DF_Categories_DisplayOrder DEFAULT 0,
    IsActive             BIT            NOT NULL CONSTRAINT DF_Categories_IsActive DEFAULT 1,
    CreatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_Categories_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryId) REFERENCES dbo.Categories(CategoryId)
);
GO

IF OBJECT_ID(N'dbo.Brands', N'U') IS NOT NULL DROP TABLE dbo.Brands;
CREATE TABLE dbo.Brands
(
    BrandId              INT IDENTITY(1,1) PRIMARY KEY,
    BrandName            NVARCHAR(150) NOT NULL UNIQUE,
    Slug                 NVARCHAR(180) NOT NULL UNIQUE,
    LogoUrl              NVARCHAR(500) NULL,
    CountryOfOrigin      NVARCHAR(100) NULL,
    Description          NVARCHAR(500) NULL,
    IsActive             BIT           NOT NULL CONSTRAINT DF_Brands_IsActive DEFAULT 1,
    CreatedAt            DATETIME2(0)  NOT NULL CONSTRAINT DF_Brands_CreatedAt DEFAULT SYSDATETIME()
);
GO

IF OBJECT_ID(N'dbo.Colors', N'U') IS NOT NULL DROP TABLE dbo.Colors;
CREATE TABLE dbo.Colors
(
    ColorId              INT IDENTITY(1,1) PRIMARY KEY,
    ColorName            NVARCHAR(100) NOT NULL UNIQUE,
    ColorCode            NVARCHAR(20)  NULL,
    SortOrder            INT           NOT NULL CONSTRAINT DF_Colors_SortOrder DEFAULT 0
);
GO

/* ================================================================
   3. SAN PHAM, BIEN THE, THONG SO
   ================================================================ */

IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL DROP TABLE dbo.Products;
CREATE TABLE dbo.Products
(
    ProductId            INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId           INT             NOT NULL,
    BrandId              INT             NOT NULL,
    ProductType          NVARCHAR(20)    NOT NULL,
    ProductName          NVARCHAR(255)   NOT NULL,
    Slug                 NVARCHAR(300)   NOT NULL UNIQUE,
    ModelCode            NVARCHAR(100)   NULL,
    ShortDescription     NVARCHAR(1000)  NULL,
    FullDescription      NVARCHAR(MAX)   NULL,
    WarrantyMonths       INT             NOT NULL CONSTRAINT DF_Products_WarrantyMonths DEFAULT 12,
    ReleaseYear          SMALLINT        NULL,
    SeoTitle             NVARCHAR(255)   NULL,
    SeoDescription       NVARCHAR(500)   NULL,
    AverageRating        DECIMAL(3,2)    NOT NULL CONSTRAINT DF_Products_AverageRating DEFAULT 0,
    ReviewCount          INT             NOT NULL CONSTRAINT DF_Products_ReviewCount DEFAULT 0,
    IsFeatured           BIT             NOT NULL CONSTRAINT DF_Products_IsFeatured DEFAULT 0,
    IsNew                BIT             NOT NULL CONSTRAINT DF_Products_IsNew DEFAULT 0,
    IsActive             BIT             NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT 1,
    CreatedAt            DATETIME2(0)    NOT NULL CONSTRAINT DF_Products_CreatedAt DEFAULT SYSDATETIME(),
    UpdatedAt            DATETIME2(0)    NOT NULL CONSTRAINT DF_Products_UpdatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT FK_Products_Brands FOREIGN KEY (BrandId) REFERENCES dbo.Brands(BrandId),
    CONSTRAINT CK_Products_ProductType CHECK (ProductType IN (N'LAPTOP', N'PHONE'))
);
GO

IF OBJECT_ID(N'dbo.ProductVariants', N'U') IS NOT NULL DROP TABLE dbo.ProductVariants;
CREATE TABLE dbo.ProductVariants
(
    VariantId            INT IDENTITY(1,1) PRIMARY KEY,
    ProductId            INT             NOT NULL,
    ColorId              INT             NULL,
    VariantName          NVARCHAR(255)   NOT NULL,
    SKU                  NVARCHAR(100)   NOT NULL UNIQUE,
    Barcode              NVARCHAR(100)   NULL,
    StorageGB            INT             NULL,
    RamGB                INT             NULL,
    SSDGB                INT             NULL,
    CpuName              NVARCHAR(150)   NULL,
    GpuName              NVARCHAR(150)   NULL,
    ScreenSizeInch       DECIMAL(4,1)    NULL,
    OriginalPrice        DECIMAL(18,2)   NOT NULL,
    SalePrice            DECIMAL(18,2)   NULL,
    CostPrice            DECIMAL(18,2)   NULL,
    WeightGram           INT             NULL,
    DimensionText        NVARCHAR(150)   NULL,
    StockStatus          NVARCHAR(20)    NOT NULL CONSTRAINT DF_ProductVariants_StockStatus DEFAULT N'IN_STOCK',
    IsDefault            BIT             NOT NULL CONSTRAINT DF_ProductVariants_IsDefault DEFAULT 0,
    IsActive             BIT             NOT NULL CONSTRAINT DF_ProductVariants_IsActive DEFAULT 1,
    CreatedAt            DATETIME2(0)    NOT NULL CONSTRAINT DF_ProductVariants_CreatedAt DEFAULT SYSDATETIME(),
    UpdatedAt            DATETIME2(0)    NOT NULL CONSTRAINT DF_ProductVariants_UpdatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_ProductVariants_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_ProductVariants_Colors FOREIGN KEY (ColorId) REFERENCES dbo.Colors(ColorId),
    CONSTRAINT CK_ProductVariants_Price CHECK (OriginalPrice >= 0 AND (SalePrice IS NULL OR SalePrice >= 0)),
    CONSTRAINT CK_ProductVariants_StockStatus CHECK (StockStatus IN (N'IN_STOCK', N'LOW_STOCK', N'OUT_OF_STOCK', N'PREORDER'))
);
GO

IF OBJECT_ID(N'dbo.ProductImages', N'U') IS NOT NULL DROP TABLE dbo.ProductImages;
CREATE TABLE dbo.ProductImages
(
    ImageId              INT IDENTITY(1,1) PRIMARY KEY,
    ProductId            INT            NULL,
    VariantId            INT            NULL,
    ImageUrl             NVARCHAR(500)  NOT NULL,
    AltText              NVARCHAR(255)  NULL,
    IsPrimary            BIT            NOT NULL CONSTRAINT DF_ProductImages_IsPrimary DEFAULT 0,
    DisplayOrder         INT            NOT NULL CONSTRAINT DF_ProductImages_DisplayOrder DEFAULT 0,
    CreatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_ProductImages_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_ProductImages_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_ProductImages_ProductVariants FOREIGN KEY (VariantId) REFERENCES dbo.ProductVariants(VariantId),
    CONSTRAINT CK_ProductImages_Owner CHECK (ProductId IS NOT NULL OR VariantId IS NOT NULL)
);
GO

IF OBJECT_ID(N'dbo.ProductFeatureBullets', N'U') IS NOT NULL DROP TABLE dbo.ProductFeatureBullets;
CREATE TABLE dbo.ProductFeatureBullets
(
    FeatureId            INT IDENTITY(1,1) PRIMARY KEY,
    ProductId            INT             NOT NULL,
    Title                NVARCHAR(200)   NOT NULL,
    FeatureValue         NVARCHAR(300)   NULL,
    IconCss              NVARCHAR(100)   NULL,
    DisplayOrder         INT             NOT NULL CONSTRAINT DF_ProductFeatureBullets_DisplayOrder DEFAULT 0,
    CONSTRAINT FK_ProductFeatureBullets_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId)
);
GO

IF OBJECT_ID(N'dbo.ProductTags', N'U') IS NOT NULL DROP TABLE dbo.ProductTags;
CREATE TABLE dbo.ProductTags
(
    TagId                INT IDENTITY(1,1) PRIMARY KEY,
    TagName              NVARCHAR(100) NOT NULL UNIQUE,
    Slug                 NVARCHAR(120) NOT NULL UNIQUE
);
GO

IF OBJECT_ID(N'dbo.ProductTagMappings', N'U') IS NOT NULL DROP TABLE dbo.ProductTagMappings;
CREATE TABLE dbo.ProductTagMappings
(
    ProductId            INT NOT NULL,
    TagId                INT NOT NULL,
    PRIMARY KEY (ProductId, TagId),
    CONSTRAINT FK_ProductTagMappings_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_ProductTagMappings_ProductTags FOREIGN KEY (TagId) REFERENCES dbo.ProductTags(TagId)
);
GO

IF OBJECT_ID(N'dbo.ProductRelations', N'U') IS NOT NULL DROP TABLE dbo.ProductRelations;
CREATE TABLE dbo.ProductRelations
(
    ProductRelationId    INT IDENTITY(1,1) PRIMARY KEY,
    ProductId            INT           NOT NULL,
    RelatedProductId     INT           NOT NULL,
    RelationType         NVARCHAR(20)  NOT NULL,
    DisplayOrder         INT           NOT NULL CONSTRAINT DF_ProductRelations_DisplayOrder DEFAULT 0,
    CONSTRAINT FK_ProductRelations_Product FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_ProductRelations_RelatedProduct FOREIGN KEY (RelatedProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT CK_ProductRelations_RelationType CHECK (RelationType IN (N'RELATED', N'UPSELL', N'CROSSSELL'))
);
GO

IF OBJECT_ID(N'dbo.LaptopSpecifications', N'U') IS NOT NULL DROP TABLE dbo.LaptopSpecifications;
CREATE TABLE dbo.LaptopSpecifications
(
    ProductId            INT PRIMARY KEY,
    CpuSeries            NVARCHAR(150)  NULL,
    CpuGeneration        NVARCHAR(100)  NULL,
    GpuSeries            NVARCHAR(150)  NULL,
    RamType              NVARCHAR(50)   NULL,
    RamBusMHz            INT            NULL,
    RamMaxGB             INT            NULL,
    StorageType          NVARCHAR(50)   NULL,
    AdditionalSlot       NVARCHAR(100)  NULL,
    ScreenResolution     NVARCHAR(100)  NULL,
    ScreenTechnology     NVARCHAR(200)  NULL,
    RefreshRateHz        INT            NULL,
    BatteryInfo          NVARCHAR(150)  NULL,
    WebcamInfo           NVARCHAR(100)  NULL,
    KeyboardInfo         NVARCHAR(150)  NULL,
    WirelessConnectivity NVARCHAR(200)  NULL,
    Ports                NVARCHAR(500)  NULL,
    OperatingSystem      NVARCHAR(100)  NULL,
    WeightKg             DECIMAL(5,2)   NULL,
    Material             NVARCHAR(150)  NULL,
    CONSTRAINT FK_LaptopSpecifications_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId)
);
GO

IF OBJECT_ID(N'dbo.PhoneSpecifications', N'U') IS NOT NULL DROP TABLE dbo.PhoneSpecifications;
CREATE TABLE dbo.PhoneSpecifications
(
    ProductId            INT PRIMARY KEY,
    ScreenTechnology     NVARCHAR(150)  NULL,
    ScreenResolution     NVARCHAR(100)  NULL,
    RefreshRateHz        INT            NULL,
    RearCameraInfo       NVARCHAR(255)  NULL,
    FrontCameraInfo      NVARCHAR(255)  NULL,
    Chipset              NVARCHAR(150)  NULL,
    BatteryMah           INT            NULL,
    ChargingWatt         INT            NULL,
    SimInfo              NVARCHAR(150)  NULL,
    OperatingSystem      NVARCHAR(100)  NULL,
    WaterResistance      NVARCHAR(100)  NULL,
    SecurityFeatures     NVARCHAR(150)  NULL,
    Connectivity         NVARCHAR(300)  NULL,
    NfcSupported         BIT            NOT NULL CONSTRAINT DF_PhoneSpecifications_NfcSupported DEFAULT 0,
    FiveGSupported       BIT            NOT NULL CONSTRAINT DF_PhoneSpecifications_FiveGSupported DEFAULT 0,
    CONSTRAINT FK_PhoneSpecifications_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId)
);
GO

/* ================================================================
   4. TON KHO, CUA HANG, BAO HANH, TRA GOP
   ================================================================ */

IF OBJECT_ID(N'dbo.StoreBranches', N'U') IS NOT NULL DROP TABLE dbo.StoreBranches;
CREATE TABLE dbo.StoreBranches
(
    StoreId              INT IDENTITY(1,1) PRIMARY KEY,
    StoreCode            NVARCHAR(50)   NOT NULL UNIQUE,
    StoreName            NVARCHAR(150)  NOT NULL,
    ProvinceName         NVARCHAR(100)  NOT NULL,
    DistrictName         NVARCHAR(100)  NOT NULL,
    WardName             NVARCHAR(100)  NULL,
    AddressLine          NVARCHAR(255)  NOT NULL,
    PhoneNumber          NVARCHAR(20)   NULL,
    Email                NVARCHAR(255)  NULL,
    OpeningHours         NVARCHAR(100)  NULL,
    Latitude             DECIMAL(10,7)  NULL,
    Longitude            DECIMAL(10,7)  NULL,
    IsActive             BIT            NOT NULL CONSTRAINT DF_StoreBranches_IsActive DEFAULT 1,
    CreatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_StoreBranches_CreatedAt DEFAULT SYSDATETIME()
);
GO

IF OBJECT_ID(N'dbo.InventoryStocks', N'U') IS NOT NULL DROP TABLE dbo.InventoryStocks;
CREATE TABLE dbo.InventoryStocks
(
    InventoryId          INT IDENTITY(1,1) PRIMARY KEY,
    VariantId            INT           NOT NULL,
    StoreId              INT           NOT NULL,
    QuantityOnHand       INT           NOT NULL CONSTRAINT DF_InventoryStocks_QuantityOnHand DEFAULT 0,
    QuantityReserved     INT           NOT NULL CONSTRAINT DF_InventoryStocks_QuantityReserved DEFAULT 0,
    ReorderLevel         INT           NOT NULL CONSTRAINT DF_InventoryStocks_ReorderLevel DEFAULT 0,
    UpdatedAt            DATETIME2(0)  NOT NULL CONSTRAINT DF_InventoryStocks_UpdatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_InventoryStocks_ProductVariants FOREIGN KEY (VariantId) REFERENCES dbo.ProductVariants(VariantId),
    CONSTRAINT FK_InventoryStocks_StoreBranches FOREIGN KEY (StoreId) REFERENCES dbo.StoreBranches(StoreId),
    CONSTRAINT UQ_InventoryStocks_Variant_Store UNIQUE (VariantId, StoreId),
    CONSTRAINT CK_InventoryStocks_Qty CHECK (QuantityOnHand >= 0 AND QuantityReserved >= 0)
);
GO

IF OBJECT_ID(N'dbo.WarrantyPackages', N'U') IS NOT NULL DROP TABLE dbo.WarrantyPackages;
CREATE TABLE dbo.WarrantyPackages
(
    WarrantyPackageId    INT IDENTITY(1,1) PRIMARY KEY,
    PackageName          NVARCHAR(150)  NOT NULL,
    DurationMonths       INT            NOT NULL,
    PackagePrice         DECIMAL(18,2)  NOT NULL,
    CoverageDescription  NVARCHAR(1000) NULL,
    IsActive             BIT            NOT NULL CONSTRAINT DF_WarrantyPackages_IsActive DEFAULT 1,
    CONSTRAINT CK_WarrantyPackages_Duration CHECK (DurationMonths > 0),
    CONSTRAINT CK_WarrantyPackages_Price CHECK (PackagePrice >= 0)
);
GO

IF OBJECT_ID(N'dbo.InstallmentProviders', N'U') IS NOT NULL DROP TABLE dbo.InstallmentProviders;
CREATE TABLE dbo.InstallmentProviders
(
    ProviderId           INT IDENTITY(1,1) PRIMARY KEY,
    ProviderCode         NVARCHAR(50)   NOT NULL UNIQUE,
    ProviderName         NVARCHAR(150)  NOT NULL,
    Description          NVARCHAR(500)  NULL,
    IsActive             BIT            NOT NULL CONSTRAINT DF_InstallmentProviders_IsActive DEFAULT 1
);
GO

IF OBJECT_ID(N'dbo.InstallmentPlans', N'U') IS NOT NULL DROP TABLE dbo.InstallmentPlans;
CREATE TABLE dbo.InstallmentPlans
(
    InstallmentPlanId    INT IDENTITY(1,1) PRIMARY KEY,
    ProviderId           INT            NOT NULL,
    ProductId            INT            NULL,
    VariantId            INT            NULL,
    TenureMonths         INT            NOT NULL,
    InterestRate         DECIMAL(5,2)   NOT NULL,
    DownPaymentPercent   DECIMAL(5,2)   NOT NULL,
    ProcessingFee        DECIMAL(18,2)  NOT NULL CONSTRAINT DF_InstallmentPlans_ProcessingFee DEFAULT 0,
    IsActive             BIT            NOT NULL CONSTRAINT DF_InstallmentPlans_IsActive DEFAULT 1,
    CONSTRAINT FK_InstallmentPlans_InstallmentProviders FOREIGN KEY (ProviderId) REFERENCES dbo.InstallmentProviders(ProviderId),
    CONSTRAINT FK_InstallmentPlans_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_InstallmentPlans_ProductVariants FOREIGN KEY (VariantId) REFERENCES dbo.ProductVariants(VariantId),
    CONSTRAINT CK_InstallmentPlans_Target CHECK (ProductId IS NOT NULL OR VariantId IS NOT NULL)
);
GO

/* ================================================================
   5. GIO HANG, WISHLIST, SO SANH
   ================================================================ */

IF OBJECT_ID(N'dbo.Carts', N'U') IS NOT NULL DROP TABLE dbo.Carts;
CREATE TABLE dbo.Carts
(
    CartId               INT IDENTITY(1,1) PRIMARY KEY,
    UserId               INT            NULL,
    SessionId            NVARCHAR(100)  NULL,
    Status               NVARCHAR(20)   NOT NULL CONSTRAINT DF_Carts_Status DEFAULT N'ACTIVE',
    CreatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_Carts_CreatedAt DEFAULT SYSDATETIME(),
    UpdatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_Carts_UpdatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Carts_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Carts_Status CHECK (Status IN (N'ACTIVE', N'CONVERTED', N'ABANDONED'))
);
GO

IF OBJECT_ID(N'dbo.CartItems', N'U') IS NOT NULL DROP TABLE dbo.CartItems;
CREATE TABLE dbo.CartItems
(
    CartItemId           INT IDENTITY(1,1) PRIMARY KEY,
    CartId               INT            NOT NULL,
    VariantId            INT            NOT NULL,
    Quantity             INT            NOT NULL,
    UnitPrice            DECIMAL(18,2)  NOT NULL,
    AddedAt              DATETIME2(0)   NOT NULL CONSTRAINT DF_CartItems_AddedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_CartItems_Carts FOREIGN KEY (CartId) REFERENCES dbo.Carts(CartId),
    CONSTRAINT FK_CartItems_ProductVariants FOREIGN KEY (VariantId) REFERENCES dbo.ProductVariants(VariantId),
    CONSTRAINT UQ_CartItems_Cart_Variant UNIQUE (CartId, VariantId),
    CONSTRAINT CK_CartItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_CartItems_UnitPrice CHECK (UnitPrice >= 0)
);
GO

IF OBJECT_ID(N'dbo.Wishlists', N'U') IS NOT NULL DROP TABLE dbo.Wishlists;
CREATE TABLE dbo.Wishlists
(
    WishlistId           INT IDENTITY(1,1) PRIMARY KEY,
    UserId               INT           NOT NULL UNIQUE,
    CreatedAt            DATETIME2(0)  NOT NULL CONSTRAINT DF_Wishlists_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Wishlists_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

IF OBJECT_ID(N'dbo.WishlistItems', N'U') IS NOT NULL DROP TABLE dbo.WishlistItems;
CREATE TABLE dbo.WishlistItems
(
    WishlistItemId       INT IDENTITY(1,1) PRIMARY KEY,
    WishlistId           INT           NOT NULL,
    ProductId            INT           NOT NULL,
    CreatedAt            DATETIME2(0)  NOT NULL CONSTRAINT DF_WishlistItems_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_WishlistItems_Wishlists FOREIGN KEY (WishlistId) REFERENCES dbo.Wishlists(WishlistId),
    CONSTRAINT FK_WishlistItems_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT UQ_WishlistItems_Wishlist_Product UNIQUE (WishlistId, ProductId)
);
GO

IF OBJECT_ID(N'dbo.CompareLists', N'U') IS NOT NULL DROP TABLE dbo.CompareLists;
CREATE TABLE dbo.CompareLists
(
    CompareListId        INT IDENTITY(1,1) PRIMARY KEY,
    UserId               INT            NULL,
    SessionId            NVARCHAR(100)  NULL,
    CreatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_CompareLists_CreatedAt DEFAULT SYSDATETIME(),
    UpdatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_CompareLists_UpdatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_CompareLists_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

IF OBJECT_ID(N'dbo.CompareItems', N'U') IS NOT NULL DROP TABLE dbo.CompareItems;
CREATE TABLE dbo.CompareItems
(
    CompareItemId        INT IDENTITY(1,1) PRIMARY KEY,
    CompareListId        INT           NOT NULL,
    ProductId            INT           NOT NULL,
    AddedAt              DATETIME2(0)  NOT NULL CONSTRAINT DF_CompareItems_AddedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_CompareItems_CompareLists FOREIGN KEY (CompareListId) REFERENCES dbo.CompareLists(CompareListId),
    CONSTRAINT FK_CompareItems_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT UQ_CompareItems_List_Product UNIQUE (CompareListId, ProductId)
);
GO

/* ================================================================
   6. KHUYEN MAI, VOUCHER, GIA
   ================================================================ */

IF OBJECT_ID(N'dbo.Promotions', N'U') IS NOT NULL DROP TABLE dbo.Promotions;
CREATE TABLE dbo.Promotions
(
    PromotionId          INT IDENTITY(1,1) PRIMARY KEY,
    PromotionCode        NVARCHAR(50)   NULL UNIQUE,
    PromotionName        NVARCHAR(200)  NOT NULL,
    PromotionType        NVARCHAR(20)   NOT NULL,
    DiscountValue        DECIMAL(18,2)  NOT NULL,
    MaxDiscountAmount    DECIMAL(18,2)  NULL,
    StartAt              DATETIME2(0)   NOT NULL,
    EndAt                DATETIME2(0)   NOT NULL,
    IsActive             BIT            NOT NULL CONSTRAINT DF_Promotions_IsActive DEFAULT 1,
    CreatedAt            DATETIME2(0)   NOT NULL CONSTRAINT DF_Promotions_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Promotions_PromotionType CHECK (PromotionType IN (N'PERCENT', N'AMOUNT', N'FLASHSALE')),
    CONSTRAINT CK_Promotions_DiscountValue CHECK (DiscountValue >= 0)
);
GO

IF OBJECT_ID(N'dbo.PromotionTargets', N'U') IS NOT NULL DROP TABLE dbo.PromotionTargets;
CREATE TABLE dbo.PromotionTargets
(
    PromotionTargetId    INT IDENTITY(1,1) PRIMARY KEY,
    PromotionId          INT NOT NULL,
    ProductId            INT NULL,
    VariantId            INT NULL,
    CategoryId           INT NULL,
    CONSTRAINT FK_PromotionTargets_Promotions FOREIGN KEY (PromotionId) REFERENCES dbo.Promotions(PromotionId),
    CONSTRAINT FK_PromotionTargets_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_PromotionTargets_ProductVariants FOREIGN KEY (VariantId) REFERENCES dbo.ProductVariants(VariantId),
    CONSTRAINT FK_PromotionTargets_Categories FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT CK_PromotionTargets_Target CHECK (
        ProductId IS NOT NULL OR VariantId IS NOT NULL OR CategoryId IS NOT NULL
    )
);
GO

IF OBJECT_ID(N'dbo.Coupons', N'U') IS NOT NULL DROP TABLE dbo.Coupons;
CREATE TABLE dbo.Coupons
(
    CouponId             INT IDENTITY(1,1) PRIMARY KEY,
    CouponCode           NVARCHAR(50)   NOT NULL UNIQUE,
    CouponName           NVARCHAR(150)  NOT NULL,
    DiscountType         NVARCHAR(20)   NOT NULL,
    DiscountValue        DECIMAL(18,2)  NOT NULL,
    MinOrderAmount       DECIMAL(18,2)  NOT NULL CONSTRAINT DF_Coupons_MinOrderAmount DEFAULT 0,
    MaxDiscountAmount    DECIMAL(18,2)  NULL,
    UsageLimit           INT            NULL,
    UsageLimitPerUser    INT            NULL,
    StartAt              DATETIME2(0)   NOT NULL,
    EndAt                DATETIME2(0)   NOT NULL,
    IsActive             BIT            NOT NULL CONSTRAINT DF_Coupons_IsActive DEFAULT 1,
    CONSTRAINT CK_Coupons_DiscountType CHECK (DiscountType IN (N'PERCENT', N'AMOUNT')),
    CONSTRAINT CK_Coupons_DiscountValue CHECK (DiscountValue >= 0)
);
GO

IF OBJECT_ID(N'dbo.CouponUsages', N'U') IS NOT NULL DROP TABLE dbo.CouponUsages;
CREATE TABLE dbo.CouponUsages
(
    CouponUsageId        INT IDENTITY(1,1) PRIMARY KEY,
    CouponId             INT           NOT NULL,
    UserId               INT           NULL,
    OrderId              INT           NULL,
    DiscountAmount       DECIMAL(18,2) NOT NULL,
    UsedAt               DATETIME2(0)  NOT NULL CONSTRAINT DF_CouponUsages_UsedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_CouponUsages_Coupons FOREIGN KEY (CouponId) REFERENCES dbo.Coupons(CouponId),
    CONSTRAINT FK_CouponUsages_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

/* ================================================================
   7. DON HANG, THANH TOAN, GIAO HANG
   ================================================================ */

IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
CREATE TABLE dbo.Orders
(
    OrderId               INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber           NVARCHAR(30)   NOT NULL UNIQUE,
    UserId                INT            NULL,
    CouponId              INT            NULL,
    PickupStoreId         INT            NULL,
    CustomerName          NVARCHAR(150)  NOT NULL,
    CustomerEmail         NVARCHAR(255)  NOT NULL,
    CustomerPhone         NVARCHAR(20)   NOT NULL,
    BillingReceiverName   NVARCHAR(150)  NOT NULL,
    BillingReceiverPhone  NVARCHAR(20)   NOT NULL,
    BillingProvince       NVARCHAR(100)  NOT NULL,
    BillingDistrict       NVARCHAR(100)  NOT NULL,
    BillingWard           NVARCHAR(100)  NULL,
    BillingAddressLine    NVARCHAR(255)  NOT NULL,
    ShippingReceiverName  NVARCHAR(150)  NOT NULL,
    ShippingReceiverPhone NVARCHAR(20)   NOT NULL,
    ShippingProvince      NVARCHAR(100)  NOT NULL,
    ShippingDistrict      NVARCHAR(100)  NOT NULL,
    ShippingWard          NVARCHAR(100)  NULL,
    ShippingAddressLine   NVARCHAR(255)  NOT NULL,
    FulfillmentMethod     NVARCHAR(20)   NOT NULL CONSTRAINT DF_Orders_FulfillmentMethod DEFAULT N'DELIVERY',
    OrderStatus           NVARCHAR(20)   NOT NULL CONSTRAINT DF_Orders_OrderStatus DEFAULT N'PENDING',
    PaymentStatus         NVARCHAR(20)   NOT NULL CONSTRAINT DF_Orders_PaymentStatus DEFAULT N'UNPAID',
    SubtotalAmount        DECIMAL(18,2)  NOT NULL,
    DiscountAmount        DECIMAL(18,2)  NOT NULL CONSTRAINT DF_Orders_DiscountAmount DEFAULT 0,
    ShippingFee           DECIMAL(18,2)  NOT NULL CONSTRAINT DF_Orders_ShippingFee DEFAULT 0,
    TaxAmount             DECIMAL(18,2)  NOT NULL CONSTRAINT DF_Orders_TaxAmount DEFAULT 0,
    GrandTotal            DECIMAL(18,2)  NOT NULL,
    CustomerNote          NVARCHAR(1000) NULL,
    CreatedAt             DATETIME2(0)   NOT NULL CONSTRAINT DF_Orders_CreatedAt DEFAULT SYSDATETIME(),
    ConfirmedAt           DATETIME2(0)   NULL,
    CompletedAt           DATETIME2(0)   NULL,
    CancelledAt           DATETIME2(0)   NULL,
    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_Orders_Coupons FOREIGN KEY (CouponId) REFERENCES dbo.Coupons(CouponId),
    CONSTRAINT FK_Orders_StoreBranches FOREIGN KEY (PickupStoreId) REFERENCES dbo.StoreBranches(StoreId),
    CONSTRAINT CK_Orders_FulfillmentMethod CHECK (FulfillmentMethod IN (N'DELIVERY', N'PICKUP')),
    CONSTRAINT CK_Orders_OrderStatus CHECK (OrderStatus IN (N'PENDING', N'CONFIRMED', N'PROCESSING', N'SHIPPING', N'COMPLETED', N'CANCELLED', N'RETURNED')),
    CONSTRAINT CK_Orders_PaymentStatus CHECK (PaymentStatus IN (N'UNPAID', N'PARTIAL', N'PAID', N'FAILED', N'REFUNDED'))
);
GO

IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NOT NULL DROP TABLE dbo.OrderItems;
CREATE TABLE dbo.OrderItems
(
    OrderItemId           INT IDENTITY(1,1) PRIMARY KEY,
    OrderId               INT            NOT NULL,
    ProductId             INT            NOT NULL,
    VariantId             INT            NOT NULL,
    ProductNameSnapshot   NVARCHAR(255)  NOT NULL,
    SKU                   NVARCHAR(100)  NOT NULL,
    VariantNameSnapshot   NVARCHAR(255)  NULL,
    ColorNameSnapshot     NVARCHAR(100)  NULL,
    Quantity              INT            NOT NULL,
    UnitPrice             DECIMAL(18,2)  NOT NULL,
    DiscountAmount        DECIMAL(18,2)  NOT NULL CONSTRAINT DF_OrderItems_DiscountAmount DEFAULT 0,
    LineTotal             DECIMAL(18,2)  NOT NULL,
    WarrantyPackageId     INT            NULL,
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_OrderItems_ProductVariants FOREIGN KEY (VariantId) REFERENCES dbo.ProductVariants(VariantId),
    CONSTRAINT FK_OrderItems_WarrantyPackages FOREIGN KEY (WarrantyPackageId) REFERENCES dbo.WarrantyPackages(WarrantyPackageId),
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0)
);
GO

IF OBJECT_ID(N'dbo.OrderStatusHistories', N'U') IS NOT NULL DROP TABLE dbo.OrderStatusHistories;
CREATE TABLE dbo.OrderStatusHistories
(
    OrderStatusHistoryId  INT IDENTITY(1,1) PRIMARY KEY,
    OrderId               INT            NOT NULL,
    OldStatus             NVARCHAR(20)   NULL,
    NewStatus             NVARCHAR(20)   NOT NULL,
    ChangedByUserId       INT            NULL,
    Note                  NVARCHAR(500)  NULL,
    ChangedAt             DATETIME2(0)   NOT NULL CONSTRAINT DF_OrderStatusHistories_ChangedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_OrderStatusHistories_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_OrderStatusHistories_Users FOREIGN KEY (ChangedByUserId) REFERENCES dbo.Users(UserId)
);
GO

IF OBJECT_ID(N'dbo.Payments', N'U') IS NOT NULL DROP TABLE dbo.Payments;
CREATE TABLE dbo.Payments
(
    PaymentId             INT IDENTITY(1,1) PRIMARY KEY,
    OrderId               INT            NOT NULL,
    PaymentMethod         NVARCHAR(30)   NOT NULL,
    ProviderCode          NVARCHAR(50)   NULL,
    ProviderTransactionId NVARCHAR(100)  NULL,
    Amount                DECIMAL(18,2)  NOT NULL,
    PaymentStatus         NVARCHAR(20)   NOT NULL CONSTRAINT DF_Payments_PaymentStatus DEFAULT N'PENDING',
    PaidAt                DATETIME2(0)   NULL,
    CreatedAt             DATETIME2(0)   NOT NULL CONSTRAINT DF_Payments_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT CK_Payments_Method CHECK (PaymentMethod IN (N'COD', N'BANK_TRANSFER', N'CARD', N'VNPAY', N'MOMO', N'INSTALLMENT')),
    CONSTRAINT CK_Payments_Status CHECK (PaymentStatus IN (N'PENDING', N'PAID', N'FAILED', N'REFUNDED'))
);
GO

IF OBJECT_ID(N'dbo.OrderInstallments', N'U') IS NOT NULL DROP TABLE dbo.OrderInstallments;
CREATE TABLE dbo.OrderInstallments
(
    OrderInstallmentId    INT IDENTITY(1,1) PRIMARY KEY,
    OrderId               INT            NOT NULL UNIQUE,
    InstallmentPlanId     INT            NOT NULL,
    ApprovedByProvider    BIT            NOT NULL CONSTRAINT DF_OrderInstallments_ApprovedByProvider DEFAULT 0,
    DownPaymentAmount     DECIMAL(18,2)  NOT NULL,
    MonthlyAmount         DECIMAL(18,2)  NOT NULL,
    TenureMonths          INT            NOT NULL,
    InterestRate          DECIMAL(5,2)   NOT NULL,
    ContractNumber        NVARCHAR(100)  NULL,
    CreatedAt             DATETIME2(0)   NOT NULL CONSTRAINT DF_OrderInstallments_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_OrderInstallments_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT FK_OrderInstallments_InstallmentPlans FOREIGN KEY (InstallmentPlanId) REFERENCES dbo.InstallmentPlans(InstallmentPlanId)
);
GO

IF OBJECT_ID(N'dbo.Shipments', N'U') IS NOT NULL DROP TABLE dbo.Shipments;
CREATE TABLE dbo.Shipments
(
    ShipmentId            INT IDENTITY(1,1) PRIMARY KEY,
    OrderId               INT            NOT NULL,
    CarrierName           NVARCHAR(100)  NULL,
    ServiceName           NVARCHAR(100)  NULL,
    TrackingNumber        NVARCHAR(100)  NULL,
    ShipmentStatus        NVARCHAR(20)   NOT NULL CONSTRAINT DF_Shipments_ShipmentStatus DEFAULT N'PENDING',
    ShippingFee           DECIMAL(18,2)  NOT NULL CONSTRAINT DF_Shipments_ShippingFee DEFAULT 0,
    ShippedAt             DATETIME2(0)   NULL,
    DeliveredAt           DATETIME2(0)   NULL,
    CreatedAt             DATETIME2(0)   NOT NULL CONSTRAINT DF_Shipments_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Shipments_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId),
    CONSTRAINT CK_Shipments_Status CHECK (ShipmentStatus IN (N'PENDING', N'PACKING', N'SHIPPING', N'DELIVERED', N'FAILED', N'RETURNED'))
);
GO

ALTER TABLE dbo.CouponUsages
ADD CONSTRAINT FK_CouponUsages_Orders
FOREIGN KEY (OrderId) REFERENCES dbo.Orders(OrderId);
GO

/* ================================================================
   8. REVIEW, CONTACT, NEWSLETTER
   ================================================================ */

IF OBJECT_ID(N'dbo.ProductReviews', N'U') IS NOT NULL DROP TABLE dbo.ProductReviews;
CREATE TABLE dbo.ProductReviews
(
    ReviewId              INT IDENTITY(1,1) PRIMARY KEY,
    ProductId             INT             NOT NULL,
    UserId                INT             NOT NULL,
    OrderItemId           INT             NULL,
    Rating                TINYINT         NOT NULL,
    ReviewTitle           NVARCHAR(200)   NULL,
    ReviewContent         NVARCHAR(2000)  NULL,
    IsVerifiedPurchase    BIT             NOT NULL CONSTRAINT DF_ProductReviews_IsVerifiedPurchase DEFAULT 0,
    ReviewStatus          NVARCHAR(20)    NOT NULL CONSTRAINT DF_ProductReviews_ReviewStatus DEFAULT N'PENDING',
    CreatedAt             DATETIME2(0)    NOT NULL CONSTRAINT DF_ProductReviews_CreatedAt DEFAULT SYSDATETIME(),
    ApprovedAt            DATETIME2(0)    NULL,
    CONSTRAINT FK_ProductReviews_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId),
    CONSTRAINT FK_ProductReviews_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT FK_ProductReviews_OrderItems FOREIGN KEY (OrderItemId) REFERENCES dbo.OrderItems(OrderItemId),
    CONSTRAINT CK_ProductReviews_Rating CHECK (Rating BETWEEN 1 AND 5),
    CONSTRAINT CK_ProductReviews_ReviewStatus CHECK (ReviewStatus IN (N'PENDING', N'APPROVED', N'REJECTED'))
);
GO

IF OBJECT_ID(N'dbo.ContactMessages', N'U') IS NOT NULL DROP TABLE dbo.ContactMessages;
CREATE TABLE dbo.ContactMessages
(
    ContactMessageId      INT IDENTITY(1,1) PRIMARY KEY,
    FullName              NVARCHAR(150)  NOT NULL,
    PhoneNumber           NVARCHAR(20)   NULL,
    Email                 NVARCHAR(255)  NOT NULL,
    Subject               NVARCHAR(200)  NULL,
    MessageBody           NVARCHAR(MAX)  NOT NULL,
    Status                NVARCHAR(20)   NOT NULL CONSTRAINT DF_ContactMessages_Status DEFAULT N'NEW',
    AssignedToUserId      INT            NULL,
    CreatedAt             DATETIME2(0)   NOT NULL CONSTRAINT DF_ContactMessages_CreatedAt DEFAULT SYSDATETIME(),
    RespondedAt           DATETIME2(0)   NULL,
    CONSTRAINT FK_ContactMessages_Users FOREIGN KEY (AssignedToUserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_ContactMessages_Status CHECK (Status IN (N'NEW', N'IN_PROGRESS', N'CLOSED'))
);
GO

IF OBJECT_ID(N'dbo.NewsletterSubscriptions', N'U') IS NOT NULL DROP TABLE dbo.NewsletterSubscriptions;
CREATE TABLE dbo.NewsletterSubscriptions
(
    SubscriptionId        INT IDENTITY(1,1) PRIMARY KEY,
    Email                 NVARCHAR(255) NOT NULL UNIQUE,
    UserId                INT           NULL,
    IsActive              BIT           NOT NULL CONSTRAINT DF_NewsletterSubscriptions_IsActive DEFAULT 1,
    SubscribedAt          DATETIME2(0)  NOT NULL CONSTRAINT DF_NewsletterSubscriptions_SubscribedAt DEFAULT SYSDATETIME(),
    UnsubscribedAt        DATETIME2(0)  NULL,
    CONSTRAINT FK_NewsletterSubscriptions_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId)
);
GO

/* ================================================================
   9. BLOG / BANNER / NOI DUNG
   ================================================================ */

IF OBJECT_ID(N'dbo.BannerSliders', N'U') IS NOT NULL DROP TABLE dbo.BannerSliders;
CREATE TABLE dbo.BannerSliders
(
    BannerId              INT IDENTITY(1,1) PRIMARY KEY,
    BannerTitle           NVARCHAR(255)  NOT NULL,
    BannerSubtitle        NVARCHAR(500)  NULL,
    ImageUrl              NVARCHAR(500)  NOT NULL,
    MobileImageUrl        NVARCHAR(500)  NULL,
    LinkUrl               NVARCHAR(500)  NULL,
    LinkText              NVARCHAR(100)  NULL,
    DisplayOrder          INT            NOT NULL CONSTRAINT DF_BannerSliders_DisplayOrder DEFAULT 0,
    IsActive              BIT            NOT NULL CONSTRAINT DF_BannerSliders_IsActive DEFAULT 1,
    StartAt               DATETIME2(0)   NULL,
    EndAt                 DATETIME2(0)   NULL,
    CreatedAt             DATETIME2(0)   NOT NULL CONSTRAINT DF_BannerSliders_CreatedAt DEFAULT SYSDATETIME()
);
GO

IF OBJECT_ID(N'dbo.BlogPosts', N'U') IS NOT NULL DROP TABLE dbo.BlogPosts;
CREATE TABLE dbo.BlogPosts
(
    BlogPostId            INT IDENTITY(1,1) PRIMARY KEY,
    AuthorUserId          INT            NULL,
    Title                 NVARCHAR(255)  NOT NULL,
    Slug                  NVARCHAR(300)  NOT NULL UNIQUE,
    Summary               NVARCHAR(500)  NULL,
    ContentBody           NVARCHAR(MAX)  NOT NULL,
    ThumbnailUrl          NVARCHAR(500)  NULL,
    SeoTitle              NVARCHAR(255)  NULL,
    SeoDescription        NVARCHAR(500)  NULL,
    ViewCount             INT            NOT NULL CONSTRAINT DF_BlogPosts_ViewCount DEFAULT 0,
    PublishedAt           DATETIME2(0)   NULL,
    IsPublished           BIT            NOT NULL CONSTRAINT DF_BlogPosts_IsPublished DEFAULT 0,
    CreatedAt             DATETIME2(0)   NOT NULL CONSTRAINT DF_BlogPosts_CreatedAt DEFAULT SYSDATETIME(),
    UpdatedAt             DATETIME2(0)   NOT NULL CONSTRAINT DF_BlogPosts_UpdatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT FK_BlogPosts_Users FOREIGN KEY (AuthorUserId) REFERENCES dbo.Users(UserId)
);
GO

/* ================================================================
   10. INDEXES
   ================================================================ */

CREATE INDEX IX_Products_CategoryId ON dbo.Products(CategoryId);
CREATE INDEX IX_Products_BrandId ON dbo.Products(BrandId);
CREATE INDEX IX_Products_ProductType_IsActive ON dbo.Products(ProductType, IsActive);

CREATE INDEX IX_ProductVariants_ProductId ON dbo.ProductVariants(ProductId);
CREATE INDEX IX_ProductVariants_ProductId_IsDefault ON dbo.ProductVariants(ProductId, IsDefault);
CREATE INDEX IX_ProductVariants_SalePrice ON dbo.ProductVariants(SalePrice);

CREATE INDEX IX_ProductImages_ProductId_DisplayOrder ON dbo.ProductImages(ProductId, DisplayOrder);
CREATE INDEX IX_InventoryStocks_StoreId ON dbo.InventoryStocks(StoreId);
CREATE INDEX IX_CartItems_VariantId ON dbo.CartItems(VariantId);
CREATE INDEX IX_WishlistItems_ProductId ON dbo.WishlistItems(ProductId);
CREATE INDEX IX_CompareItems_ProductId ON dbo.CompareItems(ProductId);
CREATE INDEX IX_Orders_UserId ON dbo.Orders(UserId);
CREATE INDEX IX_Orders_OrderStatus_PaymentStatus ON dbo.Orders(OrderStatus, PaymentStatus);
CREATE INDEX IX_OrderItems_OrderId ON dbo.OrderItems(OrderId);
CREATE INDEX IX_OrderItems_ProductId ON dbo.OrderItems(ProductId);
CREATE INDEX IX_Payments_OrderId ON dbo.Payments(OrderId);
CREATE INDEX IX_Shipments_OrderId ON dbo.Shipments(OrderId);
CREATE INDEX IX_ProductReviews_ProductId_ReviewStatus ON dbo.ProductReviews(ProductId, ReviewStatus);
CREATE INDEX IX_BlogPosts_IsPublished_PublishedAt ON dbo.BlogPosts(IsPublished, PublishedAt);
GO

/* ================================================================
   11. SEED DU LIEU TOI THIEU
   ================================================================ */

INSERT INTO dbo.Roles (RoleCode, RoleName)
VALUES
    (N'ADMIN',    N'Quan tri he thong'),
    (N'STAFF',    N'Nhan vien ban hang'),
    (N'CUSTOMER', N'Khach hang');
GO

INSERT INTO dbo.Categories (ParentCategoryId, CategoryName, Slug, Description, DisplayOrder, IsActive)
VALUES
    (NULL, N'Laptop', N'laptop', N'Danh muc laptop', 1, 1),
    (NULL, N'Dien thoai', N'dien-thoai', N'Danh muc dien thoai', 2, 1);
GO

INSERT INTO dbo.Categories (ParentCategoryId, CategoryName, Slug, Description, DisplayOrder, IsActive)
SELECT c.CategoryId, N'Laptop gaming', N'laptop-gaming', N'Laptop choi game', 11, 1
FROM dbo.Categories c
WHERE c.Slug = N'laptop';
GO

INSERT INTO dbo.Categories (ParentCategoryId, CategoryName, Slug, Description, DisplayOrder, IsActive)
SELECT c.CategoryId, N'Laptop van phong', N'laptop-van-phong', N'Laptop hoc tap va lam viec', 12, 1
FROM dbo.Categories c
WHERE c.Slug = N'laptop';
GO

INSERT INTO dbo.Categories (ParentCategoryId, CategoryName, Slug, Description, DisplayOrder, IsActive)
SELECT c.CategoryId, N'iPhone', N'iphone', N'Dien thoai Apple iPhone', 21, 1
FROM dbo.Categories c
WHERE c.Slug = N'dien-thoai';
GO

INSERT INTO dbo.Categories (ParentCategoryId, CategoryName, Slug, Description, DisplayOrder, IsActive)
SELECT c.CategoryId, N'Android', N'android', N'Dien thoai Android', 22, 1
FROM dbo.Categories c
WHERE c.Slug = N'dien-thoai';
GO

INSERT INTO dbo.Brands (BrandName, Slug, CountryOfOrigin, IsActive)
VALUES
    (N'Apple',   N'apple',   N'USA', 1),
    (N'Samsung', N'samsung', N'Korea', 1),
    (N'Xiaomi',  N'xiaomi',  N'China', 1),
    (N'Dell',    N'dell',    N'USA', 1),
    (N'HP',      N'hp',      N'USA', 1),
    (N'ASUS',    N'asus',    N'Taiwan', 1),
    (N'Acer',    N'acer',    N'Taiwan', 1),
    (N'Lenovo',  N'lenovo',  N'China', 1);
GO

INSERT INTO dbo.Colors (ColorName, ColorCode, SortOrder)
VALUES
    (N'Den', N'#000000', 1),
    (N'Trang', N'#FFFFFF', 2),
    (N'Xam', N'#808080', 3),
    (N'Xanh duong', N'#1D4ED8', 4),
    (N'Hong', N'#EC4899', 5);
GO

/* ================================================================
   12. SAMPLE DATA CHI TIET
   ================================================================ */

INSERT INTO dbo.Users
(
    Email, PhoneNumber, PasswordHash, FullName, DateOfBirth, Gender,
    Status, EmailConfirmed, PhoneConfirmed, ReceivePartnerOffers, IsNewsletterSubscribed
)
VALUES
    (N'admin@lapstore.vn', N'0900000001', N'HASH_ADMIN_123', N'Quan Tri Vien', '1995-05-10', N'MALE', N'ACTIVE', 1, 1, 0, 1),
    (N'staff@lapstore.vn', N'0900000002', N'HASH_STAFF_123', N'Nhan Vien Ban Hang', '1998-08-20', N'FEMALE', N'ACTIVE', 1, 1, 0, 1),
    (N'nguyenvana@gmail.com', N'0912345678', N'HASH_USER_A_123', N'Nguyen Van A', '2001-03-15', N'MALE', N'ACTIVE', 1, 1, 1, 1),
    (N'tranthib@gmail.com', N'0987654321', N'HASH_USER_B_123', N'Tran Thi B', '2000-11-01', N'FEMALE', N'ACTIVE', 1, 1, 1, 0);
GO

INSERT INTO dbo.UserRoles (UserId, RoleId)
SELECT u.UserId, r.RoleId
FROM dbo.Users u
JOIN dbo.Roles r ON
    (u.Email = N'admin@lapstore.vn' AND r.RoleCode = N'ADMIN')
    OR (u.Email = N'staff@lapstore.vn' AND r.RoleCode = N'STAFF')
    OR (u.Email IN (N'nguyenvana@gmail.com', N'tranthib@gmail.com') AND r.RoleCode = N'CUSTOMER');
GO

INSERT INTO dbo.UserAddresses
(
    UserId, AddressType, ReceiverName, ReceiverPhone, ProvinceName, DistrictName,
    WardName, AddressLine, PostalCode, IsDefaultBilling, IsDefaultShipping
)
SELECT u.UserId, N'SHIPPING', N'Nguyen Van A', N'0912345678', N'TP Ho Chi Minh', N'Quan 10',
       N'Phuong 12', N'120 Su Van Hanh', N'700000', 1, 1
FROM dbo.Users u
WHERE u.Email = N'nguyenvana@gmail.com'
UNION ALL
SELECT u.UserId, N'SHIPPING', N'Tran Thi B', N'0987654321', N'Ha Noi', N'Cau Giay',
       N'Dich Vong', N'88 Tran Thai Tong', N'100000', 1, 1
FROM dbo.Users u
WHERE u.Email = N'tranthib@gmail.com';
GO

INSERT INTO dbo.StoreBranches
(StoreCode, StoreName, ProvinceName, DistrictName, WardName, AddressLine, PhoneNumber, Email, OpeningHours)
VALUES
    (N'HCM_Q10', N'Chi nhanh TP.HCM Quan 10', N'TP Ho Chi Minh', N'Quan 10', N'Phuong 12', N'120 Su Van Hanh', N'02873001234', N'q10@lapstore.vn', N'08:00 - 22:00'),
    (N'HN_CG', N'Chi nhanh Ha Noi Cau Giay', N'Ha Noi', N'Cau Giay', N'Dich Vong', N'88 Tran Thai Tong', N'02473001234', N'caugiay@lapstore.vn', N'08:00 - 22:00'),
    (N'DN_HC', N'Chi nhanh Da Nang Hai Chau', N'Da Nang', N'Hai Chau', N'Hoa Cuong', N'15 Nguyen Van Linh', N'02367300123', N'danang@lapstore.vn', N'08:00 - 22:00');
GO

INSERT INTO dbo.Products
(CategoryId, BrandId, ProductType, ProductName, Slug, ModelCode, ShortDescription, FullDescription, WarrantyMonths, ReleaseYear, SeoTitle, SeoDescription, IsFeatured, IsNew, IsActive)
SELECT c.CategoryId, b.BrandId, N'LAPTOP', N'Dell Inspiron 15 3530', N'dell-inspiron-15-3530', N'DELL-3530',
       N'Laptop van phong 15.6 inch, Intel Core i5, RAM 16GB, SSD 512GB',
       N'Mau laptop van phong phu hop hoc tap, lam viec va giai tri co ban.',
       24, 2025, N'Dell Inspiron 15 3530', N'Laptop Dell van phong gia tot', 1, 1, 1
FROM dbo.Categories c CROSS JOIN dbo.Brands b
WHERE c.Slug = N'laptop-van-phong' AND b.Slug = N'dell'
UNION ALL
SELECT c.CategoryId, b.BrandId, N'LAPTOP', N'ASUS TUF Gaming F15', N'asus-tuf-gaming-f15', N'ASUS-F15',
       N'Laptop gaming RTX 4050, man hinh 144Hz',
       N'Mau laptop gaming tam trung voi tan nhiet tot, phu hop choi game va do hoa.',
       24, 2025, N'ASUS TUF Gaming F15', N'Laptop gaming ASUS TUF F15', 1, 1, 1
FROM dbo.Categories c CROSS JOIN dbo.Brands b
WHERE c.Slug = N'laptop-gaming' AND b.Slug = N'asus'
UNION ALL
SELECT c.CategoryId, b.BrandId, N'PHONE', N'iPhone 15 128GB', N'iphone-15-128gb', N'IP15-128',
       N'iPhone 15 chinh hang, Dynamic Island, camera 48MP',
       N'Dien thoai cao cap cua Apple voi thiet ke hien dai va hieu nang manh.',
       12, 2025, N'iPhone 15 128GB', N'iPhone 15 chinh hang gia tot', 1, 1, 1
FROM dbo.Categories c CROSS JOIN dbo.Brands b
WHERE c.Slug = N'iphone' AND b.Slug = N'apple'
UNION ALL
SELECT c.CategoryId, b.BrandId, N'PHONE', N'Samsung Galaxy S24 256GB', N'samsung-galaxy-s24-256gb', N'S24-256',
       N'Flagship Android nho gon, man hinh AMOLED 120Hz',
       N'Dien thoai Samsung cao cap, chip manh, camera dep, pin ben.',
       12, 2025, N'Samsung Galaxy S24 256GB', N'Galaxy S24 chinh hang gia tot', 1, 1, 1
FROM dbo.Categories c CROSS JOIN dbo.Brands b
WHERE c.Slug = N'android' AND b.Slug = N'samsung';
GO

INSERT INTO dbo.ProductVariants
(ProductId, ColorId, VariantName, SKU, StorageGB, RamGB, SSDGB, CpuName, GpuName, ScreenSizeInch, OriginalPrice, SalePrice, WeightGram, StockStatus, IsDefault, IsActive)
SELECT p.ProductId, c.ColorId, N'Dell Inspiron 15 3530 - Den - 16GB/512GB', N'DELL3530-BLK-16-512', NULL, 16, 512, N'Intel Core i5-1334U', N'Intel Iris Xe', 15.6, 18990000, 17490000, 1650, N'IN_STOCK', 1, 1
FROM dbo.Products p CROSS JOIN dbo.Colors c
WHERE p.Slug = N'dell-inspiron-15-3530' AND c.ColorName = N'Den'
UNION ALL
SELECT p.ProductId, c.ColorId, N'Dell Inspiron 15 3530 - Xam - 8GB/512GB', N'DELL3530-GRY-8-512', NULL, 8, 512, N'Intel Core i5-1334U', N'Intel Iris Xe', 15.6, 17990000, 16990000, 1650, N'IN_STOCK', 0, 1
FROM dbo.Products p CROSS JOIN dbo.Colors c
WHERE p.Slug = N'dell-inspiron-15-3530' AND c.ColorName = N'Xam'
UNION ALL
SELECT p.ProductId, c.ColorId, N'ASUS TUF Gaming F15 - Den - 16GB/512GB', N'ASUSF15-BLK-16-512', NULL, 16, 512, N'Intel Core i7-13620H', N'NVIDIA RTX 4050', 15.6, 28990000, 26990000, 2200, N'IN_STOCK', 1, 1
FROM dbo.Products p CROSS JOIN dbo.Colors c
WHERE p.Slug = N'asus-tuf-gaming-f15' AND c.ColorName = N'Den'
UNION ALL
SELECT p.ProductId, c.ColorId, N'iPhone 15 - Hong - 128GB', N'IP15-PINK-128', 128, 6, NULL, N'Apple A16 Bionic', NULL, 6.1, 22990000, 21990000, 171, N'IN_STOCK', 1, 1
FROM dbo.Products p CROSS JOIN dbo.Colors c
WHERE p.Slug = N'iphone-15-128gb' AND c.ColorName = N'Hong'
UNION ALL
SELECT p.ProductId, c.ColorId, N'iPhone 15 - Den - 128GB', N'IP15-BLK-128', 128, 6, NULL, N'Apple A16 Bionic', NULL, 6.1, 22990000, 21990000, 171, N'IN_STOCK', 0, 1
FROM dbo.Products p CROSS JOIN dbo.Colors c
WHERE p.Slug = N'iphone-15-128gb' AND c.ColorName = N'Den'
UNION ALL
SELECT p.ProductId, c.ColorId, N'Galaxy S24 - Xam - 256GB', N'S24-GRY-256', 256, 8, NULL, N'Exynos 2400', NULL, 6.2, 22990000, 20990000, 168, N'IN_STOCK', 1, 1
FROM dbo.Products p CROSS JOIN dbo.Colors c
WHERE p.Slug = N'samsung-galaxy-s24-256gb' AND c.ColorName = N'Xam'
UNION ALL
SELECT p.ProductId, c.ColorId, N'Galaxy S24 - Xanh duong - 256GB', N'S24-BLUE-256', 256, 8, NULL, N'Exynos 2400', NULL, 6.2, 22990000, 20990000, 168, N'LOW_STOCK', 0, 1
FROM dbo.Products p CROSS JOIN dbo.Colors c
WHERE p.Slug = N'samsung-galaxy-s24-256gb' AND c.ColorName = N'Xanh duong';
GO

INSERT INTO dbo.ProductImages (ProductId, ImageUrl, AltText, IsPrimary, DisplayOrder)
SELECT p.ProductId, N'~/assets/img/product/product-1.jpg', p.ProductName, 1, 1 FROM dbo.Products p WHERE p.Slug = N'dell-inspiron-15-3530'
UNION ALL
SELECT p.ProductId, N'~/assets/img/product/product-2.jpg', p.ProductName, 0, 2 FROM dbo.Products p WHERE p.Slug = N'dell-inspiron-15-3530'
UNION ALL
SELECT p.ProductId, N'~/assets/img/product/product-5.jpg', p.ProductName, 1, 1 FROM dbo.Products p WHERE p.Slug = N'asus-tuf-gaming-f15'
UNION ALL
SELECT p.ProductId, N'~/assets/img/product/product-6.jpg', p.ProductName, 0, 2 FROM dbo.Products p WHERE p.Slug = N'asus-tuf-gaming-f15'
UNION ALL
SELECT p.ProductId, N'~/assets/img/product/product-9.jpg', p.ProductName, 1, 1 FROM dbo.Products p WHERE p.Slug = N'iphone-15-128gb'
UNION ALL
SELECT p.ProductId, N'~/assets/img/product/product-10.jpg', p.ProductName, 0, 2 FROM dbo.Products p WHERE p.Slug = N'iphone-15-128gb'
UNION ALL
SELECT p.ProductId, N'~/assets/img/product/product-11.jpg', p.ProductName, 1, 1 FROM dbo.Products p WHERE p.Slug = N'samsung-galaxy-s24-256gb'
UNION ALL
SELECT p.ProductId, N'~/assets/img/product/product-12.jpg', p.ProductName, 0, 2 FROM dbo.Products p WHERE p.Slug = N'samsung-galaxy-s24-256gb';
GO

INSERT INTO dbo.ProductFeatureBullets (ProductId, Title, FeatureValue, DisplayOrder)
SELECT p.ProductId, N'CPU', N'Intel Core i5-1334U', 1 FROM dbo.Products p WHERE p.Slug = N'dell-inspiron-15-3530'
UNION ALL
SELECT p.ProductId, N'RAM', N'16GB DDR4', 2 FROM dbo.Products p WHERE p.Slug = N'dell-inspiron-15-3530'
UNION ALL
SELECT p.ProductId, N'SSD', N'512GB NVMe', 3 FROM dbo.Products p WHERE p.Slug = N'dell-inspiron-15-3530'
UNION ALL
SELECT p.ProductId, N'GPU', N'RTX 4050', 1 FROM dbo.Products p WHERE p.Slug = N'asus-tuf-gaming-f15'
UNION ALL
SELECT p.ProductId, N'Screen', N'15.6 inch 144Hz', 2 FROM dbo.Products p WHERE p.Slug = N'asus-tuf-gaming-f15'
UNION ALL
SELECT p.ProductId, N'Camera', N'48MP', 1 FROM dbo.Products p WHERE p.Slug = N'iphone-15-128gb'
UNION ALL
SELECT p.ProductId, N'Chip', N'Apple A16 Bionic', 2 FROM dbo.Products p WHERE p.Slug = N'iphone-15-128gb'
UNION ALL
SELECT p.ProductId, N'Man hinh', N'AMOLED 120Hz', 1 FROM dbo.Products p WHERE p.Slug = N'samsung-galaxy-s24-256gb';
GO

INSERT INTO dbo.LaptopSpecifications
(ProductId, CpuSeries, CpuGeneration, GpuSeries, RamType, RamBusMHz, RamMaxGB, StorageType, AdditionalSlot, ScreenResolution, ScreenTechnology, RefreshRateHz, BatteryInfo, WebcamInfo, KeyboardInfo, WirelessConnectivity, Ports, OperatingSystem, WeightKg, Material)
SELECT p.ProductId, N'Intel Core i5', N'Gen 13', N'Intel Iris Xe', N'DDR4', 3200, 32, N'NVMe SSD', N'1 khe M.2',
       N'1920x1080', N'IPS', 60, N'3-cell 41Wh', N'HD Webcam', N'Ban phim fullsize', N'Wi-Fi 6, Bluetooth 5.2',
       N'USB-A, USB-C, HDMI, Audio Jack', N'Windows 11', 1.65, N'Nhua cao cap'
FROM dbo.Products p
WHERE p.Slug = N'dell-inspiron-15-3530'
UNION ALL
SELECT p.ProductId, N'Intel Core i7', N'Gen 13', N'NVIDIA RTX 4050', N'DDR5', 4800, 64, N'NVMe SSD', N'2 khe M.2',
       N'1920x1080', N'IPS', 144, N'4-cell 90Wh', N'HD Webcam', N'RGB Keyboard', N'Wi-Fi 6, Bluetooth 5.3',
       N'USB-A, USB-C, HDMI, LAN, Audio Jack', N'Windows 11', 2.20, N'Kim loai + nhua'
FROM dbo.Products p
WHERE p.Slug = N'asus-tuf-gaming-f15';
GO

INSERT INTO dbo.PhoneSpecifications
(ProductId, ScreenTechnology, ScreenResolution, RefreshRateHz, RearCameraInfo, FrontCameraInfo, Chipset, BatteryMah, ChargingWatt, SimInfo, OperatingSystem, WaterResistance, SecurityFeatures, Connectivity, NfcSupported, FiveGSupported)
SELECT p.ProductId, N'Super Retina XDR OLED', N'2556x1179', 60, N'48MP + 12MP', N'12MP', N'Apple A16 Bionic', 3349, 20,
       N'1 Nano SIM + eSIM', N'iOS 18', N'IP68', N'Face ID', N'5G, Wi-Fi 6, Bluetooth 5.3', 1, 1
FROM dbo.Products p
WHERE p.Slug = N'iphone-15-128gb'
UNION ALL
SELECT p.ProductId, N'Dynamic AMOLED 2X', N'2340x1080', 120, N'50MP + 12MP + 10MP', N'12MP', N'Exynos 2400', 4000, 25,
       N'2 Nano SIM + eSIM', N'Android 15', N'IP68', N'Van tay + khuon mat', N'5G, Wi-Fi 6E, Bluetooth 5.3', 1, 1
FROM dbo.Products p
WHERE p.Slug = N'samsung-galaxy-s24-256gb';
GO

INSERT INTO dbo.ProductTags (TagName, Slug)
VALUES
    (N'Laptop van phong', N'laptop-van-phong-tag'),
    (N'Laptop gaming', N'laptop-gaming-tag'),
    (N'iPhone', N'iphone-tag'),
    (N'Android flagship', N'android-flagship-tag'),
    (N'Tra gop 0%', N'tra-gop-0');
GO

INSERT INTO dbo.ProductTagMappings (ProductId, TagId)
SELECT p.ProductId, t.TagId FROM dbo.Products p JOIN dbo.ProductTags t ON p.Slug = N'dell-inspiron-15-3530' AND t.Slug IN (N'laptop-van-phong-tag', N'tra-gop-0')
UNION ALL
SELECT p.ProductId, t.TagId FROM dbo.Products p JOIN dbo.ProductTags t ON p.Slug = N'asus-tuf-gaming-f15' AND t.Slug IN (N'laptop-gaming-tag', N'tra-gop-0')
UNION ALL
SELECT p.ProductId, t.TagId FROM dbo.Products p JOIN dbo.ProductTags t ON p.Slug = N'iphone-15-128gb' AND t.Slug IN (N'iphone-tag', N'tra-gop-0')
UNION ALL
SELECT p.ProductId, t.TagId FROM dbo.Products p JOIN dbo.ProductTags t ON p.Slug = N'samsung-galaxy-s24-256gb' AND t.Slug IN (N'android-flagship-tag', N'tra-gop-0');
GO

INSERT INTO dbo.ProductRelations (ProductId, RelatedProductId, RelationType, DisplayOrder)
SELECT p1.ProductId, p2.ProductId, N'RELATED', 1
FROM dbo.Products p1 CROSS JOIN dbo.Products p2
WHERE p1.Slug = N'iphone-15-128gb' AND p2.Slug = N'samsung-galaxy-s24-256gb'
UNION ALL
SELECT p1.ProductId, p2.ProductId, N'RELATED', 1
FROM dbo.Products p1 CROSS JOIN dbo.Products p2
WHERE p1.Slug = N'dell-inspiron-15-3530' AND p2.Slug = N'asus-tuf-gaming-f15';
GO

INSERT INTO dbo.InventoryStocks (VariantId, StoreId, QuantityOnHand, QuantityReserved, ReorderLevel)
SELECT v.VariantId, s.StoreId,
       CASE WHEN s.StoreCode = N'HCM_Q10' THEN 12 WHEN s.StoreCode = N'HN_CG' THEN 8 ELSE 5 END,
       CASE WHEN s.StoreCode = N'HCM_Q10' THEN 2 ELSE 1 END,
       3
FROM dbo.ProductVariants v
JOIN dbo.StoreBranches s ON s.StoreCode IN (N'HCM_Q10', N'HN_CG', N'DN_HC');
GO

INSERT INTO dbo.WarrantyPackages (PackageName, DurationMonths, PackagePrice, CoverageDescription)
VALUES
    (N'Goi bao hanh mo rong 12 thang', 12, 990000, N'Bao hanh mo rong them 12 thang'),
    (N'Goi roi vo man hinh 12 thang', 12, 1490000, N'Bao ve roi vo man hinh cho dien thoai');
GO

INSERT INTO dbo.InstallmentProviders (ProviderCode, ProviderName, Description)
VALUES
    (N'HOMECREDIT', N'Home Credit', N'Don vi ho tro tra gop'),
    (N'FECREDIT', N'FE Credit', N'Don vi ho tro tra gop');
GO

INSERT INTO dbo.InstallmentPlans (ProviderId, ProductId, VariantId, TenureMonths, InterestRate, DownPaymentPercent, ProcessingFee, IsActive)
SELECT ip.ProviderId, p.ProductId, NULL, 6, 0, 20, 0, 1
FROM dbo.InstallmentProviders ip CROSS JOIN dbo.Products p
WHERE ip.ProviderCode = N'HOMECREDIT' AND p.Slug IN (N'dell-inspiron-15-3530', N'iphone-15-128gb')
UNION ALL
SELECT ip.ProviderId, p.ProductId, NULL, 12, 1.5, 20, 250000, 1
FROM dbo.InstallmentProviders ip CROSS JOIN dbo.Products p
WHERE ip.ProviderCode = N'FECREDIT' AND p.Slug IN (N'asus-tuf-gaming-f15', N'samsung-galaxy-s24-256gb');
GO

INSERT INTO dbo.Promotions (PromotionCode, PromotionName, PromotionType, DiscountValue, MaxDiscountAmount, StartAt, EndAt, IsActive)
VALUES
    (N'KHAITRUONG2026', N'Khuyen mai khai truong', N'PERCENT', 10, 3000000, '2026-01-01', '2026-12-31', 1),
    (N'FLASHPHONE', N'Flash sale dien thoai', N'AMOUNT', 1000000, NULL, '2026-01-01', '2026-12-31', 1);
GO

INSERT INTO dbo.PromotionTargets (PromotionId, ProductId, VariantId, CategoryId)
SELECT pr.PromotionId, p.ProductId, NULL, NULL
FROM dbo.Promotions pr
JOIN dbo.Products p ON p.Slug IN (N'dell-inspiron-15-3530', N'asus-tuf-gaming-f15')
WHERE pr.PromotionCode = N'KHAITRUONG2026'
UNION ALL
SELECT pr.PromotionId, p.ProductId, NULL, NULL
FROM dbo.Promotions pr
JOIN dbo.Products p ON p.Slug IN (N'iphone-15-128gb', N'samsung-galaxy-s24-256gb')
WHERE pr.PromotionCode = N'FLASHPHONE';
GO

INSERT INTO dbo.Coupons (CouponCode, CouponName, DiscountType, DiscountValue, MinOrderAmount, MaxDiscountAmount, UsageLimit, UsageLimitPerUser, StartAt, EndAt, IsActive)
VALUES
    (N'LAPTOP500', N'Giam 500K cho don laptop', N'AMOUNT', 500000, 15000000, 500000, 1000, 1, '2026-01-01', '2026-12-31', 1),
    (N'PHONE10', N'Giam 10% cho dien thoai', N'PERCENT', 10, 10000000, 2000000, 1000, 1, '2026-01-01', '2026-12-31', 1);
GO

INSERT INTO dbo.Carts (UserId, SessionId, Status)
SELECT u.UserId, NULL, N'ACTIVE'
FROM dbo.Users u
WHERE u.Email = N'nguyenvana@gmail.com';
GO

INSERT INTO dbo.CartItems (CartId, VariantId, Quantity, UnitPrice)
SELECT c.CartId, v.VariantId, 1, 21990000
FROM dbo.Carts c
JOIN dbo.Users u ON c.UserId = u.UserId
JOIN dbo.ProductVariants v ON v.SKU = N'IP15-PINK-128'
WHERE u.Email = N'nguyenvana@gmail.com'
UNION ALL
SELECT c.CartId, v.VariantId, 1, 17490000
FROM dbo.Carts c
JOIN dbo.Users u ON c.UserId = u.UserId
JOIN dbo.ProductVariants v ON v.SKU = N'DELL3530-BLK-16-512'
WHERE u.Email = N'nguyenvana@gmail.com';
GO

INSERT INTO dbo.Wishlists (UserId)
SELECT u.UserId
FROM dbo.Users u
WHERE u.Email IN (N'nguyenvana@gmail.com', N'tranthib@gmail.com');
GO

INSERT INTO dbo.WishlistItems (WishlistId, ProductId)
SELECT w.WishlistId, p.ProductId
FROM dbo.Wishlists w
JOIN dbo.Users u ON w.UserId = u.UserId
JOIN dbo.Products p ON p.Slug = N'asus-tuf-gaming-f15'
WHERE u.Email = N'nguyenvana@gmail.com'
UNION ALL
SELECT w.WishlistId, p.ProductId
FROM dbo.Wishlists w
JOIN dbo.Users u ON w.UserId = u.UserId
JOIN dbo.Products p ON p.Slug = N'iphone-15-128gb'
WHERE u.Email = N'tranthib@gmail.com';
GO

INSERT INTO dbo.CompareLists (UserId, SessionId)
SELECT u.UserId, NULL
FROM dbo.Users u
WHERE u.Email = N'nguyenvana@gmail.com';
GO

INSERT INTO dbo.CompareItems (CompareListId, ProductId)
SELECT cl.CompareListId, p.ProductId
FROM dbo.CompareLists cl
JOIN dbo.Users u ON cl.UserId = u.UserId
JOIN dbo.Products p ON p.Slug IN (N'iphone-15-128gb', N'samsung-galaxy-s24-256gb')
WHERE u.Email = N'nguyenvana@gmail.com';
GO

INSERT INTO dbo.Orders
(
    OrderNumber, UserId, CouponId, PickupStoreId, CustomerName, CustomerEmail, CustomerPhone,
    BillingReceiverName, BillingReceiverPhone, BillingProvince, BillingDistrict, BillingWard, BillingAddressLine,
    ShippingReceiverName, ShippingReceiverPhone, ShippingProvince, ShippingDistrict, ShippingWard, ShippingAddressLine,
    FulfillmentMethod, OrderStatus, PaymentStatus, SubtotalAmount, DiscountAmount, ShippingFee, TaxAmount, GrandTotal, CustomerNote, CreatedAt, ConfirmedAt
)
SELECT
    N'ORD20260411001',
    u.UserId,
    c.CouponId,
    NULL,
    N'Nguyen Van A',
    u.Email,
    N'0912345678',
    N'Nguyen Van A',
    N'0912345678',
    N'TP Ho Chi Minh',
    N'Quan 10',
    N'Phuong 12',
    N'120 Su Van Hanh',
    N'Nguyen Van A',
    N'0912345678',
    N'TP Ho Chi Minh',
    N'Quan 10',
    N'Phuong 12',
    N'120 Su Van Hanh',
    N'DELIVERY',
    N'CONFIRMED',
    N'PAID',
    39480000,
    500000,
    0,
    0,
    38980000,
    N'Giao gio hanh chinh',
    '2026-04-11 09:30:00',
    '2026-04-11 09:45:00'
FROM dbo.Users u
JOIN dbo.Coupons c ON c.CouponCode = N'LAPTOP500'
WHERE u.Email = N'nguyenvana@gmail.com';
GO

INSERT INTO dbo.OrderItems
(OrderId, ProductId, VariantId, ProductNameSnapshot, SKU, VariantNameSnapshot, ColorNameSnapshot, Quantity, UnitPrice, DiscountAmount, LineTotal, WarrantyPackageId)
SELECT o.OrderId, p.ProductId, v.VariantId, p.ProductName, v.SKU, v.VariantName, col.ColorName, 1, 21990000, 0, 21990000, wp.WarrantyPackageId
FROM dbo.Orders o
JOIN dbo.ProductVariants v ON v.SKU = N'IP15-PINK-128'
JOIN dbo.Products p ON p.ProductId = v.ProductId
LEFT JOIN dbo.Colors col ON col.ColorId = v.ColorId
LEFT JOIN dbo.WarrantyPackages wp ON wp.PackageName = N'Goi roi vo man hinh 12 thang'
WHERE o.OrderNumber = N'ORD20260411001'
UNION ALL
SELECT o.OrderId, p.ProductId, v.VariantId, p.ProductName, v.SKU, v.VariantName, col.ColorName, 1, 17490000, 500000, 16990000, NULL
FROM dbo.Orders o
JOIN dbo.ProductVariants v ON v.SKU = N'DELL3530-BLK-16-512'
JOIN dbo.Products p ON p.ProductId = v.ProductId
LEFT JOIN dbo.Colors col ON col.ColorId = v.ColorId
WHERE o.OrderNumber = N'ORD20260411001';
GO

INSERT INTO dbo.OrderStatusHistories (OrderId, OldStatus, NewStatus, ChangedByUserId, Note, ChangedAt)
SELECT o.OrderId, NULL, N'PENDING', adminUser.UserId, N'Don hang vua duoc tao', '2026-04-11 09:30:00'
FROM dbo.Orders o CROSS JOIN dbo.Users adminUser
WHERE o.OrderNumber = N'ORD20260411001' AND adminUser.Email = N'admin@lapstore.vn'
UNION ALL
SELECT o.OrderId, N'PENDING', N'CONFIRMED', staffUser.UserId, N'Nhan vien da xac nhan don', '2026-04-11 09:45:00'
FROM dbo.Orders o CROSS JOIN dbo.Users staffUser
WHERE o.OrderNumber = N'ORD20260411001' AND staffUser.Email = N'staff@lapstore.vn';
GO

INSERT INTO dbo.Payments (OrderId, PaymentMethod, ProviderCode, ProviderTransactionId, Amount, PaymentStatus, PaidAt)
SELECT o.OrderId, N'VNPAY', N'VNPAY', N'VNPAY_TXN_0001', 38980000, N'PAID', '2026-04-11 09:40:00'
FROM dbo.Orders o
WHERE o.OrderNumber = N'ORD20260411001';
GO

INSERT INTO dbo.Shipments (OrderId, CarrierName, ServiceName, TrackingNumber, ShipmentStatus, ShippingFee, ShippedAt)
SELECT o.OrderId, N'Giao Hang Nhanh', N'Giao nhanh noi thanh', N'GHN000123456', N'SHIPPING', 0, '2026-04-11 12:00:00'
FROM dbo.Orders o
WHERE o.OrderNumber = N'ORD20260411001';
GO

INSERT INTO dbo.CouponUsages (CouponId, UserId, OrderId, DiscountAmount)
SELECT c.CouponId, u.UserId, o.OrderId, 500000
FROM dbo.Coupons c
JOIN dbo.Users u ON u.Email = N'nguyenvana@gmail.com'
JOIN dbo.Orders o ON o.OrderNumber = N'ORD20260411001'
WHERE c.CouponCode = N'LAPTOP500';
GO

INSERT INTO dbo.OrderInstallments (OrderId, InstallmentPlanId, ApprovedByProvider, DownPaymentAmount, MonthlyAmount, TenureMonths, InterestRate, ContractNumber)
SELECT o.OrderId, ip.InstallmentPlanId, 1, 4398000, 2932667, 6, 0, N'HC-2026-0001'
FROM dbo.Orders o
JOIN dbo.InstallmentPlans ip ON ip.ProductId = (SELECT ProductId FROM dbo.Products WHERE Slug = N'iphone-15-128gb') AND ip.TenureMonths = 6
WHERE o.OrderNumber = N'ORD20260411001';
GO

INSERT INTO dbo.ProductReviews (ProductId, UserId, OrderItemId, Rating, ReviewTitle, ReviewContent, IsVerifiedPurchase, ReviewStatus, CreatedAt, ApprovedAt)
SELECT p.ProductId, u.UserId, oi.OrderItemId, 5, N'May chay muot, camera dep', N'Trai nghiem rat tot, giao hang nhanh, dong goi ky.', 1, N'APPROVED', '2026-04-11 20:00:00', '2026-04-11 21:00:00'
FROM dbo.Products p
JOIN dbo.Users u ON u.Email = N'nguyenvana@gmail.com'
JOIN dbo.OrderItems oi ON oi.ProductId = p.ProductId
JOIN dbo.Orders o ON oi.OrderId = o.OrderId
WHERE p.Slug = N'iphone-15-128gb' AND o.OrderNumber = N'ORD20260411001'
UNION ALL
SELECT p.ProductId, u.UserId, NULL, 4, N'Laptop van phong on dinh', N'Pin kha, man hinh de nhin, phu hop hoc tap va lam viec.', 0, N'APPROVED', '2026-04-10 18:00:00', '2026-04-10 19:00:00'
FROM dbo.Products p
JOIN dbo.Users u ON u.Email = N'tranthib@gmail.com'
WHERE p.Slug = N'dell-inspiron-15-3530';
GO

INSERT INTO dbo.ContactMessages (FullName, PhoneNumber, Email, Subject, MessageBody, Status)
VALUES
    (N'Le Minh C', N'0909123123', N'leminhc@gmail.com', N'Tu van laptop gaming', N'Toi can tu van laptop gaming tam gia 25-30 trieu.', N'NEW'),
    (N'Pham Thu D', N'0911222333', N'phamthud@gmail.com', N'Ho tro tra gop iPhone', N'Toi muon mua iPhone theo hinh thuc tra gop 0%.', N'IN_PROGRESS');
GO

INSERT INTO dbo.NewsletterSubscriptions (Email, UserId, IsActive)
SELECT N'khachvang@gmail.com', NULL, 1
UNION ALL
SELECT u.Email, u.UserId, 1
FROM dbo.Users u
WHERE u.Email = N'nguyenvana@gmail.com';
GO

INSERT INTO dbo.BannerSliders (BannerTitle, BannerSubtitle, ImageUrl, MobileImageUrl, LinkUrl, LinkText, DisplayOrder, IsActive, StartAt, EndAt)
VALUES
    (N'Laptop Van Phong Gia Tot', N'Dell, HP, Lenovo giam den 3 trieu', N'~/assets/img/slider/slider1-home1.jpg', N'~/assets/img/slider/slider1-home2.jpg', N'/Home/Shop', N'Mua ngay', 1, 1, '2026-01-01', '2026-12-31'),
    (N'iPhone va Samsung Chinh Hang', N'Tra gop 0%, thu cu doi moi', N'~/assets/img/slider/slider2-home1.jpg', N'~/assets/img/slider/slider2-home2.jpg', N'/Home/Shop', N'Xem san pham', 2, 1, '2026-01-01', '2026-12-31');
GO

INSERT INTO dbo.BlogPosts (AuthorUserId, Title, Slug, Summary, ContentBody, ThumbnailUrl, SeoTitle, SeoDescription, ViewCount, PublishedAt, IsPublished)
SELECT u.UserId, N'Top 5 laptop van phong dang mua nam 2026', N'top-5-laptop-van-phong-2026',
       N'Goi y cac mau laptop van phong ngon trong tam gia.',
       N'Noi dung bai viet tu van laptop van phong danh cho sinh vien va nhan vien van phong.',
       N'~/assets/img/blog/blog1.jpg',
       N'Top 5 laptop van phong 2026',
       N'Bai viet tu van chon laptop van phong',
       120, '2026-04-01 08:00:00', 1
FROM dbo.Users u
WHERE u.Email = N'admin@lapstore.vn'
UNION ALL
SELECT u.UserId, N'Nen mua iPhone hay Samsung o tam gia 20 trieu?', N'iphone-hay-samsung-20-trieu',
       N'So sanh nhanh giua iPhone va Samsung cho nhu cau pho thong va cao cap.',
       N'Noi dung bai viet so sanh iPhone va Samsung giup khach hang de lua chon hon.',
       N'~/assets/img/blog/blog2.jpg',
       N'iPhone hay Samsung 20 trieu',
       N'Bai viet so sanh dien thoai dang mua',
       95, '2026-04-05 09:00:00', 1
FROM dbo.Users u
WHERE u.Email = N'admin@lapstore.vn';
GO

/*
====================================================================
HUONG SU DUNG FILE NAY
====================================================================
1. Chay file trong SQL Server Management Studio.
2. Database [LaptopPhoneStoreDB] se duoc tao neu chua ton tai.
3. Bang seed co san categories, brands, roles, colors.
4. Sau do co the:
   - Tao DbContext + entity classes theo cac bang nay
   - Tao migrations tu schema nay neu muon code-first hoa nguoc lai
   - Dieu chinh them bang voucher/bao hanh/tra gop theo nghiep vu thuc te

GOI Y AP DUNG VOI PROJECT HIEN TAI
   - Home/Index      -> BannerSliders, Products, ProductImages, Brands
   - Shop            -> Products, ProductVariants, Categories, Brands
   - Product         -> Products, ProductVariants, ProductImages, specs, reviews
   - Cart            -> Carts, CartItems, Coupons
   - Checkout        -> Orders, OrderItems, Payments, Shipments, UserAddresses
   - Wishlist        -> Wishlists, WishlistItems
   - Compare         -> CompareLists, CompareItems
   - Login/Register  -> Users, Roles, UserRoles
   - MyAccount       -> Users, UserAddresses, Orders
   - Contact         -> ContactMessages
   - Blog            -> BlogPosts
====================================================================
*/
