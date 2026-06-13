@echo off
echo Starting Pocket Court Backend...
cd pocket-court-backend
start cmd /k "npm start"
cd ..

echo Setting up ADB reverse tunnel...
timeout /t 3 /nobreak >nul
adb reverse tcp:5000 tcp:5000

echo Launching Flutter app...
cd pocket_court_app
flutter run

pause
