# ClickBite Upload Keystore Generator for Google Play Release
# Usage: powershell -ExecutionPolicy Bypass -File scripts/generate_upload_keystore.ps1

$keystorePath = Join-Path $PSScriptRoot "..\android\app\upload-keystore.jks"
$propertiesPath = Join-Path $PSScriptRoot "..\android\key.properties"

if (Test-Path $keystorePath) {
    Write-Host "Keystore already exists at: $keystorePath" -ForegroundColor Yellow
} else {
    Write-Host "Generating release upload keystore for ClickBite..." -ForegroundColor Cyan
    
    # Locate keytool
    $keytool = "keytool"
    if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
        if (Test-Path "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe") {
            $keytool = "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe"
        } elseif (Test-Path "C:\Program Files\Java\jdk-25.0.4\bin\keytool.exe") {
            $keytool = "C:\Program Files\Java\jdk-25.0.4\bin\keytool.exe"
        }
    }

    & $keytool -genkeypair -v `
        -keystore $keystorePath `
        -storetype PKCS12 `
        -alias clickbite-upload `
        -keyalg RSA `
        -keysize 2048 `
        -validity 10000 `
        -storepass "ClickBite2026Secure!" `
        -keypass "ClickBite2026Secure!" `
        -dname "CN=ClickBite, OU=Mobile, O=LexTech GH, L=Konongo, ST=Ashanti, C=GH"

    Write-Host "Generated $keystorePath successfully." -ForegroundColor Green
}

# Generate android/key.properties
$keyPropsContent = @"
keyAlias=clickbite-upload
keyPassword=ClickBite2026Secure!
storeFile=upload-keystore.jks
storePassword=ClickBite2026Secure!
"@

Set-Content -Path $propertiesPath -Value $keyPropsContent -Encoding utf8
Write-Host "Generated $propertiesPath" -ForegroundColor Green
Write-Host "Keystore and signing configuration are ready for release builds." -ForegroundColor Green
