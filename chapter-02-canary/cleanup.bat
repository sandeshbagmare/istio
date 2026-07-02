@echo off
title Chapter 02 - Cleanup
color 0E
cd /d "%~dp0"
echo.
echo  Cleaning up Chapter 02 (Canary)...
echo  ------------------------------------------------------------
kubectl delete virtualservice reviews --ignore-not-found
echo.
echo  [OK] Reviews routing rule removed. Bookinfo now load-balances
echo       across all versions again (default behaviour).
echo.
pause
