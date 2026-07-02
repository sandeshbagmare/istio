@echo off
title Chapter 04 - Fault Injection
color 0B
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo.
echo  ============================================================
echo   CHAPTER 04 : FAULT INJECTION (chaos engineering in config)
echo   Break a service on purpose to test resilience
echo  ============================================================
echo.

call "%~dp0..\common\_common.bat"
if errorlevel 1 ( pause & exit /b 1 )
echo  [OK] Cluster, Istio and Bookinfo are ready.
echo.

echo  Preparing an in-mesh client...
kubectl get deploy curl-client >nul 2>&1 || kubectl create deployment curl-client --image=curlimages/curl:latest -- sleep infinity
kubectl rollout status deploy/curl-client --timeout=120s
echo.

echo  ------------------------------------------------------------
echo   BASELINE : ratings is healthy
echo  ------------------------------------------------------------
kubectl exec deploy/curl-client -- sh -c "c=$(curl -s -o /dev/null -w %%{http_code} http://ratings:9080/ratings/0); t=$(curl -s -o /dev/null -w %%{time_total} http://ratings:9080/ratings/0); echo     status=$c   latency=${t}s"
echo.

echo  ------------------------------------------------------------
echo   DEMO 1 : ABORT - inject HTTP 500 into 50%% of calls
echo  ------------------------------------------------------------
kubectl apply -f fault-abort.yaml
timeout /t 3 /nobreak >nul
kubectl exec deploy/curl-client -- sh -c "ok=0; e5=0; n=0; while [ $n -lt 20 ]; do c=$(curl -s -o /dev/null -w %%{http_code} http://ratings:9080/ratings/0); case $c in 200) ok=$(expr $ok + 1);; 500) e5=$(expr $e5 + 1);; esac; n=$(expr $n + 1); done; echo     HTTP-200=$ok   HTTP-500(injected)=$e5   [of 20 requests]"
echo.

echo  ------------------------------------------------------------
echo   DEMO 2 : DELAY - add a 3s delay to 100%% of calls
echo  ------------------------------------------------------------
kubectl apply -f fault-delay.yaml
timeout /t 3 /nobreak >nul
kubectl exec deploy/curl-client -- sh -c "t=$(curl -s -o /dev/null -w %%{time_total} http://ratings:9080/ratings/0); echo     one request now took ${t}s   [baseline was a few ms; expected ~3s]"
echo.

echo  ============================================================
echo   RESULT
echo  ------------------------------------------------------------
echo   You made a perfectly healthy service look broken and slow
echo   using ONLY Istio config - the ratings code was untouched.
echo   This is how you prove your timeouts, retries and circuit
echo   breakers actually work BEFORE a real outage tests them.
echo  ============================================================
echo.
echo  TIP: with the delay active, open the productpage - the
echo  "Book Reviews" panel shows an error where ratings should be:
echo    kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
echo    http://localhost:8080/productpage
echo.
echo  Opening the illustrated guide...
start "" "%~dp0guide.html"
echo.
echo  When finished, double-click cleanup.bat to remove the faults.
echo.
pause
