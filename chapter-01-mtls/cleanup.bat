@echo off
title Chapter 01 - Cleanup
color 0E
cd /d "%~dp0"
echo.
echo  Cleaning up Chapter 01 (mTLS)...
echo  ------------------------------------------------------------
kubectl delete -f peer-auth-strict.yaml --ignore-not-found
kubectl delete -f mtls-test-clients.yaml --ignore-not-found
echo.
echo  [OK] STRICT mTLS policy removed and test clients deleted.
echo       The 'default' namespace is back to PERMISSIVE mode.
echo.
pause
