using System;
using System.Collections.Generic;

namespace mobile.Models;

public partial class ProductDetail
{
    public int DetailId { get; set; }

    public int? ProductId { get; set; }

    public string? Cpu { get; set; }

    public string? Ram { get; set; }

    public string? Storage { get; set; }

    public string? Screen { get; set; }

    public string? Gpu { get; set; }

    public string? Battery { get; set; }

    public string? Os { get; set; }

    public virtual Product? Product { get; set; }
}
