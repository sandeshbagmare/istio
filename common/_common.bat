@echo off
:: ============================================================
:: Shared prerequisite checks for every chapter's startup.bat
:: Called as:  call "%~dp0..\common\_common.bat" || exit /b 1
:: Exits 1 (with a helpful message) if the lab isn't ready.
:: ============================================================
where kubectl >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ERROR] kubectl was not found on your PATH.
  echo           Please run the top-level setup.bat first.
  echo.
  exit /b 1
)

kubectl cluster-info >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ERROR] No Kubernetes cluster is reachable.
  echo           Start Rancher Desktop / Docker Desktop, then run setup.bat.
  echo.
  exit /b 1
)

kubectl get namespace istio-system >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ERROR] Istio is not installed in this cluster.
  echo           Please run the top-level setup.bat first.
  echo.
  exit /b 1
)

kubectl get deployment productpage-v1 >nul 2>&1
if errorlevel 1 (
  echo.
  echo   [ERROR] The Bookinfo sample app is not deployed.
  echo           Please run the top-level setup.bat first.
  echo.
  exit /b 1
)

exit /b 0
