using System;
using System.Collections.Generic;

namespace mobile.Models;

public partial class ProductVariant
{
    public int VariantId { get; set; }

    public int? ProductId { get; set; }

    public string? VariantName { get; set; }

    public decimal? Price { get; set; }

    public int? Stock { get; set; }

    public virtual Product? Product { get; set; }
}
