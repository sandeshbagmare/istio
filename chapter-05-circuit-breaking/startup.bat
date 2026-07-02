@echo off
title Chapter 05 - Circuit Breaking
color 0B
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo.
echo  ============================================================
echo   CHAPTER 05 : CIRCUIT BREAKING
echo   Shed load instead of letting a service melt down
echo  ============================================================
echo.

call "%~dp0..\common\_common.bat"
if errorlevel 1 ( pause & exit /b 1 )
echo  [OK] Cluster, Istio and Bookinfo are ready.
echo.

echo  [1/4] Deploying the target service (httpbin) and load tool (fortio)...
kubectl apply -f httpbin-deploy.yaml
kubectl apply -f fortio-deploy.yaml
kubectl rollout status deploy/httpbin --timeout=150s
kubectl rollout status deploy/fortio  --timeout=150s
echo.

echo  [2/4] BASELINE - no circuit breaker, 3 parallel callers...
echo  ------------------------------------------------------------
echo   (httpbin handles the concurrency fine - expect ~100%% code 200)
kubectl exec deploy/fortio -c fortio -- fortio load -c 3 -qps 0 -n 30 http://httpbin:8000/get 2>&1 | findstr /C:"Code " /C:"Sockets used"
echo.

echo  [3/4] Applying the circuit breaker (max 1 conn, 1 pending)...
echo  ------------------------------------------------------------
kubectl apply -f circuit-breaker.yaml
timeout /t 3 /nobreak >nul
echo.

echo  [4/4] SAME test WITH the circuit breaker, 3 parallel callers...
echo  ------------------------------------------------------------
echo   (calls beyond the limit are rejected fast with 503)
kubectl exec deploy/fortio -c fortio -- fortio load -c 3 -qps 0 -n 30 http://httpbin:8000/get 2>&1 | findstr /C:"Code " /C:"Sockets used"
echo.

echo  ============================================================
echo   RESULT
echo  ------------------------------------------------------------
echo   With the breaker OPEN, excess concurrent calls get an
echo   immediate 503 instead of piling onto an overloaded service.
echo   Failing fast protects httpbin AND frees the caller quickly -
echo   this is what stops one hot service from cascading into a
echo   full outage.
echo.
echo   Try raising concurrency (-c 5, -c 10) to trip it harder.
echo  ============================================================
echo.
echo  Opening the illustrated guide...
start "" "%~dp0guide.html"
echo.
echo  When finished, double-click cleanup.bat to remove everything.
echo.
pause
