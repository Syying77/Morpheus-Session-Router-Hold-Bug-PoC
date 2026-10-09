TARGET:      SessionRouter @ Diamond Proxy (Appendix A) on Arbitrum One, block 350000000
INVARIANT:   Same late-closed session must yield same provider payout via closeSession() and claimForProvider()
IMPACT:      76,800 tokens per session = 88% loss. Calc: 86,400 - 9,600 = 76,800. At $0.5/MOR = $38,400 per session. Bounded by daily treasury but repeatable
PRECONDITIONS: Session endsAt=1086400, closedAt=1200000 late, attacker is provider (no privileged role, no owner), requires timing
ATTACK:      1) provider opens session 2) wait endsAt passed 3) session closed late 1200000 4) provider calls claimForProvider() 5) gets 9600 not 86400
POC:         https://github.com/Syying77/Morpheus-Session-Router-Hold-Bug-PoC/blob/main/PoC.t.sol
FIX:         _getProviderOnHoldAmount: use sessionEnd_ = closedAt.min(endsAt); claimForProvider: hold_ = isClosingLate_ ? 0 : _getProviderOnHoldAmount()
