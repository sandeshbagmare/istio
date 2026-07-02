@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul 2>&1
color 0B

echo.
echo  ╔══════════════════════════════════════════════════════════════╗
echo  ║                                                              ║
echo  ║   Chapter 10: Traffic Mirroring - Cleanup                    ║
echo  ║                                                              ║
echo  ╚══════════════════════════════════════════════════════════════╝
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   Removing Traffic Mirroring Resources
echo  ═══════════════════════════════════════════════════════════════
echo.

echo  [INFO] Deleting VirtualService (mirror config)...
kubectl delete -f vs-mirror-to-v3.yaml --ignore-not-found
echo.

echo  [INFO] Deleting DestinationRule (subsets)...
kubectl delete -f destination-rule-reviews.yaml --ignore-not-found
echo.

echo  ═══════════════════════════════════════════════════════════════
echo   ✓ Cleanup Complete!
echo  ═══════════════════════════════════════════════════════════════
echo.
echo  [INFO] All Chapter 10 traffic mirroring resources have been
echo         removed. The reviews service will return to default
echo         round-robin routing.
echo.

pause
