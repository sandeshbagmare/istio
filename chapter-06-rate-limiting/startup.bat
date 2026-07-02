@echo off
title Chapter 06 - Rate Limiting
color 0B
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo.
echo  ============================================================
echo   CHAPTER 06 : RATE LIMITING
echo   Cap requests so nobody can overwhelm your service
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
echo   BEFORE : no rate limit - fire 20 requests at productpage
echo  ------------------------------------------------------------
kubectl exec deploy/curl-client -- sh -c "ok=0; rl=0; n=0; while [ $n -lt 20 ]; do c=$(curl -s -o /dev/null -w %%{http_code} http://productpage:9080/productpage); case $c in 200) ok=$(expr $ok + 1);; 429) rl=$(expr $rl + 1);; esac; n=$(expr $n + 1); done; echo     HTTP-200(allowed)=$ok   HTTP-429(limited)=$rl   [of 20]"
echo.

echo  Applying a local rate limit (burst of 5 per 60 seconds)...
kubectl apply -f local-ratelimit.yaml
echo   Waiting 5s for the EnvoyFilter to load into the sidecar...
timeout /t 5 /nobreak >nul
echo.

echo  ------------------------------------------------------------
echo   AFTER : same 20 requests, now rate limited
echo  ------------------------------------------------------------
kubectl exec deploy/curl-client -- sh -c "ok=0; rl=0; n=0; while [ $n -lt 20 ]; do c=$(curl -s -o /dev/null -w %%{http_code} http://productpage:9080/productpage); case $c in 200) ok=$(expr $ok + 1);; 429) rl=$(expr $rl + 1);; esac; n=$(expr $n + 1); done; echo     HTTP-200(allowed)=$ok   HTTP-429(limited)=$rl   [of 20]"
echo.

echo  ============================================================
echo   RESULT
echo  ------------------------------------------------------------
echo   Once the burst allowance is spent, extra requests get an
echo   immediate HTTP 429 "Too Many Requests" - the service is
echo   shielded from floods, scrapers and runaway clients.
echo.
echo   NOTE: Envoy's token bucket is per worker-thread, so the
echo   exact cut-off can vary by a few requests - the throttling
echo   behaviour is the point.
echo  ============================================================
echo.
echo  Opening the illustrated guide...
start "" "%~dp0guide.html"
echo.
echo  When finished, double-click cleanup.bat to remove the limit.
echo.
pause
