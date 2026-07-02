@echo off
setlocal enabledelayedexpansion
title Istio Learning Lab - Run All Chapters
color 0B
chcp 65001 >nul 2>&1

echo.
echo  ===========================================================
echo  ==                                                       ==
echo  ==       ISTIO LEARNING LAB - VALIDATE ALL CHAPTERS      ==
echo  ==              Checking 10 Demo Chapters                 ==
echo  ==                                                       ==
echo  ===========================================================
echo.

set "ROOT=%~dp0"
set PASS=0
set FAIL=0
set TOTAL=10

:: ============================================================
:: CHECK PREREQUISITES
:: ============================================================
echo  [PREREQ] Checking prerequisites...
echo  ----------------------------------------

minikube status 2>nul | findstr /i "Running" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: Minikube is not running!
    echo  Please run setup.bat first.
    echo.
    pause
    exit /b 1
)
echo  [OK] Minikube is running

kubectl get namespace istio-system >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: Istio is not installed!
    echo  Please run setup.bat first.
    echo.
    pause
    exit /b 1
)
echo  [OK] Istio is installed

kubectl get deployment productpage-v1 >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: Bookinfo app is not deployed!
    echo  Please run setup.bat first.
    echo.
    pause
    exit /b 1
)
echo  [OK] Bookinfo is deployed
echo.

:: ============================================================
:: VALIDATE CHAPTER STRUCTURE
:: ============================================================
echo  [VALIDATE] Checking all chapter directories and files...
echo  ============================================================
echo.

:: Chapter 1: mTLS
echo  --- Chapter 01: Mutual TLS (mTLS) ---
set CH1_OK=1
if not exist "%ROOT%chapter-01-mtls\startup.bat" (
    echo    [MISSING] startup.bat
    set CH1_OK=0
)
if not exist "%ROOT%chapter-01-mtls\guide.html" (
    echo    [MISSING] guide.html
    set CH1_OK=0
)
if not exist "%ROOT%chapter-01-mtls\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH1_OK=0
)
if not exist "%ROOT%chapter-01-mtls\peer-auth-strict.yaml" (
    echo    [MISSING] peer-auth-strict.yaml
    set CH1_OK=0
)
if !CH1_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: Chapter 2: Canary
echo  --- Chapter 02: Canary Deployments ---
set CH2_OK=1
if not exist "%ROOT%chapter-02-canary\startup.bat" (
    echo    [MISSING] startup.bat
    set CH2_OK=0
)
if not exist "%ROOT%chapter-02-canary\guide.html" (
    echo    [MISSING] guide.html
    set CH2_OK=0
)
if not exist "%ROOT%chapter-02-canary\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH2_OK=0
)
if not exist "%ROOT%chapter-02-canary\destination-rule-reviews.yaml" (
    echo    [MISSING] destination-rule-reviews.yaml
    set CH2_OK=0
)
if !CH2_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: Chapter 3: Traffic Routing
echo  --- Chapter 03: Intelligent Traffic Routing ---
set CH3_OK=1
if not exist "%ROOT%chapter-03-traffic-routing\startup.bat" (
    echo    [MISSING] startup.bat
    set CH3_OK=0
)
if not exist "%ROOT%chapter-03-traffic-routing\guide.html" (
    echo    [MISSING] guide.html
    set CH3_OK=0
)
if not exist "%ROOT%chapter-03-traffic-routing\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH3_OK=0
)
if !CH3_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: Chapter 4: Fault Injection
echo  --- Chapter 04: Fault Injection ---
set CH4_OK=1
if not exist "%ROOT%chapter-04-fault-injection\startup.bat" (
    echo    [MISSING] startup.bat
    set CH4_OK=0
)
if not exist "%ROOT%chapter-04-fault-injection\guide.html" (
    echo    [MISSING] guide.html
    set CH4_OK=0
)
if not exist "%ROOT%chapter-04-fault-injection\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH4_OK=0
)
if !CH4_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: Chapter 5: Circuit Breaking
echo  --- Chapter 05: Circuit Breaking ---
set CH5_OK=1
if not exist "%ROOT%chapter-05-circuit-breaking\startup.bat" (
    echo    [MISSING] startup.bat
    set CH5_OK=0
)
if not exist "%ROOT%chapter-05-circuit-breaking\guide.html" (
    echo    [MISSING] guide.html
    set CH5_OK=0
)
if not exist "%ROOT%chapter-05-circuit-breaking\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH5_OK=0
)
if !CH5_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: Chapter 6: Rate Limiting
echo  --- Chapter 06: Rate Limiting ---
set CH6_OK=1
if not exist "%ROOT%chapter-06-rate-limiting\startup.bat" (
    echo    [MISSING] startup.bat
    set CH6_OK=0
)
if not exist "%ROOT%chapter-06-rate-limiting\guide.html" (
    echo    [MISSING] guide.html
    set CH6_OK=0
)
if not exist "%ROOT%chapter-06-rate-limiting\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH6_OK=0
)
if !CH6_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: Chapter 7: Kiali
echo  --- Chapter 07: Kiali Dashboard ---
set CH7_OK=1
if not exist "%ROOT%chapter-07-kiali-dashboard\startup.bat" (
    echo    [MISSING] startup.bat
    set CH7_OK=0
)
if not exist "%ROOT%chapter-07-kiali-dashboard\guide.html" (
    echo    [MISSING] guide.html
    set CH7_OK=0
)
if not exist "%ROOT%chapter-07-kiali-dashboard\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH7_OK=0
)
if !CH7_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: Chapter 8: Grafana & Prometheus
echo  --- Chapter 08: Grafana and Prometheus ---
set CH8_OK=1
if not exist "%ROOT%chapter-08-grafana-prometheus\startup.bat" (
    echo    [MISSING] startup.bat
    set CH8_OK=0
)
if not exist "%ROOT%chapter-08-grafana-prometheus\guide.html" (
    echo    [MISSING] guide.html
    set CH8_OK=0
)
if not exist "%ROOT%chapter-08-grafana-prometheus\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH8_OK=0
)
if !CH8_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: Chapter 9: Jaeger
echo  --- Chapter 09: Distributed Tracing (Jaeger) ---
set CH9_OK=1
if not exist "%ROOT%chapter-09-jaeger-tracing\startup.bat" (
    echo    [MISSING] startup.bat
    set CH9_OK=0
)
if not exist "%ROOT%chapter-09-jaeger-tracing\guide.html" (
    echo    [MISSING] guide.html
    set CH9_OK=0
)
if not exist "%ROOT%chapter-09-jaeger-tracing\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH9_OK=0
)
if !CH9_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: Chapter 10: Traffic Mirroring
echo  --- Chapter 10: Traffic Mirroring ---
set CH10_OK=1
if not exist "%ROOT%chapter-10-traffic-mirroring\startup.bat" (
    echo    [MISSING] startup.bat
    set CH10_OK=0
)
if not exist "%ROOT%chapter-10-traffic-mirroring\guide.html" (
    echo    [MISSING] guide.html
    set CH10_OK=0
)
if not exist "%ROOT%chapter-10-traffic-mirroring\cleanup.bat" (
    echo    [MISSING] cleanup.bat
    set CH10_OK=0
)
if !CH10_OK! equ 1 (
    echo    [PASS] All files present
    set /a PASS+=1
) else (
    echo    [FAIL] Missing files
    set /a FAIL+=1
)
echo.

:: ============================================================
:: SUMMARY
:: ============================================================
echo  ===========================================================
echo.
if !FAIL! equ 0 (
    echo    ALL !PASS!/!TOTAL! CHAPTERS VALIDATED SUCCESSFULLY!
    echo.
    echo  ===========================================================
    echo.
    echo  All chapters are ready! To run a demo:
    echo.
    echo    1. Open the chapter folder
    echo    2. Double-click startup.bat
    echo    3. Follow the on-screen instructions
    echo    4. When done, run cleanup.bat
    echo.
    echo  Or open index.html for the full interactive guide!
    echo.
) else (
    echo    VALIDATION: !PASS! passed, !FAIL! failed out of !TOTAL!
    echo.
    echo  ===========================================================
    echo.
    echo  Some chapters have missing files. Please check above.
    echo.
)

echo  Opening index.html...
start "" "%ROOT%index.html"
echo.
pause
