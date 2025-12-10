# Script to get SHA-1 fingerprint for Firebase Google Sign-In setup
# Run this script to get your debug keystore SHA-1 fingerprint

Write-Host "Getting SHA-1 fingerprint from debug keystore..." -ForegroundColor Cyan
Write-Host ""

$keystorePath = "$env:USERPROFILE\.android\debug.keystore"

if (Test-Path $keystorePath) {
    Write-Host "Found debug keystore at: $keystorePath" -ForegroundColor Green
    Write-Host ""
    Write-Host "SHA-1 Fingerprint:" -ForegroundColor Yellow
    Write-Host "==================" -ForegroundColor Yellow
    
    # Get SHA-1 fingerprint
    $result = keytool -list -v -keystore $keystorePath -alias androiddebugkey -storepass android -keypass android 2>&1
    
    # Extract SHA-1 line
    $sha1Line = $result | Select-String -Pattern "SHA1:"
    
    if ($sha1Line) {
        Write-Host $sha1Line -ForegroundColor Green
        Write-Host ""
        Write-Host "Copy the SHA-1 value above and add it to Firebase Console:" -ForegroundColor Cyan
        Write-Host "1. Go to Firebase Console > Project Settings" -ForegroundColor White
        Write-Host "2. Scroll to 'Your apps' section" -ForegroundColor White
        Write-Host "3. Click on your Android app" -ForegroundColor White
        Write-Host "4. Click 'Add fingerprint'" -ForegroundColor White
        Write-Host "5. Paste the SHA-1 value (format: AA:BB:CC:DD:EE:FF...)" -ForegroundColor White
        Write-Host "6. Click Save" -ForegroundColor White
        Write-Host "7. Download the new google-services.json file" -ForegroundColor White
        Write-Host "8. Replace android/app/google-services.json with the new file" -ForegroundColor White
    } else {
        Write-Host "Could not extract SHA-1 fingerprint. Full output:" -ForegroundColor Red
        Write-Host $result
    }
} else {
    Write-Host "Debug keystore not found at: $keystorePath" -ForegroundColor Red
    Write-Host ""
    Write-Host "The debug keystore will be created automatically when you:" -ForegroundColor Yellow
    Write-Host "1. Build your Flutter app for the first time, OR" -ForegroundColor White
    Write-Host "2. Run: flutter build apk --debug" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

