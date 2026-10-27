# Okuw diski - yerli web-serwer (Python gerek dal).
# Windows 7 SP1 we tazeleri: PowerShell 2.0 we .NET 3.5 yeterlik.
param([int]$Port = 8777)

$ErrorActionPreference = "Stop"

# Kok bukja - ayagynda hokman bir "\" bolmaly, yogsam C:\disk bilen
# C:\disk2 bir hasaplanyar we bukjadan dasa cykmak mumkin bolyar.
$root = [System.IO.Path]::GetFullPath((Get-Location).Path)
if (-not $root.EndsWith("\")) { $root = $root + "\" }

$mime = @{
  ".htm"="text/html"; ".html"="text/html"; ".css"="text/css"; ".js"="application/javascript";
  ".jpg"="image/jpeg"; ".jpeg"="image/jpeg"; ".png"="image/png"; ".gif"="image/gif";
  ".svg"="image/svg+xml"; ".ico"="image/x-icon"; ".swf"="application/x-shockwave-flash";
  ".wasm"="application/wasm"; ".txt"="text/plain"; ".pdf"="application/pdf";
  ".doc"="application/msword"
}

function Send-Head($stream, $code, $type, $len) {
  $h = "HTTP/1.1 " + $code + "`r`nContent-Type: " + $type + "`r`nContent-Length: " + $len + "`r`nConnection: close`r`n`r`n"
  $b = [System.Text.Encoding]::ASCII.GetBytes($h)
  $stream.Write($b, 0, $b.Length)
}

$listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $Port)
$listener.Start()
Write-Host ("  Serwer isleyar: http://localhost:{0}/index.htm" -f $Port)
Write-Host "  Yapmak ucin Ctrl+C basyn ya-da su penjirani yapyn."

while ($true) {
  $client = $listener.AcceptTcpClient()
  try {
    $stream = $client.GetStream()
    $stream.ReadTimeout = 10000
    $stream.WriteTimeout = 30000

    # Sorag setirini bayt-bayt okayas: StreamReader ozunin bufferine
    # galan maglumaty hem yuwudyar, sol sebapli ulanylmayar.
    $sb = New-Object System.Text.StringBuilder
    while ($true) {
      $c = $stream.ReadByte()
      if ($c -lt 0 -or $c -eq 10) { break }
      if ($c -ne 13) { [void]$sb.Append([char]$c) }
    }
    $req = $sb.ToString()

    if ($req -match '^(?:GET|HEAD)\s+(\S+)') {
      $target = $matches[1]
      $path = $target.Split("?")[0].Split("#")[0]
      $path = [System.Uri]::UnescapeDataString($path)
      if ($path -eq "/") { $path = "/index.htm" }
      $rel = $path.TrimStart("/").Replace("/", "\")

      $full = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($root, $rel))

      if (-not $full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        Send-Head $stream "403 Forbidden" "text/plain" 0
      } elseif (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - tapylmady: " + $path)
        Send-Head $stream "404 Not Found" "text/plain; charset=utf-8" $msg.Length
        $stream.Write($msg, 0, $msg.Length)
      } else {
        $ext = [System.IO.Path]::GetExtension($full).ToLower()
        $ct = $mime[$ext]
        if (-not $ct) { $ct = "application/octet-stream" }
        if ($ct.StartsWith("text/") -or $ct -eq "application/javascript") { $ct = $ct + "; charset=utf-8" }

        $fs = New-Object System.IO.FileStream($full, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
        try {
          Send-Head $stream "200 OK" $ct $fs.Length
          $buf = New-Object byte[] 65536
          while ($true) {
            $n = $fs.Read($buf, 0, $buf.Length)
            if ($n -le 0) { break }
            $stream.Write($buf, 0, $n)
          }
        } finally { $fs.Close() }
      }
      $stream.Flush()
    }
  } catch {
    # Brauzer baglanysygy yarym yolda kesse - indiki sorag bilen dowam edyas.
  } finally {
    $client.Close()
  }
}
