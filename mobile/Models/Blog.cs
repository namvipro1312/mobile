using System;
using System.Collections.Generic;

namespace mobile.Models;

public partial class Blog
{
    public int BlogId { get; set; }

    public string? Title { get; set; }

    public string? Content { get; set; }

    public string? Image { get; set; }

    public string? Author { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual ICollection<BlogComment> BlogComments { get; set; } = new List<BlogComment>();
}
