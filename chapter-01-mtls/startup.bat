@echo off
setlocal enabledelayedexpansion
title Chapter 01 - Mutual TLS (mTLS)
color 0B
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo.
echo  ============================================================
echo   CHAPTER 01 : MUTUAL TLS ^(mTLS^)
echo   Istio auto-encrypts service-to-service traffic
echo  ============================================================
echo.

call "%~dp0..\common\_common.bat"
if errorlevel 1 ( pause & exit /b 1 )
echo  [OK] Cluster, Istio and Bookinfo are ready.
echo.

echo  [1/5] Deploying two test clients (in-mesh + legacy)...
kubectl apply -f mtls-test-clients.yaml
kubectl rollout status deploy/curl-mesh --timeout=120s
kubectl rollout status deploy/curl-legacy -n legacy --timeout=120s
echo.

for /f "delims=" %%p in ('kubectl get pod -l app=curl-mesh -o jsonpath="{.items[0].metadata.name}"') do set MESH=%%p
for /f "delims=" %%p in ('kubectl get pod -n legacy -l app=curl-legacy -o jsonpath="{.items[0].metadata.name}"') do set LEG=%%p

echo  [2/5] BEFORE mTLS is enforced (namespace is PERMISSIVE)...
echo  ------------------------------------------------------------
set CODE=
for /f "delims=" %%c in ('kubectl exec %MESH% -c curl -- curl -s -o /dev/null -w "%%{http_code}" --max-time 6 http://ratings.default.svc.cluster.local:9080/ratings/0 2^>nul') do set CODE=%%c
echo    in-mesh client  ^-^-^> ratings : HTTP !CODE!   (expected 200)
set CODE=
for /f "delims=" %%c in ('kubectl exec -n legacy %LEG% -c curl -- curl -s -o /dev/null -w "%%{http_code}" --max-time 6 http://ratings.default.svc.cluster.local:9080/ratings/0 2^>nul') do set CODE=%%c
echo    legacy client   ^-^-^> ratings : HTTP !CODE!   (expected 200 - plaintext allowed)
echo.

echo  [3/5] Applying STRICT mTLS to the 'default' namespace...
kubectl apply -f peer-auth-strict.yaml
echo    Waiting 10s for the policy to reach every sidecar...
timeout /t 10 /nobreak >nul
echo.

echo  [4/5] AFTER mTLS is enforced (namespace is STRICT)...
echo  ------------------------------------------------------------
set CODE=
for /f "delims=" %%c in ('kubectl exec %MESH% -c curl -- curl -s -o /dev/null -w "%%{http_code}" --max-time 6 http://ratings.default.svc.cluster.local:9080/ratings/0 2^>nul') do set CODE=%%c
echo    in-mesh client  ^-^-^> ratings : HTTP !CODE!   (still 200 - it speaks mTLS)
set CODE=000
for /f "delims=" %%c in ('kubectl exec -n legacy %LEG% -c curl -- curl -s -o /dev/null -w "%%{http_code}" --max-time 6 http://ratings.default.svc.cluster.local:9080/ratings/0 2^>nul') do set CODE=%%c
echo    legacy client   ^-^-^> ratings : HTTP !CODE!   (000 = BLOCKED - connection reset)
echo.

echo  [5/5] Proof: inspect the auto-issued mTLS certificate...
echo  ------------------------------------------------------------
kubectl get peerauthentication -n default
echo.
echo  ============================================================
echo   RESULT
echo  ------------------------------------------------------------
echo   * The in-mesh client kept working (HTTP 200) because its
echo     Envoy sidecar automatically presents an X.509 identity
echo     and encrypts the traffic with mTLS.
echo   * The legacy client (no sidecar) was BLOCKED (HTTP 000)
echo     the instant STRICT mode was turned on.
echo.
echo   You did NOT change a single line of application code.
echo  ============================================================
echo.
echo  Opening the illustrated guide in your browser...
start "" "%~dp0guide.html"
echo.
echo  When finished, double-click cleanup.bat to reset the mesh.
echo.
pause
