#!/bin/bash
echo "=== PTL Security Tool - Verificacion Fix SessionRouter ==="
echo ""
echo "[1] Verificando Fix 1 - _getProviderOnHoldAmount usa min()"
grep -n "session.closedAt.min(session.endsAt)"../smart-contracts/contracts/diamond/facets/SessionRouter.sol || echo "NOT FIXED: falta min() en L268"
echo ""
echo "[2] Verificando Fix 2 - claimForProvider respeta isClosingLate"
grep -n "isClosingLate_"../smart-contracts/contracts/diamond/facets/SessionRouter.sol
echo ""
echo "[3] Ejecutando PoC logico"
python3 auto_analyzer.py
echo ""
echo "[4] FIX.patch preview"
cat FIX.patch 2>/dev/null || echo "Genera patch con: git diff > FIX.patch"
