# Pocket Court - One command startup script
# Usage: .\start.ps1

Write-Host "Starting Pocket Court..." -ForegroundColor Cyan

# 1. Start backend
Write-Host "`n[1/3] Starting backend..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\pocket-court-backend'; npm start" -WindowStyle Normal

Start-Sleep -Seconds 3

# 2. Start ngrok and capture URL
Write-Host "[2/3] Starting ngrok tunnel..." -ForegroundColor Yellow
$ngrokJob = Start-Process powershell -ArgumentList "-NoExit", "-Command", "ngrok http 5000" -WindowStyle Normal -PassThru

Start-Sleep -Seconds 4

# 3. Fetch ngrok public URL from its local API
try {
    $ngrokApi = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -ErrorAction Stop
    $publicUrl = ($ngrokApi.tunnels | Where-Object { $_.proto -eq "https" }).public_url

    if ($publicUrl) {
        Write-Host "[3/3] ngrok URL: $publicUrl" -ForegroundColor Green

        # Patch api_service.dart with the new URL
        $filePath = "$PSScriptRoot\pocket_court_app\lib\services\api_service.dart"
        $content = Get-Content $filePath -Raw
        $content = $content -replace "static const String baseUrl = '.*';", "static const String baseUrl = '$publicUrl/api';"
        Set-Content $filePath $content

        Write-Host "api_service.dart updated automatically!" -ForegroundColor Green
        Write-Host "`nNow run: flutter run" -ForegroundColor Cyan
        Write-Host "Or press Enter to run flutter now..." -ForegroundColor White
        Read-Host

        Set-Location "$PSScriptRoot\pocket_court_app"
        flutter run
    } else {
        Write-Host "Could not get ngrok URL. Open http://localhost:4040 to find it manually." -ForegroundColor Red
    }
} catch {
    Write-Host "ngrok API not ready. Make sure ngrok is installed: npm install -g ngrok" -ForegroundColor Red
    Write-Host "Then run: ngrok config add-authtoken YOUR_TOKEN" -ForegroundColor Red
}
