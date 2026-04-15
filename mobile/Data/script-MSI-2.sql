USE [master]
GO
/****** Object:  Database [mobile]    Script Date: 4/11/2026 11:59:16 PM ******/
CREATE DATABASE [mobile]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'mobile', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\mobile.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'mobile_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\mobile_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [mobile] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [mobile].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [mobile] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [mobile] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [mobile] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [mobile] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [mobile] SET ARITHABORT OFF 
GO
ALTER DATABASE [mobile] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [mobile] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [mobile] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [mobile] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [mobile] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [mobile] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [mobile] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [mobile] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [mobile] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [mobile] SET  DISABLE_BROKER 
GO
ALTER DATABASE [mobile] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [mobile] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [mobile] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [mobile] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [mobile] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [mobile] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [mobile] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [mobile] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [mobile] SET  MULTI_USER 
GO
ALTER DATABASE [mobile] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [mobile] SET DB_CHAINING OFF 
GO
ALTER DATABASE [mobile] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [mobile] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [mobile] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [mobile] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [mobile] SET QUERY_STORE = ON
GO
ALTER DATABASE [mobile] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [mobile]
GO
/****** Object:  Table [dbo].[BlogComments]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlogComments](
	[CommentID] [int] IDENTITY(1,1) NOT NULL,
	[BlogID] [int] NULL,
	[UserID] [int] NULL,
	[Content] [nvarchar](max) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CommentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Blogs]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Blogs](
	[BlogID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](255) NULL,
	[Content] [nvarchar](max) NULL,
	[Image] [nvarchar](255) NULL,
	[Author] [nvarchar](100) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[BlogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cart]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cart](
	[CartID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CartItems]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CartItems](
	[CartItemID] [int] IDENTITY(1,1) NOT NULL,
	[CartID] [int] NULL,
	[ProductID] [int] NULL,
	[Quantity] [int] NULL,
	[Price] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[CartItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Contacts]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Contacts](
	[ContactID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NULL,
	[Message] [nvarchar](max) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Coupons]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Coupons](
	[CouponID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Discount] [decimal](5, 2) NULL,
	[ExpiryDate] [datetime] NULL,
	[IsActive] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[CouponID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails](
	[OrderDetailID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NULL,
	[ProductID] [int] NULL,
	[Quantity] [int] NULL,
	[Price] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[OrderDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[TotalAmount] [decimal](18, 2) NULL,
	[ShippingAddress] [nvarchar](255) NULL,
	[Phone] [nvarchar](20) NULL,
	[Note] [nvarchar](255) NULL,
	[Status] [nvarchar](50) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Payments]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments](
	[PaymentID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NULL,
	[PaymentMethod] [nvarchar](50) NULL,
	[PaymentStatus] [nvarchar](50) NULL,
	[PaidAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[PaymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductDetails]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductDetails](
	[DetailID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[CPU] [nvarchar](100) NULL,
	[RAM] [nvarchar](50) NULL,
	[Storage] [nvarchar](50) NULL,
	[Screen] [nvarchar](100) NULL,
	[GPU] [nvarchar](100) NULL,
	[Battery] [nvarchar](50) NULL,
	[OS] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[DetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductImages]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductImages](
	[ImageID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[ImageURL] [nvarchar](255) NULL,
	[IsMain] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ImageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Price] [decimal](18, 2) NOT NULL,
	[Discount] [decimal](5, 2) NULL,
	[Stock] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[CategoryID] [int] NULL,
	[Brand] [nvarchar](100) NULL,
	[Thumbnail] [nvarchar](255) NULL,
	[IsActive] [bit] NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductVariants]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductVariants](
	[VariantID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[VariantName] [nvarchar](100) NULL,
	[Price] [decimal](18, 2) NULL,
	[Stock] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[VariantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reviews]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reviews](
	[ReviewID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[UserID] [int] NULL,
	[Rating] [int] NULL,
	[Comment] [nvarchar](max) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ReviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](100) NULL,
	[Password] [nvarchar](255) NULL,
	[FullName] [nvarchar](150) NULL,
	[Email] [nvarchar](100) NULL,
	[Phone] [nvarchar](20) NULL,
	[Address] [nvarchar](255) NULL,
	[Role] [nvarchar](20) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Wishlist]    Script Date: 4/11/2026 11:59:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Wishlist](
	[WishlistID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[ProductID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[WishlistID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BlogComments] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Blogs] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Cart] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[CartItems] ADD  DEFAULT ((1)) FOR [Quantity]
GO
ALTER TABLE [dbo].[Categories] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Contacts] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Coupons] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Orders] ADD  DEFAULT ('Pending') FOR [Status]
GO
ALTER TABLE [dbo].[Orders] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[ProductImages] ADD  DEFAULT ((0)) FOR [IsMain]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [Stock]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Reviews] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ('User') FOR [Role]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[BlogComments]  WITH CHECK ADD FOREIGN KEY([BlogID])
REFERENCES [dbo].[Blogs] ([BlogID])
GO
ALTER TABLE [dbo].[BlogComments]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[CartItems]  WITH CHECK ADD FOREIGN KEY([CartID])
REFERENCES [dbo].[Cart] ([CartID])
GO
ALTER TABLE [dbo].[CartItems]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[ProductDetails]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[ProductImages]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])
GO
ALTER TABLE [dbo].[ProductVariants]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Wishlist]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[Wishlist]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
GO
ALTER TABLE [dbo].[Reviews]  WITH CHECK ADD CHECK  (([Rating]>=(1) AND [Rating]<=(5)))
GO
/****** Seed data for development and UI testing ******/
INSERT INTO [dbo].[Categories] ([CategoryName], [Description], [CreatedAt])
SELECT N'Laptop', N'Laptop phu hop hoc tap, van phong va gaming tam trung.', GETDATE()
WHERE NOT EXISTS (
    SELECT 1
    FROM [dbo].[Categories]
    WHERE [CategoryName] = N'Laptop'
);
GO
INSERT INTO [dbo].[Categories] ([CategoryName], [Description], [CreatedAt])
SELECT N'Dien thoai', N'Dien thoai thong minh chinh hang nhieu tam gia.', GETDATE()
WHERE NOT EXISTS (
    SELECT 1
    FROM [dbo].[Categories]
    WHERE [CategoryName] = N'Dien thoai'
);
GO

INSERT INTO [dbo].[Products] ([Name], [Price], [Discount], [Stock], [Description], [CategoryID], [Brand], [Thumbnail], [IsActive], [CreatedAt])
SELECT N'MSI Modern 14 C13M', 18990000, 5.00, 12, N'Laptop van phong gon nhe, hop cho hoc tap va lam viec moi ngay.', c.[CategoryID], N'MSI', N'~/assets/img/product/product-1.jpg', 1, GETDATE()
FROM [dbo].[Categories] c
WHERE c.[CategoryName] = N'Laptop'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[Products] p WHERE p.[Name] = N'MSI Modern 14 C13M');
GO
INSERT INTO [dbo].[Products] ([Name], [Price], [Discount], [Stock], [Description], [CategoryID], [Brand], [Thumbnail], [IsActive], [CreatedAt])
SELECT N'ASUS Vivobook 15 OLED', 21990000, 7.00, 10, N'Laptop man hinh OLED, thiet ke hien dai va hieu nang on dinh.', c.[CategoryID], N'ASUS', N'~/assets/img/product/product-3.jpg', 1, GETDATE()
FROM [dbo].[Categories] c
WHERE c.[CategoryName] = N'Laptop'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[Products] p WHERE p.[Name] = N'ASUS Vivobook 15 OLED');
GO
INSERT INTO [dbo].[Products] ([Name], [Price], [Discount], [Stock], [Description], [CategoryID], [Brand], [Thumbnail], [IsActive], [CreatedAt])
SELECT N'Lenovo LOQ 15IRH8', 26990000, 4.00, 6, N'Laptop gaming tam trung voi man hinh 144Hz va tan nhiet tot.', c.[CategoryID], N'Lenovo', N'~/assets/img/product/product-5.jpg', 1, GETDATE()
FROM [dbo].[Categories] c
WHERE c.[CategoryName] = N'Laptop'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[Products] p WHERE p.[Name] = N'Lenovo LOQ 15IRH8');
GO
INSERT INTO [dbo].[Products] ([Name], [Price], [Discount], [Stock], [Description], [CategoryID], [Brand], [Thumbnail], [IsActive], [CreatedAt])
SELECT N'Acer Nitro V 15', 23990000, 6.00, 7, N'Laptop gaming can bang gia va hieu nang, phu hop sinh vien ky thuat.', c.[CategoryID], N'Acer', N'~/assets/img/product/product-7.jpg', 1, GETDATE()
FROM [dbo].[Categories] c
WHERE c.[CategoryName] = N'Laptop'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[Products] p WHERE p.[Name] = N'Acer Nitro V 15');
GO
INSERT INTO [dbo].[Products] ([Name], [Price], [Discount], [Stock], [Description], [CategoryID], [Brand], [Thumbnail], [IsActive], [CreatedAt])
SELECT N'iPhone 15 128GB', 19990000, 3.00, 15, N'Dien thoai cao cap voi hieu nang manh, camera tot va trai nghiem on dinh.', c.[CategoryID], N'Apple', N'~/assets/img/product/product-9.jpg', 1, GETDATE()
FROM [dbo].[Categories] c
WHERE c.[CategoryName] = N'Dien thoai'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[Products] p WHERE p.[Name] = N'iPhone 15 128GB');
GO
INSERT INTO [dbo].[Products] ([Name], [Price], [Discount], [Stock], [Description], [CategoryID], [Brand], [Thumbnail], [IsActive], [CreatedAt])
SELECT N'Samsung Galaxy S24 256GB', 18990000, 8.00, 11, N'Dien thoai Android cao cap, man hinh dep va camera da dung.', c.[CategoryID], N'Samsung', N'~/assets/img/product/product-11.jpg', 1, GETDATE()
FROM [dbo].[Categories] c
WHERE c.[CategoryName] = N'Dien thoai'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[Products] p WHERE p.[Name] = N'Samsung Galaxy S24 256GB');
GO
INSERT INTO [dbo].[Products] ([Name], [Price], [Discount], [Stock], [Description], [CategoryID], [Brand], [Thumbnail], [IsActive], [CreatedAt])
SELECT N'Xiaomi 14T 12GB 256GB', 12990000, 5.00, 13, N'Dien thoai can bang gia va cau hinh, man hinh dep va sac nhanh.', c.[CategoryID], N'Xiaomi', N'~/assets/img/product/product-13.jpg', 1, GETDATE()
FROM [dbo].[Categories] c
WHERE c.[CategoryName] = N'Dien thoai'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[Products] p WHERE p.[Name] = N'Xiaomi 14T 12GB 256GB');
GO
INSERT INTO [dbo].[Products] ([Name], [Price], [Discount], [Stock], [Description], [CategoryID], [Brand], [Thumbnail], [IsActive], [CreatedAt])
SELECT N'OPPO Reno11 F 5G', 9990000, 5.00, 14, N'Dien thoai thiet ke tre trung, camera dep va pin du dung ca ngay.', c.[CategoryID], N'OPPO', N'~/assets/img/product/product-14.jpg', 1, GETDATE()
FROM [dbo].[Categories] c
WHERE c.[CategoryName] = N'Dien thoai'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[Products] p WHERE p.[Name] = N'OPPO Reno11 F 5G');
GO

INSERT INTO [dbo].[ProductDetails] ([ProductID], [CPU], [RAM], [Storage], [Screen], [GPU], [Battery], [OS])
SELECT p.[ProductID], N'Intel Core i5-1335U', N'16GB DDR4', N'512GB SSD', N'14-inch FHD IPS', N'Intel Iris Xe', N'39.3Wh', N'Windows 11'
FROM [dbo].[Products] p
WHERE p.[Name] = N'MSI Modern 14 C13M'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductDetails] d WHERE d.[ProductID] = p.[ProductID]);
GO
INSERT INTO [dbo].[ProductDetails] ([ProductID], [CPU], [RAM], [Storage], [Screen], [GPU], [Battery], [OS])
SELECT p.[ProductID], N'Intel Core i5-13500H', N'16GB DDR4', N'512GB SSD', N'15.6-inch OLED', N'Intel Iris Xe', N'50Wh', N'Windows 11'
FROM [dbo].[Products] p
WHERE p.[Name] = N'ASUS Vivobook 15 OLED'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductDetails] d WHERE d.[ProductID] = p.[ProductID]);
GO
INSERT INTO [dbo].[ProductDetails] ([ProductID], [CPU], [RAM], [Storage], [Screen], [GPU], [Battery], [OS])
SELECT p.[ProductID], N'Intel Core i7-13620H', N'16GB DDR5', N'512GB SSD', N'15.6-inch FHD 144Hz', N'RTX 4050 6GB', N'60Wh', N'Windows 11'
FROM [dbo].[Products] p
WHERE p.[Name] = N'Lenovo LOQ 15IRH8'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductDetails] d WHERE d.[ProductID] = p.[ProductID]);
GO
INSERT INTO [dbo].[ProductDetails] ([ProductID], [CPU], [RAM], [Storage], [Screen], [GPU], [Battery], [OS])
SELECT p.[ProductID], N'Intel Core i5-13420H', N'16GB DDR5', N'512GB SSD', N'15.6-inch FHD 144Hz', N'RTX 4050 6GB', N'57Wh', N'Windows 11'
FROM [dbo].[Products] p
WHERE p.[Name] = N'Acer Nitro V 15'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductDetails] d WHERE d.[ProductID] = p.[ProductID]);
GO
INSERT INTO [dbo].[ProductDetails] ([ProductID], [CPU], [RAM], [Storage], [Screen], [GPU], [Battery], [OS])
SELECT p.[ProductID], N'Apple A16 Bionic', N'6GB', N'128GB', N'6.1-inch Super Retina XDR', N'Apple GPU 5-core', N'3349mAh', N'iOS 18'
FROM [dbo].[Products] p
WHERE p.[Name] = N'iPhone 15 128GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductDetails] d WHERE d.[ProductID] = p.[ProductID]);
GO
INSERT INTO [dbo].[ProductDetails] ([ProductID], [CPU], [RAM], [Storage], [Screen], [GPU], [Battery], [OS])
SELECT p.[ProductID], N'Snapdragon 8 Gen 3', N'8GB', N'256GB', N'6.2-inch Dynamic AMOLED 2X', N'Adreno 750', N'4000mAh', N'Android 15'
FROM [dbo].[Products] p
WHERE p.[Name] = N'Samsung Galaxy S24 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductDetails] d WHERE d.[ProductID] = p.[ProductID]);
GO
INSERT INTO [dbo].[ProductDetails] ([ProductID], [CPU], [RAM], [Storage], [Screen], [GPU], [Battery], [OS])
SELECT p.[ProductID], N'MediaTek Dimensity 8300 Ultra', N'12GB', N'256GB', N'6.67-inch AMOLED 144Hz', N'Mali G615', N'5000mAh', N'Android 15'
FROM [dbo].[Products] p
WHERE p.[Name] = N'Xiaomi 14T 12GB 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductDetails] d WHERE d.[ProductID] = p.[ProductID]);
GO
INSERT INTO [dbo].[ProductDetails] ([ProductID], [CPU], [RAM], [Storage], [Screen], [GPU], [Battery], [OS])
SELECT p.[ProductID], N'MediaTek Dimensity 7050', N'8GB', N'256GB', N'6.7-inch AMOLED 120Hz', N'Mali G68', N'5000mAh', N'Android 15'
FROM [dbo].[Products] p
WHERE p.[Name] = N'OPPO Reno11 F 5G'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductDetails] d WHERE d.[ProductID] = p.[ProductID]);
GO

INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-1.jpg', 1
FROM [dbo].[Products] p
WHERE p.[Name] = N'MSI Modern 14 C13M'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-1.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-2.jpg', 0
FROM [dbo].[Products] p
WHERE p.[Name] = N'MSI Modern 14 C13M'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-2.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-3.jpg', 1
FROM [dbo].[Products] p
WHERE p.[Name] = N'ASUS Vivobook 15 OLED'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-3.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-4.jpg', 0
FROM [dbo].[Products] p
WHERE p.[Name] = N'ASUS Vivobook 15 OLED'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-4.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-5.jpg', 1
FROM [dbo].[Products] p
WHERE p.[Name] = N'Lenovo LOQ 15IRH8'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-5.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-6.jpg', 0
FROM [dbo].[Products] p
WHERE p.[Name] = N'Lenovo LOQ 15IRH8'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-6.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-7.jpg', 1
FROM [dbo].[Products] p
WHERE p.[Name] = N'Acer Nitro V 15'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-7.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-8.jpg', 0
FROM [dbo].[Products] p
WHERE p.[Name] = N'Acer Nitro V 15'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-8.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-9.jpg', 1
FROM [dbo].[Products] p
WHERE p.[Name] = N'iPhone 15 128GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-9.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-10.jpg', 0
FROM [dbo].[Products] p
WHERE p.[Name] = N'iPhone 15 128GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-10.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-11.jpg', 1
FROM [dbo].[Products] p
WHERE p.[Name] = N'Samsung Galaxy S24 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-11.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-12.jpg', 0
FROM [dbo].[Products] p
WHERE p.[Name] = N'Samsung Galaxy S24 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-12.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-13.jpg', 1
FROM [dbo].[Products] p
WHERE p.[Name] = N'Xiaomi 14T 12GB 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-13.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-14.jpg', 0
FROM [dbo].[Products] p
WHERE p.[Name] = N'Xiaomi 14T 12GB 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-14.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-14.jpg', 1
FROM [dbo].[Products] p
WHERE p.[Name] = N'OPPO Reno11 F 5G'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-14.jpg');
GO
INSERT INTO [dbo].[ProductImages] ([ProductID], [ImageURL], [IsMain])
SELECT p.[ProductID], N'~/assets/img/product/product-13.jpg', 0
FROM [dbo].[Products] p
WHERE p.[Name] = N'OPPO Reno11 F 5G'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductImages] i WHERE i.[ProductID] = p.[ProductID] AND i.[ImageURL] = N'~/assets/img/product/product-13.jpg');
GO

INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'16GB/512GB - Classic Black', 18990000, 8
FROM [dbo].[Products] p
WHERE p.[Name] = N'MSI Modern 14 C13M'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'16GB/512GB - Classic Black');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'8GB/512GB - Silver', 17990000, 4
FROM [dbo].[Products] p
WHERE p.[Name] = N'MSI Modern 14 C13M'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'8GB/512GB - Silver');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'16GB/512GB - Indie Black', 21990000, 6
FROM [dbo].[Products] p
WHERE p.[Name] = N'ASUS Vivobook 15 OLED'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'16GB/512GB - Indie Black');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'16GB/1TB - Cool Silver', 23990000, 4
FROM [dbo].[Products] p
WHERE p.[Name] = N'ASUS Vivobook 15 OLED'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'16GB/1TB - Cool Silver');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'16GB/512GB - Luna Grey', 26990000, 4
FROM [dbo].[Products] p
WHERE p.[Name] = N'Lenovo LOQ 15IRH8'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'16GB/512GB - Luna Grey');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'24GB/512GB - Storm Grey', 28990000, 2
FROM [dbo].[Products] p
WHERE p.[Name] = N'Lenovo LOQ 15IRH8'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'24GB/512GB - Storm Grey');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'16GB/512GB - Obsidian Black', 23990000, 5
FROM [dbo].[Products] p
WHERE p.[Name] = N'Acer Nitro V 15'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'16GB/512GB - Obsidian Black');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'16GB/1TB - Obsidian Black', 25990000, 2
FROM [dbo].[Products] p
WHERE p.[Name] = N'Acer Nitro V 15'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'16GB/1TB - Obsidian Black');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'Black 128GB', 19990000, 8
FROM [dbo].[Products] p
WHERE p.[Name] = N'iPhone 15 128GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'Black 128GB');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'Pink 128GB', 19990000, 7
FROM [dbo].[Products] p
WHERE p.[Name] = N'iPhone 15 128GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'Pink 128GB');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'Onyx Black 256GB', 18990000, 5
FROM [dbo].[Products] p
WHERE p.[Name] = N'Samsung Galaxy S24 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'Onyx Black 256GB');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'Marble Gray 256GB', 18990000, 6
FROM [dbo].[Products] p
WHERE p.[Name] = N'Samsung Galaxy S24 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'Marble Gray 256GB');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'Black 256GB', 12990000, 7
FROM [dbo].[Products] p
WHERE p.[Name] = N'Xiaomi 14T 12GB 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'Black 256GB');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'Blue 256GB', 12990000, 6
FROM [dbo].[Products] p
WHERE p.[Name] = N'Xiaomi 14T 12GB 256GB'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'Blue 256GB');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'Green 256GB', 9990000, 8
FROM [dbo].[Products] p
WHERE p.[Name] = N'OPPO Reno11 F 5G'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'Green 256GB');
GO
INSERT INTO [dbo].[ProductVariants] ([ProductID], [VariantName], [Price], [Stock])
SELECT p.[ProductID], N'Purple 256GB', 9990000, 6
FROM [dbo].[Products] p
WHERE p.[Name] = N'OPPO Reno11 F 5G'
  AND NOT EXISTS (SELECT 1 FROM [dbo].[ProductVariants] v WHERE v.[ProductID] = p.[ProductID] AND v.[VariantName] = N'Purple 256GB');
GO
USE [master]
GO
ALTER DATABASE [mobile] SET  READ_WRITE 
GO

