@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

cls
echo.
echo  ╔══════════════════════════════════════════════════════════════════╗
echo  ║                                                                ║
echo  ║    ██████╗██╗     ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗  ║
echo  ║   ██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗ ║
echo  ║   ██║     ██║     █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝ ║
echo  ║   ██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔═══╝  ║
echo  ║   ╚██████╗███████╗███████╗██║  ██║██║ ╚████║╚██████╔╝██║      ║
echo  ║    ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚═╝      ║
echo  ║                                                                ║
echo  ║          CHAPTER 5: CIRCUIT BREAKING - CLEANUP                 ║
echo  ║                                                                ║
echo  ╚══════════════════════════════════════════════════════════════════╝
echo.

:: ──────────────────────────────────────────────────────────────
:: Step 1: Delete Circuit Breaker DestinationRule
:: ──────────────────────────────────────────────────────────────
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  Removing Circuit Breaker DestinationRule                │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Deleting httpbin-circuit-breaker DestinationRule...
kubectl delete destinationrule httpbin-circuit-breaker --ignore-not-found=true
echo  [✓] DestinationRule removed
echo.

:: ──────────────────────────────────────────────────────────────
:: Step 2: Delete httpbin deployment and service
:: ──────────────────────────────────────────────────────────────
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  Removing httpbin Deployment and Service                 │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Deleting httpbin deployment...
kubectl delete deployment httpbin --ignore-not-found=true
echo  [*] Deleting httpbin service...
kubectl delete service httpbin --ignore-not-found=true
echo  [✓] httpbin resources removed
echo.

:: ──────────────────────────────────────────────────────────────
:: Step 3: Delete fortio deployment and service
:: ──────────────────────────────────────────────────────────────
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  Removing Fortio Deployment and Service                  │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Deleting fortio deployment...
kubectl delete deployment fortio --ignore-not-found=true
echo  [*] Deleting fortio service...
kubectl delete service fortio --ignore-not-found=true
echo  [✓] Fortio resources removed
echo.

:: ──────────────────────────────────────────────────────────────
:: Step 4: Verify cleanup
:: ──────────────────────────────────────────────────────────────
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  Verifying Cleanup                                       │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Checking remaining resources...
echo.
echo  --- Pods ---
kubectl get pods -l "app in (httpbin,fortio)" 2>nul
echo.
echo  --- Services ---
kubectl get svc -l "app in (httpbin,fortio)" 2>nul
echo.
echo  --- DestinationRules ---
kubectl get destinationrule httpbin-circuit-breaker 2>nul
echo.

echo.
echo  ╔══════════════════════════════════════════════════════════════════╗
echo  ║                                                                ║
echo  ║   ✓  CLEANUP COMPLETE!                                        ║
echo  ║                                                                ║
echo  ║   All Chapter 5 resources have been removed:                   ║
echo  ║   • httpbin-circuit-breaker DestinationRule                    ║
echo  ║   • httpbin Deployment + Service                               ║
echo  ║   • fortio Deployment + Service                                ║
echo  ║                                                                ║
echo  ╚══════════════════════════════════════════════════════════════════╝
echo.
pause
endlocal
