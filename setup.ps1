# Flutter Gym App Setup Script
# Run this script to set up the project

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Camalig Fitness Gym - Flutter Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter installation
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "✓ Flutter is installed: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Navigate to project directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Installing Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Checking for image assets..." -ForegroundColor Yellow

$imagesPath = Join-Path $scriptPath "assets\images"
$othersImagesPath = Join-Path (Split-Path -Parent $scriptPath) "others\images"

$requiredImages = @("logo.png", "login.jpg", "forgot-password.jpg", "signup-1.jpg", "signup-2.jpg")

foreach ($image in $requiredImages) {
    $sourcePath = Join-Path $othersImagesPath $image
    $destPath = Join-Path $imagesPath $image
    
    if (Test-Path $sourcePath) {
        if (!(Test-Path $destPath)) {
            Copy-Item $sourcePath $destPath
            Write-Host "✓ Copied $image" -ForegroundColor Green
        } else {
            Write-Host "✓ $image already exists" -ForegroundColor Green
        }
    } else {
        Write-Host "✗ $image not found in others/images/" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update API URL in lib/utils/constants.dart" -ForegroundColor White
Write-Host "2. Start your development server (XAMPP)" -ForegroundColor White
Write-Host "3. Run the app: flutter run" -ForegroundColor White
Write-Host ""
Write-Host "For Android Emulator, use: http://10.0.2.2/camalig/web/mobile/" -ForegroundColor Cyan
Write-Host "For physical device, use your computer's IP address" -ForegroundColor Cyan
Write-Host ""
