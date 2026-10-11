# [Morpheus - Lumerin Node] Professional Security Report
## Diamond Loupe Inconsistency - Hidden Upgradeability
**Version: Final - 2026-10-08 - syyinG777**

---
### 1. Metadata
- **Researcher:** syyinG777 - Ethical Researcher
- **Project:** Morpheus Lumerin Node
- **Chain:** Base Mainnet (8453) - Block Pinned: 52348400
- **Diamond Proxy:** 0x6aBE1d282f72B474E54527D93b979A4f64d3030a
- **Payout Wallet:** 0x44c7c86b6b808c5750491748b24d008d587c1c37 (Base/Ethereum)
- **Severity:** Low / Informational - No fund loss
- **Type:** Transparency / EIP-2535 Compliance
- **Status:** Secure by Design

### 2. Executive Summary
Full on-chain audit of Lumerin Diamond at block 52348400. Owner is Gnosis Safe 5/9 - VERIFIED SECURE. No Critical/High. Implementation hides diamondCut (0x1f931c1c) selector from IDiamondLoupe.facets(), causing off-chain monitoring (L2Beat, BaseScan, Tenderly) to report diamond as non-upgradeable, while Safe owner CAN upgrade.

### 3. On-Chain Evidence (cast verified)
**Owner Safe:**
- Address: 0x1FE04BC15Cf2c5A2d41a0b3a96725596676eBa1E
- Code: 0x608060405273ffffffff... (Safe Proxy L1.3.0)
- getOwners() = 9 - Threshold 5 - Verified via cast
- Security: PASS - SECURE

**Registry:**
- Address: 0x00000000000000447e69651d841bD8D104Bed493
- Type: ERC-721 Registry - 15kb verified
- Pattern: CREATE2 vanity 0x0000...0447

**Funding Account:**
- Address: 0x5160C0311A95E0A1072FA85Df23712A7BA1cD4b1
- Type: Safe Proxy (same bytecode as Owner)
- Balance: 0.01 ETH (10000000000000000 wei) - gas only

### 4. Diamond Mapping - Appendix A (Our Work)
Total: 5 Facets, 73 Selectors - Code sizes measured on-chain

| # | Facet Address | Selectors | Code Size | Role |
|---|---|---|---|---|
| 0 | 0xE30279b79392AEfF7fDf1883C23d52eBA9D88A75 | 8 | 7103 bytes | Loupe (filtered) |
| 1 | 0xb7994dE339AEe515C9b2792831CD83f3C9D8df87 | 10 | 8069 bytes | |
| 2 | 0x5B660aB78f3AC743953F9E68630A2D66e7b45F64 | 18 | 9260 bytes | |
| 3 | 0x345B8B23c38F70f1d77560C60493Bb583f012Cb0 | 8 | 1506 bytes | |
| 4 | 0x3a3952F0e57B343F00B31f7da039Ef16389B7260 | 29 | 18535 bytes | Pool logic |

**Critical Test (forge):**
- IDiamondLoupe.facetAddress(0x1f931c1c) = 0x0000000000000000000000000000000000000000 // HIDDEN
- IDiamondLoupe.facetAddress(0x8da5cb5b) = 0x0 // owner() also hidden from Loupe
- IOwnable.owner() = 0x1FE04BC15Cf2c5A2d41a0b3a96725596676eBa1E // Direct call WORKS
- forge test test_bountyReport => PASS gas 401022

### 5. Issue Detail
**EIP-2535 Requirement:** facets() MUST return all facets and selectors.
**Current:** diamondCut callable via proxy fallback but not returned by Loupe.
**Impact:** Low. No theft without 5/9 compromise. Users/tools misled. Facet 4 handles pool funds.

### 6. Repro Steps (Extendible)
Step 1 - Env:
export DIAMOND=0x6aBE1d282f72B474E54527D93b979A4f64d3030a
export BASE_RPC=YOUR_BASE_RPC

Step 2 - Facets:
cast call $DIAMOND "facets()((address,bytes4[])[])" --rpc-url $BASE_RPC --block 52348400

Step 3 - Hidden diamondCut:
cast call $DIAMOND "facetAddress(bytes4)(address)" 0x1f931c1c --rpc-url $BASE_RPC --block 52348400
# Returns 0x0000000000000000000000000000000000000000

Step 4 - Owner works:
cast call $DIAMOND "owner()(address)" --rpc-url $BASE_RPC --block 52348400
# Returns 0x1FE04BC15Cf2c5A2d41a0b3a96725596676eBa1E

Step 5 - Forge PoC:
forge test --match-test test_bountyReport -vvv --fork-url $BASE_RPC --fork-block-number 52348400
# Check logs/bounty_final.log

Step 6 - Safe verification:
cast call 0x1FE04BC15Cf2c5A2d41a0b3a96725596676eBa1E "getThreshold()(uint256)" --rpc-url $BASE_RPC
cast call 0x1FE04BC15Cf2c5A2d41a0b3a96725596676eBa1E "getOwners()(address[])" --rpc-url $BASE_RPC

### 7. Fix Recommendation
Option 1 (Preferred): Expose diamondCut in Facet 0 Loupe
Option 2: Document filtering + add isUpgradeable() view + 48h Timelock event

### 8. Quantified Impact
- Funds at risk: $0 without Safe compromise
- Exploit path: None - Requires 5/9
- Classification: Informational / Low

### 9. Safe Harbor & Disclosure
Good-faith research, no state change, only view calls + fork. Do not disclose publicly before fix. Request acknowledgment.

Artifacts: FINAL_BOUNTY_syyinG777_0x44c7.tar.gz SHA256 be66cd2ef2b985f745e5997ba420612abc93b59799859a9f8273204417ceeff7
Wallet: 0x44c7c86b6b808c5750491748b24d008d587c1c37
Researcher: syyinG777
System is SECURE. No Critical/High.
