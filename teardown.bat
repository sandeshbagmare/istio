@echo off
title Istio Learning Lab - Teardown
color 0C
echo.
echo  ⚠️  TEARDOWN - This will remove Minikube + all data
echo.
set /p CONFIRM=Type YES to continue:
if /i not "%CONFIRM%"=="YES" (
  echo Cancelled.
  pause
  exit /b 0
)
echo.
echo Stopping port-forwards...
taskkill /F /IM kubectl.exe /T >nul 2>&1

echo Deleting Minikube cluster...
minikube delete --all

echo.
echo Done! Minikube and all Istio data removed.
echo Run setup.bat to start fresh.
pause
