$templateDir = 'template\cc\htmldemo.net\sinrato\sinrato'

$pages = @(
  @{ Action = 'Index';     Template = 'index.html';                    Title = 'Home' },
  @{ Action = 'Shop';      Template = 'shop-grid-left-sidebar.html';   Title = 'Shop' },
  @{ Action = 'Product';   Template = 'product-details.html';          Title = 'Product' },
  @{ Action = 'Blog';      Template = 'blog-full-5-column.html';       Title = 'Blog' },
  @{ Action = 'About';     Template = 'about.html';                    Title = 'About' },
  @{ Action = 'Cart';      Template = 'cart.html';                     Title = 'Cart' },
  @{ Action = 'Checkout';  Template = 'checkout.html';                 Title = 'Checkout' },
  @{ Action = 'Contact';   Template = 'contact-us.html';               Title = 'Contact' },
  @{ Action = 'Wishlist';  Template = 'wishlist.html';                 Title = 'Wishlist' },
  @{ Action = 'Compare';   Template = 'compare.html';                  Title = 'Compare' },
  @{ Action = 'Login';     Template = 'login.html';                    Title = 'Login' },
  @{ Action = 'Register';  Template = 'register.html';                 Title = 'Register' },
  @{ Action = 'MyAccount'; Template = 'my-account.html';               Title = 'My Account' }
)

$headerMarker = '<!-- header area end -->'
$footerMarker = '<!-- footer area start -->'

$linkMap = @{
  'index.html'                      = '@Url.Action("Index", "Home")'
  'index-2.html'                    = '@Url.Action("Index", "Home")'
  'index-3.html'                    = '@Url.Action("Index", "Home")'
  'index-4.html'                    = '@Url.Action("Index", "Home")'
  'about.html'                      = '@Url.Action("About", "Home")'
  'blog-details.html'               = '@Url.Action("Blog", "Home")'
  'blog-details-audio.html'         = '@Url.Action("Blog", "Home")'
  'blog-details-gallery.html'       = '@Url.Action("Blog", "Home")'
  'blog-details-right-sidebar.html' = '@Url.Action("Blog", "Home")'
  'blog-details-video.html'         = '@Url.Action("Blog", "Home")'
  'blog-full-3-column.html'         = '@Url.Action("Blog", "Home")'
  'blog-full-4-column.html'         = '@Url.Action("Blog", "Home")'
  'blog-full-5-column.html'         = '@Url.Action("Blog", "Home")'
  'blog-left-sidebar-3.html'        = '@Url.Action("Blog", "Home")'
  'blog-left-sidebar-4.html'        = '@Url.Action("Blog", "Home")'
  'blog-right-sidebar-3.html'       = '@Url.Action("Blog", "Home")'
  'blog-right-sidebar-4.html'       = '@Url.Action("Blog", "Home")'
  'cart.html'                       = '@Url.Action("Cart", "Home")'
  'checkout.html'                   = '@Url.Action("Checkout", "Home")'
  'compare.html'                    = '@Url.Action("Compare", "Home")'
  'contact-us.html'                 = '@Url.Action("Contact", "Home")'
  'login.html'                      = '@Url.Action("Login", "Home")'
  'my-account.html'                 = '@Url.Action("MyAccount", "Home")'
  'product-details.html'            = '@Url.Action("Product", "Home")'
  'product-details-external.html'   = '@Url.Action("Product", "Home")'
  'product-details-gallery-left.html' = '@Url.Action("Product", "Home")'
  'product-details-gallery-right.html' = '@Url.Action("Product", "Home")'
  'product-details-group.html'      = '@Url.Action("Product", "Home")'
  'product-details-slider-box.html' = '@Url.Action("Product", "Home")'
  'product-details-variable.html'   = '@Url.Action("Product", "Home")'
  'register.html'                   = '@Url.Action("Register", "Home")'
  'shop-grid-full-width.html'       = '@Url.Action("Shop", "Home")'
  'shop-grid-full-width-3-column.html' = '@Url.Action("Shop", "Home")'
  'shop-grid-full-width-4-column.html' = '@Url.Action("Shop", "Home")'
  'shop-grid-left-sidebar.html'     = '@Url.Action("Shop", "Home")'
  'shop-grid-left-sidebar-4-column.html' = '@Url.Action("Shop", "Home")'
  'shop-grid-right-sidebar.html'    = '@Url.Action("Shop", "Home")'
  'shop-grid-right-sidebar-4-column.html' = '@Url.Action("Shop", "Home")'
  'shop-list-full-width.html'       = '@Url.Action("Shop", "Home")'
  'shop-list-left-sidebar.html'     = '@Url.Action("Shop", "Home")'
  'shop-list-right-sidebar.html'    = '@Url.Action("Shop", "Home")'
  'sticky-left-sidebar.html'        = '@Url.Action("Product", "Home")'
  'sticky-right-sidebar.html'       = '@Url.Action("Product", "Home")'
  'tab-style-one.html'              = '@Url.Action("Product", "Home")'
  'wishlist.html'                   = '@Url.Action("Wishlist", "Home")'
}

$protectedExpressions = [System.Collections.Generic.List[string]]::new()

function New-ProtectedExpression([string]$expression) {
  $token = "__RAZOR_EXPR_$($protectedExpressions.Count)__"
  $protectedExpressions.Add($expression)
  return $token
}

function Restore-ProtectedExpressions([string]$content) {
  for ($i = 0; $i -lt $protectedExpressions.Count; $i++) {
    $content = $content.Replace("__RAZOR_EXPR_${i}__", $protectedExpressions[$i])
  }

  return $content
}

function Remove-MirrorComments([string]$content) {
  return ($content -replace '(?is)<!--\s*Mirrored from.*?-->\s*', '')
}

function Extract-BodyContent([string]$html) {
  $iHeader = $html.IndexOf($headerMarker, [System.StringComparison]::OrdinalIgnoreCase)
  $iFooter = $html.IndexOf($footerMarker, [System.StringComparison]::OrdinalIgnoreCase)

  if ($iHeader -ge 0 -and $iFooter -ge 0 -and $iFooter -gt $iHeader) {
    return $html.Substring($iHeader + $headerMarker.Length, $iFooter - ($iHeader + $headerMarker.Length))
  }

  $headerCloseMatch = [regex]::Match($html, '(?is)</header>')
  $footerOpenMatch = [regex]::Match($html, '(?is)<footer\b')
  if ($headerCloseMatch.Success -and $footerOpenMatch.Success -and $footerOpenMatch.Index -gt $headerCloseMatch.Index) {
    $start = $headerCloseMatch.Index + $headerCloseMatch.Length
    return $html.Substring($start, $footerOpenMatch.Index - $start)
  }

  $bodyMatch = [regex]::Match($html, '(?is)<body[^>]*>(?<content>.*)</body>')
  if ($bodyMatch.Success) {
    return $bodyMatch.Groups['content'].Value
  }

  throw 'Cannot extract body content.'
}

function Fix-AssetPaths([string]$content) {
  $content = $content -replace '(["''])assets/', '$1~/assets/'
  $content = $content -replace '(["''])/assets/', '$1~/assets/'

  $content = [regex]::Replace(
    $content,
    'url\((["'']?)(?:~\/|/)?assets/(?<path>[^)"'']+)\1\)',
    {
      param($match)

      $assetPath = $match.Groups['path'].Value
      $token = New-ProtectedExpression("@Url.Content(""~/assets/$assetPath"")")
      return "url('$token')"
    }
  )

  return $content
}

function Fix-InternalLinks([string]$content) {
  return [regex]::Replace(
    $content,
    '(?<attr>href|action)=["''](?<target>[^"'']+\.html)["'']',
    {
      param($match)

      $target = $match.Groups['target'].Value
      if (-not $linkMap.ContainsKey($target)) {
        return $match.Value
      }

      $token = New-ProtectedExpression($linkMap[$target])
      return "$($match.Groups['attr'].Value)=`"$token`""
    }
  )
}

function Normalize-Fragment([string]$content) {
  $normalized = Remove-MirrorComments $content
  $normalized = $normalized -replace '(?is)^\s*<header\b.*?</header>\s*', ''
  $normalized = $normalized -replace '(?is)<footer\b.*?</footer>\s*', ''
  $normalized = $normalized -replace '(?is)<script\b[^>]*>.*?</script>\s*', ''
  $normalized = Fix-AssetPaths $normalized
  $normalized = Fix-InternalLinks $normalized
  $normalized = $normalized -replace '@', '@@'
  $normalized = Restore-ProtectedExpressions $normalized
  return $normalized
}

foreach ($page in $pages) {
  $templatePath = Join-Path $templateDir $page.Template
  if (-not (Test-Path $templatePath)) {
    throw "Missing template: $templatePath"
  }

  $protectedExpressions.Clear()

  $html = Get-Content -Raw -Encoding UTF8 $templatePath
  $bodyContent = Extract-BodyContent (Remove-MirrorComments $html)
  $bodyContent = Normalize-Fragment $bodyContent

  $view = @"
@{ ViewData["Title"] = "$($page.Title)"; }
$bodyContent
"@

  $outputPath = Join-Path 'Views\Home' ($page.Action + '.cshtml')
  Set-Content -Path $outputPath -Value $view -Encoding UTF8
}
