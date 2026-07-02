@echo off
title Chapter 03 - Content-Based Traffic Routing
color 0B
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo.
echo  ============================================================
echo   CHAPTER 03 : CONTENT-BASED TRAFFIC ROUTING
echo   Route by WHO the user is, not by percentages
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

echo  Applying the routing rule (jason -^> v2, everyone else -^> v1)...
kubectl apply -f reviews-route-by-user.yaml
timeout /t 3 /nobreak >nul
echo.

echo  ------------------------------------------------------------
echo   TEST A : an ANONYMOUS user (no end-user header)
echo  ------------------------------------------------------------
kubectl exec deploy/curl-client -- sh -c "v1=0; v2=0; n=0; while [ $n -lt 10 ]; do r=$(curl -s http://reviews:9080/reviews/0); case $r in *reviews-v1*) v1=$(expr $v1 + 1);; *reviews-v2*) v2=$(expr $v2 + 1);; esac; n=$(expr $n + 1); done; echo     served by  v1=$v1  v2=$v2   [expected all v1]"
echo.

echo  ------------------------------------------------------------
echo   TEST B : the user 'jason' (header end-user: jason)
echo  ------------------------------------------------------------
kubectl exec deploy/curl-client -- sh -c "v1=0; v2=0; n=0; while [ $n -lt 10 ]; do r=$(curl -s -H end-user:jason http://reviews:9080/reviews/0); case $r in *reviews-v1*) v1=$(expr $v1 + 1);; *reviews-v2*) v2=$(expr $v2 + 1);; esac; n=$(expr $n + 1); done; echo     served by  v1=$v1  v2=$v2   [expected all v2]"
echo.

echo  ============================================================
echo   RESULT
echo  ------------------------------------------------------------
echo   Same URL, same service - but the response version depends
echo   entirely on the request's identity header. This is the
echo   engine behind A/B tests, dark launches and beta cohorts.
echo  ============================================================
echo.
echo  SEE IT IN THE BROWSER:
echo    1^) kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
echo    2^) http://localhost:8080/productpage  -> reviews has NO stars (v1)
echo    3^) Click "Sign in" (top-right), log in as user  jason  (any password)
echo       -> reviews now shows BLACK stars (v2). Log in as anyone else -> v1.
echo.
echo  Opening the illustrated guide...
start "" "%~dp0guide.html"
echo.
echo  When finished, double-click cleanup.bat to reset routing.
echo.
pause
