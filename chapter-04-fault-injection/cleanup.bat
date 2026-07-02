@echo off
title Chapter 04 - Cleanup
color 0E
cd /d "%~dp0"
echo.
echo  Cleaning up Chapter 04 (Fault Injection)...
kubectl delete virtualservice ratings --ignore-not-found
echo  [OK] Faults removed - ratings is healthy again.
echo.
pause
