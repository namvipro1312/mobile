using System;
using System.Collections.Generic;

namespace mobile.Models;

public partial class Order
{
    public int OrderId { get; set; }

    public int? UserId { get; set; }

    public decimal? TotalAmount { get; set; }

    public string? ShippingAddress { get; set; }

    public string? Phone { get; set; }

    public string? Note { get; set; }

    public string? Status { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual ICollection<OrderDetail> OrderDetails { get; set; } = new List<OrderDetail>();

    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();

    public virtual User? User { get; set; }
}
