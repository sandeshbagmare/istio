@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo  ╔══════════════════════════════════════════════════════════════╗
echo  ║                                                              ║
echo  ║        ██╗███████╗████████╗██╗ ██████╗                       ║
echo  ║        ██║██╔════╝╚══██╔══╝██║██╔═══██╗                      ║
echo  ║        ██║███████╗   ██║   ██║██║   ██║                      ║
echo  ║        ██║╚════██║   ██║   ██║██║   ██║                      ║
echo  ║        ██║███████║   ██║   ██║╚██████╔╝                      ║
echo  ║        ╚═╝╚══════╝   ╚═╝   ╚═╝ ╚═════╝                      ║
echo  ║                                                              ║
echo  ║        Chapter 10: Traffic Mirroring                         ║
echo  ║        Shadow Traffic / Dark Launching                       ║
echo  ║                                                              ║
echo  ╚══════════════════════════════════════════════════════════════╝
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   Step 1: Applying DestinationRule for reviews subsets
echo  ═══════════════════════════════════════════════════════════════
echo.
kubectl apply -f destination-rule-reviews.yaml
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   Step 2: Applying VirtualService with traffic mirroring
echo  ═══════════════════════════════════════════════════════════════
echo.
kubectl apply -f vs-mirror-to-v3.yaml
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   Step 3: Waiting for configuration to propagate...
echo  ═══════════════════════════════════════════════════════════════
echo.
echo  [INFO] Waiting 5 seconds for Envoy sidecars to sync...
timeout /t 5 /nobreak >nul
echo  [OK] Configuration propagated.
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   Step 4: Sending 5 test requests to reviews service
echo  ═══════════════════════════════════════════════════════════════
echo.
for /L %%i in (1,1,5) do (
    echo  [INFO] Sending request %%i/5...
    kubectl exec deploy/ratings-v1 -- curl -sS http://reviews:9080/reviews/0 >nul 2>&1
    timeout /t 1 /nobreak >nul
)
echo.
echo  [OK] All 5 test requests sent.
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   Step 5: Checking reviews-v1 logs (PRIMARY - live traffic)
echo  ═══════════════════════════════════════════════════════════════
echo.
echo  [INFO] Logs from reviews-v1 (PRIMARY):
echo  ───────────────────────────────────────
kubectl logs deploy/reviews-v1 -c reviews --tail=5
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   Step 6: Checking reviews-v3 logs (MIRROR - shadow traffic)
echo  ═══════════════════════════════════════════════════════════════
echo.
echo  [INFO] Logs from reviews-v3 (MIRROR):
echo  ───────────────────────────────────────
kubectl logs deploy/reviews-v3 -c reviews --tail=5
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   Step 7: Explanation
echo  ═══════════════════════════════════════════════════════════════
echo.
echo  [INFO] Both reviews-v1 and reviews-v3 should show incoming
echo         traffic in their logs. This proves that mirroring is
echo         working correctly!
echo.
echo         - reviews-v1 received the LIVE traffic (primary)
echo         - reviews-v3 received the MIRRORED traffic (shadow)
echo.
echo         The client only saw responses from reviews-v1.
echo         Responses from reviews-v3 were silently discarded.
echo.
echo         Notice the mirrored requests have a '-shadow' suffix
echo         appended to the Host header by Envoy.
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   Step 8: Opening the Learning Guide
echo  ═══════════════════════════════════════════════════════════════
echo.
echo  [INFO] Opening guide.html in your default browser...
start guide.html
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   ✓ Chapter 10 Traffic Mirroring Lab Complete!
echo  ═══════════════════════════════════════════════════════════════
echo.
pause
