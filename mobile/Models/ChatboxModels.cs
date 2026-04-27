namespace mobile.Models;

public sealed class ChatboxMessageRequest
{
    public string Message { get; set; } = string.Empty;

    public string? UserName { get; set; }

    public ChatboxStoreContext? StoreContext { get; set; }

    public List<ChatboxTurn> History { get; set; } = [];
}

public sealed class ChatboxStoreContext
{
    public string? HomeUrl { get; set; }

    public string? ShopUrl { get; set; }

    public string? CartUrl { get; set; }

    public string? CheckoutUrl { get; set; }

    public string? AccountUrl { get; set; }

    public string? ContactUrl { get; set; }

    public string? CompareUrl { get; set; }

    public string? WishlistUrl { get; set; }
}

public sealed class ChatboxTurn
{
    public string Role { get; set; } = string.Empty;

    public string Text { get; set; } = string.Empty;
}

public sealed class ChatboxMessageResponse
{
    public string Answer { get; set; } = string.Empty;
}
