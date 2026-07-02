@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

cls
echo.
echo  ╔══════════════════════════════════════════════════════════════════╗
echo  ║                                                                ║
echo  ║    ██████╗██╗██████╗  ██████╗██╗   ██╗██╗████████╗            ║
echo  ║   ██╔════╝██║██╔══██╗██╔════╝██║   ██║██║╚══██╔══╝            ║
echo  ║   ██║     ██║██████╔╝██║     ██║   ██║██║   ██║               ║
echo  ║   ██║     ██║██╔══██╗██║     ██║   ██║██║   ██║               ║
echo  ║   ╚██████╗██║██║  ██║╚██████╗╚██████╔╝██║   ██║               ║
echo  ║    ╚═════╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝╚═╝   ╚═╝               ║
echo  ║                                                                ║
echo  ║   ██████╗ ██████╗ ███████╗ █████╗ ██╗  ██╗██╗███╗   ██╗ ██████╗║
echo  ║   ██╔══██╗██╔══██╗██╔════╝██╔══██╗██║ ██╔╝██║████╗  ██║██╔════╝║
echo  ║   ██████╔╝██████╔╝█████╗  ███████║█████╔╝ ██║██╔██╗ ██║██║  ███║
echo  ║   ██╔══██╗██╔══██╗██╔══╝  ██╔══██║██╔═██╗ ██║██║╚██╗██║██║   ██║
echo  ║   ██████╔╝██║  ██║███████╗██║  ██║██║  ██╗██║██║ ╚████║╚██████╔╝║
echo  ║   ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝ ╚═══╝ ╚═════╝║
echo  ║                                                                ║
echo  ║          CHAPTER 5: CIRCUIT BREAKING                           ║
echo  ║          Preventing Cascade Failures in Microservices          ║
echo  ║                                                                ║
echo  ╚══════════════════════════════════════════════════════════════════╝
echo.

:: ──────────────────────────────────────────────────────────────
:: STEP 1: Deploy httpbin service
:: ──────────────────────────────────────────────────────────────
echo.
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  STEP 1: Deploying httpbin Service                       │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Applying httpbin deployment and service...
kubectl apply -f httpbin-deploy.yaml
if !errorlevel! neq 0 (
    echo  [X] ERROR: Failed to deploy httpbin
    pause
    exit /b 1
)
echo.
echo  [*] Waiting for httpbin pod to be ready...
kubectl wait --for=condition=ready pod -l app=httpbin --timeout=120s
if !errorlevel! neq 0 (
    echo  [X] ERROR: httpbin pod did not become ready in time
    pause
    exit /b 1
)
echo  [✓] httpbin is ready!
echo.

:: ──────────────────────────────────────────────────────────────
:: STEP 2: Deploy fortio load testing tool
:: ──────────────────────────────────────────────────────────────
echo.
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  STEP 2: Deploying Fortio Load Testing Tool              │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Applying fortio deployment and service...
kubectl apply -f fortio-deploy.yaml
if !errorlevel! neq 0 (
    echo  [X] ERROR: Failed to deploy fortio
    pause
    exit /b 1
)
echo.
echo  [*] Waiting for fortio pod to be ready...
kubectl wait --for=condition=ready pod -l app=fortio --timeout=120s
if !errorlevel! neq 0 (
    echo  [X] ERROR: fortio pod did not become ready in time
    pause
    exit /b 1
)
echo  [✓] Fortio is ready!
echo.

:: ──────────────────────────────────────────────────────────────
:: STEP 3: Apply Circuit Breaker DestinationRule
:: ──────────────────────────────────────────────────────────────
echo.
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  STEP 3: Applying Circuit Breaker DestinationRule        │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Applying circuit breaker configuration...
echo  [*] Settings:
echo       - maxConnections: 1
echo       - http1MaxPendingRequests: 1
echo       - maxRequestsPerConnection: 1
echo       - consecutive5xxErrors: 1
echo       - baseEjectionTime: 3m
echo.
kubectl apply -f circuit-breaker.yaml
if !errorlevel! neq 0 (
    echo  [X] ERROR: Failed to apply circuit breaker
    pause
    exit /b 1
)
echo  [✓] Circuit breaker DestinationRule applied!
echo.

:: ──────────────────────────────────────────────────────────────
:: STEP 4: Get Fortio pod name
:: ──────────────────────────────────────────────────────────────
echo.
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  STEP 4: Getting Fortio Pod Name                         │
echo  └──────────────────────────────────────────────────────────┘
echo.
for /f %%i in ('kubectl get pod -l app=fortio -o jsonpath^={.items[0].metadata.name}') do set FORTIO_POD=%%i
if not defined FORTIO_POD (
    echo  [X] ERROR: Could not find fortio pod
    pause
    exit /b 1
)
echo  [✓] Fortio pod: %FORTIO_POD%
echo.

:: ──────────────────────────────────────────────────────────────
:: STEP 5 - DEMO 1: Single request (baseline)
:: ──────────────────────────────────────────────────────────────
echo.
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  STEP 5 - DEMO 1: Single Request (Baseline Test)        │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Sending a single request from fortio to httpbin...
echo  [*] This should succeed with HTTP 200 OK since the circuit
echo      breaker is not tripped by a single connection.
echo.
kubectl exec %FORTIO_POD% -c fortio -- fortio curl http://httpbin:8000/get
echo.
echo  [✓] Single request completed - should return HTTP 200 OK
echo  [i] With just one connection, we stay within the circuit
echo      breaker limits (maxConnections: 1).
echo.
echo  ════════════════════════════════════════════════════════════
pause
echo.

:: ──────────────────────────────────────────────────────────────
:: STEP 6 - DEMO 2: 20 requests with 2 concurrent connections
:: ──────────────────────────────────────────────────────────────
echo.
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  STEP 6 - DEMO 2: Load Test (2 Concurrent Connections)  │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Sending 20 requests with 2 concurrent connections...
echo  [*] With maxConnections=1, the 2nd connection will overflow
echo      and some requests will be circuit-broken (HTTP 503).
echo.
kubectl exec %FORTIO_POD% -c fortio -- fortio load -c 2 -qps 0 -n 20 -loglevel Warning http://httpbin:8000/get
echo.
echo  [i] ANALYSIS: Look at the results above.
echo      - HTTP 200 responses = Requests that got through
echo      - HTTP 503 responses = Requests BLOCKED by circuit breaker
echo      The circuit breaker tripped because we exceeded
echo      maxConnections (1) with 2 concurrent connections.
echo.
echo  ════════════════════════════════════════════════════════════
pause
echo.

:: ──────────────────────────────────────────────────────────────
:: STEP 7 - DEMO 3: 20 requests with 3 concurrent connections
:: ──────────────────────────────────────────────────────────────
echo.
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  STEP 7 - DEMO 3: Load Test (3 Concurrent Connections)  │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Sending 20 requests with 3 concurrent connections...
echo  [*] With 3 connections exceeding the limit of 1, even MORE
echo      requests will be circuit-broken compared to Demo 2.
echo.
kubectl exec %FORTIO_POD% -c fortio -- fortio load -c 3 -qps 0 -n 20 -loglevel Warning http://httpbin:8000/get
echo.
echo  [i] ANALYSIS: Compare these results with Demo 2.
echo      - You should see MORE 503 errors with 3 connections
echo      - The circuit breaker is more aggressively blocking
echo        because we're further over the connection limit.
echo      - This demonstrates proportional circuit breaking:
echo        more pressure = more protection.
echo.
echo  ════════════════════════════════════════════════════════════
pause
echo.

:: ──────────────────────────────────────────────────────────────
:: STEP 8: Show Envoy upstream overflow stats
:: ──────────────────────────────────────────────────────────────
echo.
echo  ┌──────────────────────────────────────────────────────────┐
echo  │  STEP 8: Envoy Proxy Circuit Breaker Statistics          │
echo  └──────────────────────────────────────────────────────────┘
echo.
echo  [*] Querying istio-proxy (Envoy) for overflow statistics...
echo  [*] The upstream_rq_pending_overflow counter shows how many
echo      requests were blocked by the circuit breaker.
echo.
kubectl exec %FORTIO_POD% -c istio-proxy -- pilot-agent request GET stats | findstr "upstream_rq_pending_overflow"
echo.
echo  [i] The number shown is the total count of requests that
echo      were rejected by the circuit breaker across all demos.
echo      This is the definitive proof that Envoy's circuit
echo      breaker was actively protecting the httpbin service.
echo.

:: ──────────────────────────────────────────────────────────────
:: Complete - Open guide
:: ──────────────────────────────────────────────────────────────
echo.
echo  ╔══════════════════════════════════════════════════════════════════╗
echo  ║                                                                ║
echo  ║   ✓  CHAPTER 5 DEMOS COMPLETE!                                ║
echo  ║                                                                ║
echo  ║   You've seen circuit breaking in action:                      ║
echo  ║   • Single request passes through normally                     ║
echo  ║   • 2 connections triggers some circuit breaking               ║
echo  ║   • 3 connections triggers more aggressive blocking            ║
echo  ║   • Envoy stats confirm requests were overflow-rejected        ║
echo  ║                                                                ║
echo  ║   Opening the study guide for deeper understanding...          ║
echo  ║                                                                ║
echo  ╚══════════════════════════════════════════════════════════════════╝
echo.

start "" "%~dp0guide.html"

echo  [*] Run cleanup.bat when you're done to remove all resources.
echo.
pause
endlocal
