@echo off
title Chapter 02 - Canary Deployments
color 0B
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo.
echo  ============================================================
echo   CHAPTER 02 : CANARY DEPLOYMENTS (weighted traffic shifting)
echo   Roll out a new version to 10%% -^> 50%% -^> 100%% of users
echo  ============================================================
echo.

call "%~dp0..\common\_common.bat"
if errorlevel 1 ( pause & exit /b 1 )
echo  [OK] Cluster, Istio and Bookinfo are ready.
echo.

echo  Preparing an in-mesh client to measure the traffic split...
kubectl get deploy curl-client >nul 2>&1 || kubectl create deployment curl-client --image=curlimages/curl:latest -- sleep infinity
kubectl rollout status deploy/curl-client --timeout=120s
echo.

echo  ------------------------------------------------------------
echo   STEP 0 : baseline - 100%% of traffic on reviews v1
echo  ------------------------------------------------------------
kubectl apply -f reviews-all-v1.yaml
timeout /t 3 /nobreak >nul
call :sample 50
echo.

echo  ------------------------------------------------------------
echo   STEP 1 : release v3 to 10%% of users (the "canary")
echo  ------------------------------------------------------------
kubectl apply -f reviews-canary-90-10.yaml
timeout /t 3 /nobreak >nul
call :sample 50
echo.

echo  ------------------------------------------------------------
echo   STEP 2 : v3 looks healthy - widen to 50/50
echo  ------------------------------------------------------------
kubectl apply -f reviews-canary-50-50.yaml
timeout /t 3 /nobreak >nul
call :sample 50
echo.

echo  ------------------------------------------------------------
echo   STEP 3 : promote v3 to 100%% (rollout complete)
echo  ------------------------------------------------------------
kubectl apply -f reviews-canary-100-v3.yaml
timeout /t 3 /nobreak >nul
call :sample 50
echo.

echo  ============================================================
echo   RESULT
echo  ------------------------------------------------------------
echo   Watch how the counts moved from all-v1 to all-v3 as you
echo   changed nothing but a "weight" number. Istio's sidecars
echo   enforced the split with no redeploys and no downtime.
echo  ============================================================
echo.
echo  TIP: open the productpage and refresh to SEE it change:
echo    1^) In a new terminal:  kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
echo    2^) Browse to:          http://localhost:8080/productpage
echo       (reviews stars: none = v1, black = v2, red = v3)
echo.
echo  Opening the illustrated guide...
start "" "%~dp0guide.html"
echo.
echo  When finished, double-click cleanup.bat to reset routing.
echo.
pause
goto :eof

:sample
kubectl exec deploy/curl-client -- sh -c "v1=0; v2=0; v3=0; n=0; while [ $n -lt %1 ]; do r=$(curl -s http://reviews:9080/reviews/0); case $r in *reviews-v1*) v1=$(expr $v1 + 1);; *reviews-v2*) v2=$(expr $v2 + 1);; *reviews-v3*) v3=$(expr $v3 + 1);; esac; n=$(expr $n + 1); done; echo     reviews-v1[no stars]=$v1   reviews-v2[black]=$v2   reviews-v3[red]=$v3   [of %1 requests]"
exit /b 0
