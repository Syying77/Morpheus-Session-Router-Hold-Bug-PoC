Morpheus SessionRouter Hold Inconsistency - Bounty v2

**Severity:** High | **Loss:** 88% | **DIFF:** 76800 | **Impact:** $38,400 per session | **Status:** Verified Fix

## 1-Click Reproduce for Morpheus Team

git clone https://github.com/Syying77/Morpheus-Session-Router-Hold-Bug-PoC.git
cd Morpheus-Session-Router-Hold-Bug-PoC
python3 Analyzers.py
# Expected Output: Late=True close=86400 claim=9600 DIFF=76800 BUG=True
## Foundry PoC
forge install foundry-rs/forge-std --no-commit
forge test -vv
# Expected: PASS - Invariant broken demonstrated
## Summary

After PR #830 fixed user rewards to use `min(closedAt, endsAt)`, provider hold path was left using raw `closedAt`. Two payout paths for same late session give different results.

- `closeSession()` L277: `isClosingLate_=true => hold=0` => *86,400 tokens CORRECT*
- `claimForProvider()` L361: `always subtracts hold` => *9,600 tokens BUGGY*
- *DIFF: 76,800 = 88% loss - Invariant broken*

## Files

- `PoC.t.sol` - Foundry test with invariant assertion
- `Analyzers.py` - Python 1-click reproducible PoC
- `FIX.patch` - Verified fix (3 hits min() + 2 hits isClosingLate_)
- `Fix.sh` - 1-click verification script for team
- `report.md` - Bounty v2 required format (TARGET/INVARIANT/IMPACT)

## Fix Verified
// L268 - Fix _getProviderOnHoldAmount
uint128 sessionEnd_ = session.closedAt.min(session.endsAt);
uint128 startOfSessionEnd_ = startOfTheDay(sessionEnd_);

// L361-362 - Fix claimForProvider
bool isClosingLate_ = session.closedAt >= session.endsAt;
uint256 hold_ = isClosingLate_ ? 0 : _getProviderOnHoldAmount(session, bid);
## Bounty Submission

- *TARGET:* SessionRouter @ Diamond Proxy (Appendix A) on Arbitrum One
- *INVARIANT:* Same late-closed session must yield same provider payout via both paths
- *IMPACT:* 76,800 tokens per session, $38,400 at $0.5/MOR
- *POC:* https://github.com/Syying77/Morpheus-Session-Router-Hold-Bug-PoC

## Auditor - Reward Info

- *Name:* syyinG777 | PTL Security 1909 - Whitehat Ethical Hacker
- *GitHub:* @Syying77
- *Email:* syyinG09@protonmail.com
- *Wallet Arbitrum One (for Bounty v2 payout):* 0x44c7c86b6b808c5750491748b24d008d587c1c37
- *Program:* Morpheus Bug Bounty v2 $100k
- *Repo:* https://github.com/Syying77/Morpheus-Session-Router-Hold-Bug-PoC

---
MIT License - Whitehat PoC - PTL Security 1909

