@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo ╔══════════════════════════════════════════════════════════════════╗
echo ║                                                                  ║
echo ║     ██████╗██╗     ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗   ║
echo ║    ██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗  ║
echo ║    ██║     ██║     █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝  ║
echo ║    ██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔═══╝   ║
echo ║    ╚██████╗███████╗███████╗██║  ██║██║ ╚████║╚██████╔╝██║       ║
echo ║     ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝       ║
echo ║                                                                  ║
echo ║          CHAPTER 6: RATE LIMITING - CLEANUP                      ║
echo ║          Removing Rate Limit Configuration                       ║
echo ║                                                                  ║
echo ╚══════════════════════════════════════════════════════════════════╝
echo.

:: ─────────────────────────────────────────────
:: STEP 1: Delete the EnvoyFilter
:: ─────────────────────────────────────────────
echo ═══════════════════════════════════════════════════════════════
echo   STEP 1: Delete Rate Limit EnvoyFilter
echo ═══════════════════════════════════════════════════════════════
echo.
echo [*] Removing local rate limit EnvoyFilter...
kubectl delete -f "%~dp0local-ratelimit.yaml" --ignore-not-found
echo.
echo [✓] EnvoyFilter deleted.
echo.

:: ─────────────────────────────────────────────
:: STEP 2: Verify cleanup
:: ─────────────────────────────────────────────
echo ═══════════════════════════════════════════════════════════════
echo   STEP 2: Verify Cleanup
echo ═══════════════════════════════════════════════════════════════
echo.
echo [*] Checking for remaining EnvoyFilters in istio-system...
kubectl get envoyfilter -n istio-system 2>nul
echo.
echo [*] Waiting for Envoy to remove the filter...
timeout /t 5 /nobreak >nul
echo.
echo [*] Verifying productpage responds without rate limiting...
kubectl exec deploy/ratings-v1 -c ratings -- curl -s -o /dev/null -w "HTTP Status: %%{http_code}" http://productpage:9080/productpage 2>nul
echo.
echo.
echo [✓] Rate limiting has been removed.
echo.

:: ─────────────────────────────────────────────
:: Complete
:: ─────────────────────────────────────────────
echo ═══════════════════════════════════════════════════════════════
echo   ✓ CLEANUP COMPLETE
echo ═══════════════════════════════════════════════════════════════
echo.
echo   All Chapter 6 resources have been removed:
echo   • EnvoyFilter: productpage-ratelimit  [DELETED]
echo   • productpage is now accepting all requests without limits
echo.
echo ═══════════════════════════════════════════════════════════════
echo   Press any key to exit...
echo ═══════════════════════════════════════════════════════════════
pause >nul
