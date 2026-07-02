@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                                                                  ║
echo ║    ██████╗  █████╗ ████████╗███████╗                             ║
echo ║    ██╔══██╗██╔══██╗╚══██╔══╝██╔════╝                             ║
echo ║    ██████╔╝███████║   ██║   █████╗                               ║
echo ║    ██╔══██╗██╔══██║   ██║   ██╔══╝                               ║
echo ║    ██║  ██║██║  ██║   ██║   ███████╗                             ║
echo ║    ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝                             ║
echo ║                                                                  ║
echo ║    ██╗     ██╗███╗   ███╗██╗████████╗██╗███╗   ██╗ ██████╗       ║
echo ║    ██║     ██║████╗ ████║██║╚══██╔══╝██║████╗  ██║██╔════╝       ║
echo ║    ██║     ██║██╔████╔██║██║   ██║   ██║██╔██╗ ██║██║  ███╗      ║
echo ║    ██║     ██║██║╚██╔╝██║██║   ██║   ██║██║╚██╗██║██║   ██║      ║
echo ║    ███████╗██║██║ ╚═╝ ██║██║   ██║   ██║██║ ╚████║╚██████╔╝      ║
echo ║    ╚══════╝╚═╝╚═╝     ╚═╝╚═╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝       ║
echo ║                                                                  ║
echo ║          CHAPTER 6: RATE LIMITING                                ║
echo ║          Protect Services from Traffic Overload                  ║
echo ║                                                                  ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.

:: ─────────────────────────────────────────────
:: STEP 1: Verify productpage is running
:: ─────────────────────────────────────────────
echo ═══════════════════════════════════════════════════════════════
echo   STEP 1: Verify productpage is running
echo ═══════════════════════════════════════════════════════════════
echo.
echo [*] Checking productpage pod status...
kubectl get pod -l app=productpage -o wide
if !errorlevel! neq 0 (
    echo [ERROR] productpage pod not found. Please deploy BookInfo first.
    echo         Run: kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
    pause
    exit /b 1
)
echo.
echo [✓] productpage is running.
echo.

:: ─────────────────────────────────────────────
:: STEP 2: Apply the EnvoyFilter
:: ─────────────────────────────────────────────
echo ═══════════════════════════════════════════════════════════════
echo   STEP 2: Apply Local Rate Limit EnvoyFilter
echo ═══════════════════════════════════════════════════════════════
echo.
echo [*] Applying local rate limit filter to productpage...
echo     Config: 10 requests per 60 seconds (token bucket)
echo.
kubectl apply -f "%~dp0local-ratelimit.yaml"
if !errorlevel! neq 0 (
    echo [ERROR] Failed to apply EnvoyFilter.
    pause
    exit /b 1
)
echo.
echo [✓] EnvoyFilter applied successfully.
echo.

:: ─────────────────────────────────────────────
:: STEP 3: Wait for filter to take effect
:: ─────────────────────────────────────────────
echo ═══════════════════════════════════════════════════════════════
echo   STEP 3: Waiting for filter to propagate...
echo ═══════════════════════════════════════════════════════════════
echo.
echo [*] Envoy sidecar needs a moment to pick up the new filter...
timeout /t 10 /nobreak
echo.
echo [✓] Filter should now be active.
echo.

:: ─────────────────────────────────────────────
:: STEP 4: Demo - Send rapid requests
:: ─────────────────────────────────────────────
echo ═══════════════════════════════════════════════════════════════
echo   STEP 4: Rate Limiting Demo - Rapid Fire Requests
echo ═══════════════════════════════════════════════════════════════
echo.
echo [*] Sending 15 rapid requests to productpage...
echo     Token bucket: max_tokens=10, fill_interval=60s
echo     Expected: First ~10 return 200 (OK), remaining return 429 (Too Many Requests)
echo.
echo ┌─────────┬────────────┬──────────────────────┐
echo │ Request │ HTTP Code  │ Status               │
echo ├─────────┼────────────┼──────────────────────┤

for /L %%i in (1,1,15) do (
    set "PADDING=  "
    if %%i LSS 10 set "PADDING=  "
    if %%i GEQ 10 set "PADDING= "

    for /f %%a in ('kubectl exec deploy/ratings-v1 -c ratings -- curl -s -o /dev/null -w "%%{http_code}" http://productpage:9080/productpage 2^>nul') do (
        set "CODE=%%a"
    )

    if "!CODE!"=="200" (
        echo │ !PADDING!%%i    │    !CODE!     │ ✓ Allowed              │
    ) else if "!CODE!"=="429" (
        echo │ !PADDING!%%i    │    !CODE!     │ ✗ Rate Limited          │
    ) else (
        echo │ !PADDING!%%i    │    !CODE!     │ ? Unknown               │
    )
)

echo └─────────┴────────────┴──────────────────────┘
echo.
echo [✓] Demo complete! Observe the transition from 200 → 429.
echo.

:: ─────────────────────────────────────────────
:: STEP 5: Show rate limit headers
:: ─────────────────────────────────────────────
echo ═══════════════════════════════════════════════════════════════
echo   STEP 5: Inspect Rate Limit Response Headers
echo ═══════════════════════════════════════════════════════════════
echo.
echo [*] Checking for x-local-rate-limit header...
echo.
kubectl exec deploy/ratings-v1 -c ratings -- curl -s -I http://productpage:9080/productpage 2>&1 | findstr /i "rate-limit HTTP"
echo.
echo [✓] The x-local-rate-limit: true header confirms the filter is active.
echo.

:: ─────────────────────────────────────────────
:: Complete - Open Guide
:: ─────────────────────────────────────────────
echo ═══════════════════════════════════════════════════════════════
echo   ✓ CHAPTER 6 DEMO COMPLETE
echo ═══════════════════════════════════════════════════════════════
echo.
echo   Rate limiting is now active on productpage!
echo   • Token Bucket: 10 requests / 60 seconds
echo   • Excess requests receive HTTP 429
echo   • Custom header: x-local-rate-limit: true
echo.
echo [*] Opening the Chapter 6 guide...
start "" "%~dp0guide.html"
echo.
echo ═══════════════════════════════════════════════════════════════
echo   Press any key to exit...
echo ═══════════════════════════════════════════════════════════════
pause >nul
