# Portable Ruby Setup for Asteroids
$RubyZipUrl = "https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.1-x64-mingw-ucrt.zip"
$DestFolder = "ruby_portable"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Ruby Asteroids: Portable Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $DestFolder)) {
    Write-Host "[1/3] Downloading Portable Ruby (this may take a minute)..."
    Invoke-WebRequest -Uri $RubyZipUrl -OutFile "ruby.zip"
    
    Write-Host "[2/3] Extracting Ruby..."
    Expand-Archive -Path "ruby.zip" -DestinationPath $DestFolder
    
    # Move files up one level if they are nested inside another folder in the zip
    $SubFolder = Get-ChildItem -Path $DestFolder | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    if ($SubFolder) {
        Move-Item -Path "$($SubFolder.FullName)\*" -Destination $DestFolder
        Remove-Item $SubFolder.FullName
    }
    
    Remove-Item "ruby.zip"
} else {
    Write-Host "[INFO] Portable Ruby already exists."
}

Write-Host "[3/3] Installing game libraries (Gosu)..."
$RubyPath = Join-Path (Get-Location).Path "$DestFolder\binuby.exe"
$GemPath = Join-Path (Get-Location).Path "$DestFolder\bin\gem"

# Run gem install using the portable ruby
Start-Process -FilePath $RubyPath -ArgumentList "$GemPath install gosu --no-document" -Wait

Write-Host ""
Write-Host "DONE! You can now use 'play_portable.bat' to launch the game." -ForegroundColor Green
pause
