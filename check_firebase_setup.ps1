# Firebase Android Configuration Checker
# Run this script to verify Firebase setup

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Firebase Android Configuration Checker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: google-services.json file
Write-Host "[1/4] Checking for google-services.json..." -ForegroundColor Yellow
$googleServicesPath = "android/app/google-services.json"
if (Test-Path $googleServicesPath) {
    Write-Host "  [OK] google-services.json found" -ForegroundColor Green
    $fileContent = Get-Content $googleServicesPath -Raw
    if ($fileContent -match 'package_name') {
        Write-Host "  [OK] File appears to be valid JSON" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] File exists but may be invalid" -ForegroundColor Yellow
        $allGood = $false
    }
} else {
    Write-Host "  [FAIL] google-services.json NOT FOUND" -ForegroundColor Red
    Write-Host "    Expected location: android/app/google-services.json" -ForegroundColor Gray
    $allGood = $false
}
Write-Host ""

# Check 2: Google Services plugin in build.gradle.kts
Write-Host "[2/4] Checking build.gradle.kts files..." -ForegroundColor Yellow
$appBuildFile = "android/app/build.gradle.kts"
$appBuildContent = ""
if (Test-Path $appBuildFile) {
    $appBuildContent = Get-Content $appBuildFile -Raw
    if ($appBuildContent -match "com.google.gms.google-services") {
        Write-Host "  [OK] Google Services plugin found in app/build.gradle.kts" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Google Services plugin NOT found in app/build.gradle.kts" -ForegroundColor Red
        $allGood = $false
    }
} else {
    Write-Host "  [FAIL] app/build.gradle.kts not found" -ForegroundColor Red
    $allGood = $false
}

$projectBuildFile = "android/build.gradle.kts"
if (Test-Path $projectBuildFile) {
    $projectBuildContent = Get-Content $projectBuildFile -Raw
    if ($projectBuildContent -match "google-services") {
        Write-Host "  [OK] Google Services dependency found in build.gradle.kts" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] Google Services dependency not found (may use plugin management)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [INFO] build.gradle.kts not found (using settings.gradle.kts)" -ForegroundColor Yellow
}
Write-Host ""

# Check 3: Firebase dependencies in pubspec.yaml
Write-Host "[3/4] Checking pubspec.yaml for Firebase dependencies..." -ForegroundColor Yellow
$pubspecFile = "pubspec.yaml"
if (Test-Path $pubspecFile) {
    $pubspecContent = Get-Content $pubspecFile -Raw
    if ($pubspecContent -match "firebase_core" -and $pubspecContent -match "firebase_database") {
        Write-Host "  [OK] Firebase dependencies found in pubspec.yaml" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Firebase dependencies missing in pubspec.yaml" -ForegroundColor Red
        $allGood = $false
    }
} else {
    Write-Host "  [FAIL] pubspec.yaml not found" -ForegroundColor Red
    $allGood = $false
}
Write-Host ""

# Check 4: Package name consistency
Write-Host "[4/4] Checking package name..." -ForegroundColor Yellow
if (Test-Path $googleServicesPath) {
    try {
        $jsonContent = Get-Content $googleServicesPath -Raw | ConvertFrom-Json
        $packageName = $jsonContent.project_info.android_client_info.package_name
        Write-Host "  Package name in google-services.json: $packageName" -ForegroundColor Gray
        
        if ($appBuildContent -match "applicationId\s*=\s*`"$packageName`"") {
            Write-Host "  [OK] Package names match" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] Package names may not match" -ForegroundColor Yellow
            Write-Host "    Check: applicationId in build.gradle.kts should match google-services.json" -ForegroundColor Gray
        }
    } catch {
        Write-Host "  [WARN] Could not parse google-services.json" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [INFO] Cannot check package name (google-services.json missing)" -ForegroundColor Yellow
}
Write-Host ""

# Final Summary
Write-Host "========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "[SUCCESS] Firebase appears to be configured!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Run: flutter pub get" -ForegroundColor White
    Write-Host "2. Run: flutter clean" -ForegroundColor White
    Write-Host "3. Run: flutter build apk --debug" -ForegroundColor White
} else {
    Write-Host "[ACTION REQUIRED] Firebase configuration incomplete" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please follow these steps:" -ForegroundColor Cyan
    Write-Host "1. Download google-services.json from Firebase Console" -ForegroundColor White
    Write-Host "2. Place it in: android/app/google-services.json" -ForegroundColor White
    Write-Host "3. See FIREBASE_ANDROID_SETUP.md for detailed instructions" -ForegroundColor White
}
Write-Host "========================================" -ForegroundColor Cyan

