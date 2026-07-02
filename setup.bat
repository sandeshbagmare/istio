@echo off
setlocal enabledelayedexpansion
title Istio Learning Lab - Full Setup
color 0B
chcp 65001 >nul 2>&1

echo.
echo  ███████████████████████████████████████████████████████
echo  ██                                                   ██
echo  ██       ISTIO LEARNING LAB — COMPLETE SETUP         ██
echo  ██         10 Chapters · Hands-On Demos              ██
echo  ██                                                   ██
echo  ███████████████████████████████████████████████████████
echo.
echo  What this setup will do:
echo  -------------------------------------------------
echo  [1] Install Minikube  (local Kubernetes cluster)
echo  [2] Install Helm      (Kubernetes package manager)
echo  [3] Install Istioctl  (Istio control CLI)
echo  [4] Start Minikube    (4 CPUs · 8GB RAM)
echo  [5] Install Istio     (demo profile)
echo  [6] Install Addons    (Kiali + Grafana + Jaeger + Prometheus)
echo  [7] Deploy Bookinfo   (sample microservices app)
echo  [8] Verify Setup      (all chapters ready)
echo.
echo  Total time: approximately 10-15 minutes
echo  Please keep Docker Desktop / Rancher Desktop running!
echo.
pause

:: ============================================================
:: CHECK DOCKER
:: ============================================================
echo.
echo [CHECK] Verifying Docker is running...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: Docker is not running!
    echo.
    echo  Please start Docker Desktop or Rancher Desktop first,
    echo  wait for it to fully load, then run this script again.
    echo.
    pause
    exit /b 1
)
echo  [OK] Docker is running

:: ============================================================
:: CHECK WINGET
:: ============================================================
winget --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ERROR: winget (Windows Package Manager) not found!
    echo.
    echo  Please install it from: https://aka.ms/getwinget
    echo  Or install tools manually:
    echo    Minikube: https://minikube.sigs.k8s.io
    echo    Helm:     https://helm.sh
    echo    Istio:    https://istio.io/latest/docs/setup/getting-started/
    echo.
    pause
    exit /b 1
)
echo  [OK] winget available

:: ============================================================
:: STEP 1: INSTALL MINIKUBE
:: ============================================================
echo.
echo  [STEP 1/8] Installing Minikube...
echo  ----------------------------------------
minikube version >nul 2>&1
if %errorlevel% neq 0 (
    echo  Installing Minikube via winget...
    winget install Kubernetes.minikube --silent --accept-source-agreements --accept-package-agreements
    if %errorlevel% neq 0 (
        echo  [WARN] winget install failed. Trying direct download...
        PowerShell -Command "& { $url='https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe'; $out='%TEMP%\minikube-installer.exe'; Write-Host 'Downloading Minikube...'; Invoke-WebRequest $url -OutFile $out; Start-Process $out -ArgumentList '/S' -Wait; Remove-Item $out }"
    )
) else (
    echo  [OK] Minikube already installed
)

:: Refresh PATH for newly installed tools
set "PATH=%PATH%;%LOCALAPPDATA%\Microsoft\WinGet\Links;C:\Program Files\Kubernetes\Minikube"
for /f "tokens=2*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do set "USER_PATH=%%b"
if defined USER_PATH set "PATH=%PATH%;%USER_PATH%"

:: ============================================================
:: STEP 2: INSTALL HELM
:: ============================================================
echo.
echo  [STEP 2/8] Installing Helm...
echo  ----------------------------------------
helm version >nul 2>&1
if %errorlevel% neq 0 (
    echo  Installing Helm via winget...
    winget install Helm.Helm --silent --accept-source-agreements --accept-package-agreements
) else (
    echo  [OK] Helm already installed
)

:: ============================================================
:: STEP 3: INSTALL ISTIOCTL
:: ============================================================
echo.
echo  [STEP 3/8] Installing Istioctl...
echo  ----------------------------------------
istioctl version --remote=false >nul 2>&1
if %errorlevel% neq 0 (
    echo  Installing Istioctl via winget...
    winget install Istio.istioctl --silent --accept-source-agreements --accept-package-agreements
    if %errorlevel% neq 0 (
        echo  Trying PowerShell install method...
        PowerShell -Command "& { $env:ISTIO_VERSION='1.23.0'; $env:TARGET_ARCH='amd64'; (New-Object System.Net.WebClient).DownloadString('https://istio.io/downloadIstio') | iex }"
    )
) else (
    echo  [OK] Istioctl already installed
)

:: Final PATH refresh
set "PATH=%PATH%;%LOCALAPPDATA%\Microsoft\WinGet\Links;%USERPROFILE%\.istioctl\bin;C:\istio-1.23.0\bin"
for /f "tokens=2*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>nul') do set "SYS_PATH=%%b"
if defined SYS_PATH set "PATH=%PATH%;%SYS_PATH%"

:: ============================================================
:: STEP 4: START MINIKUBE
:: ============================================================
echo.
echo  [STEP 4/8] Starting Minikube cluster...
echo  ----------------------------------------
minikube status 2>nul | findstr /i "Running" >nul 2>&1
if %errorlevel% equ 0 (
    echo  [OK] Minikube already running
) else (
    echo  Starting Minikube (4 CPUs, 8GB RAM, 50GB disk)...
    echo  This may take 3-5 minutes on first run...
    minikube start --driver=docker --memory=8192 --cpus=4 --disk-size=50g
    if %errorlevel% neq 0 (
        echo.
        echo  [WARN] Docker driver failed, trying hyperv driver...
        minikube start --driver=hyperv --memory=8192 --cpus=4 --disk-size=50g
        if %errorlevel% neq 0 (
            echo.
            echo  ERROR: Minikube failed to start!
            echo  Please check Docker is running and try again.
            pause
            exit /b 1
        )
    )
    echo  [OK] Minikube started successfully
)

:: Switch kubectl context to minikube
kubectl config use-context minikube >nul 2>&1
echo  [OK] kubectl context set to minikube

:: ============================================================
:: STEP 5: INSTALL ISTIO
:: ============================================================
echo.
echo  [STEP 5/8] Installing Istio service mesh...
echo  ----------------------------------------
kubectl get namespace istio-system >nul 2>&1
if %errorlevel% neq 0 (
    echo  Installing Istio with demo profile...
    echo  (This includes istiod, ingress gateway, egress gateway)
    istioctl install --set profile=demo -y
    if %errorlevel% neq 0 (
        echo  ERROR: Istio installation failed!
        pause
        exit /b 1
    )
    echo  [OK] Istio installed
) else (
    echo  [OK] Istio already installed
)

:: Wait for Istio to be ready
echo  Waiting for Istio components to be ready...
kubectl wait --namespace istio-system --for=condition=ready pod -l app=istiod --timeout=120s
kubectl wait --namespace istio-system --for=condition=ready pod -l app=istio-ingressgateway --timeout=120s

:: Enable sidecar injection on default namespace
kubectl label namespace default istio-injection=enabled --overwrite
echo  [OK] Sidecar injection enabled on default namespace

:: ============================================================
:: STEP 6: INSTALL ADDONS
:: ============================================================
echo.
echo  [STEP 6/8] Installing observability addons...
echo  ----------------------------------------
echo  Installing Prometheus (metrics collection)...
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/addons/prometheus.yaml

echo  Installing Grafana (metrics dashboards)...
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/addons/grafana.yaml

echo  Installing Jaeger (distributed tracing)...
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/addons/jaeger.yaml

echo  Installing Kiali (service mesh visualization)...
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.23/samples/addons/kiali.yaml

echo  Waiting for addons to start...
timeout /t 30 /nobreak >nul
echo  [OK] Addons installed

:: ============================================================
:: STEP 7: DEPLOY BOOKINFO
:: ============================================================
echo.
echo  [STEP 7/8] Deploying Bookinfo sample application...
echo  ----------------------------------------
kubectl get deployment productpage-v1 >nul 2>&1
if %errorlevel% neq 0 (
    echo  Deploying Bookinfo app...
    kubectl apply -f common\bookinfo.yaml
    kubectl apply -f common\bookinfo-gateway.yaml
    echo  Waiting for all pods to be ready (2-3 minutes)...
    kubectl wait --for=condition=ready pod -l app=productpage --timeout=300s
    kubectl wait --for=condition=ready pod -l app=details --timeout=300s
    kubectl wait --for=condition=ready pod -l app=reviews --timeout=300s
    kubectl wait --for=condition=ready pod -l app=ratings --timeout=300s
    echo  [OK] Bookinfo deployed
) else (
    echo  [OK] Bookinfo already deployed
)

:: ============================================================
:: STEP 8: VERIFY
:: ============================================================
echo.
echo  [STEP 8/8] Verifying setup...
echo  ----------------------------------------
echo  Checking all pods...
kubectl get pods
echo.
echo  Checking Istio components...
kubectl get pods -n istio-system

:: ============================================================
:: SUCCESS!
:: ============================================================
echo.
echo  ███████████████████████████████████████████████████████
echo  ██                                                   ██
echo  ██              SETUP COMPLETE!                      ██
echo  ██                                                   ██
echo  ███████████████████████████████████████████████████████
echo.
echo  Next Steps:
echo  -------------------------------------------------
echo  1. Open index.html in your browser for the full tour
echo  2. Start minikube tunnel in a NEW Command Prompt:
echo        minikube tunnel
echo  3. Then visit: http://localhost/productpage
echo  4. Go into any chapter folder ^& double-click startup.bat
echo.
echo  Installed:
for /f "delims=" %%i in ('minikube version --short 2^>nul') do echo    Minikube: %%i
for /f "delims=" %%i in ('istioctl version --remote=false 2^>nul') do echo    Istio:    %%i
for /f "delims=" %%i in ('kubectl version --client --output=yaml 2^>nul ^| findstr "gitVersion"') do echo    kubectl: %%i
echo.
pause
