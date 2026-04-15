$templateDir = 'template\cc\htmldemo.net\sinrato\sinrato'
$layoutTemplate = Join-Path $templateDir 'index.html'
$layoutOut = 'Views\Shared\_Layout.cshtml'

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
  $normalized = Fix-AssetPaths $normalized
  $normalized = Fix-InternalLinks $normalized
  $normalized = $normalized -replace '@', '@@'
  $normalized = Restore-ProtectedExpressions $normalized
  return $normalized
}

$html = Get-Content -Raw -Encoding UTF8 $layoutTemplate
$html = Remove-MirrorComments $html

$iHeader = $html.IndexOf($headerMarker, [System.StringComparison]::OrdinalIgnoreCase)
$iFooter = $html.IndexOf($footerMarker, [System.StringComparison]::OrdinalIgnoreCase)

if ($iHeader -lt 0 -or $iFooter -lt 0 -or $iFooter -le $iHeader) {
  throw 'Cannot find header/footer markers in template.'
}

$headAndHeader = $html.Substring(0, $iHeader + $headerMarker.Length)
$footerAndAfter = $html.Substring($iFooter)

$headAndHeader = Normalize-Fragment $headAndHeader
$footerAndAfter = Normalize-Fragment $footerAndAfter

$headAndHeader = $headAndHeader -replace '(?is)<title>.*?</title>', '<title>@ViewData["Title"] - Sinrato</title>'

$layout = @"
$headAndHeader

    @RenderBody()

$footerAndAfter
"@

Set-Content -Path $layoutOut -Value $layout -Encoding UTF8
