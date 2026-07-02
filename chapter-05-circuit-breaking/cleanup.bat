@echo off
title Chapter 05 - Cleanup
color 0E
cd /d "%~dp0"
echo.
echo  Cleaning up Chapter 05 (Circuit Breaking)...
kubectl delete -f circuit-breaker.yaml --ignore-not-found
kubectl delete -f fortio-deploy.yaml --ignore-not-found
kubectl delete -f httpbin-deploy.yaml --ignore-not-found
echo  [OK] Circuit breaker, fortio and httpbin removed.
echo.
pause
