using System;
using System.Collections.Generic;

namespace mobile.Models;

public partial class BlogComment
{
    public int CommentId { get; set; }

    public int? BlogId { get; set; }

    public int? UserId { get; set; }

    public string? Content { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Blog? Blog { get; set; }

    public virtual User? User { get; set; }
}
