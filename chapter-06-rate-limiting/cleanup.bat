@echo off
title Chapter 06 - Cleanup
color 0E
cd /d "%~dp0"
echo.
echo  Cleaning up Chapter 06 (Rate Limiting)...
kubectl delete -f local-ratelimit.yaml --ignore-not-found
echo  [OK] Rate limit removed - productpage accepts all requests again.
echo.
pause
