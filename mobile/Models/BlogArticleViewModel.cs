namespace mobile.Models;

public sealed class BlogArticleViewModel
{
    public int Id { get; init; }

    public string Title { get; init; } = string.Empty;

    public string Summary { get; init; } = string.Empty;

    public string Content { get; init; } = string.Empty;

    public string ImageUrl { get; init; } = "~/assets/img/blog/blog1.jpg";

    public string Author { get; init; } = "Mobile Store";

    public DateTime CreatedAt { get; init; } = DateTime.Today;

    public int CommentCount { get; init; }
}
