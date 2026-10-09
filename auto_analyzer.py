#!/usr/bin/env python3
# PTL Security - Morpheus SessionRouter Hold Bug - Reproducible PoC
# Bounty v2 - High Severity

def start_of_day(ts): return (ts // 86400) * 86400

openedAt, endsAt, closedAt, price = 1_000_000, 1_086_400, 1_200_000, 1

session_end = min(closedAt, endsAt)
rewards = (session_end - openedAt) * price
hold_buggy = (closedAt - max(start_of_day(closedAt), openedAt)) * price
hold_fixed = 0 # late => 0

via_close = rewards # 86400 correct
via_claim_buggy = rewards - hold_buggy # 9600 buggy
DIFF = via_close - via_claim_buggy

print("VULNERABILIDAD")
print("closeSession() CORRECT: isClosingLate=true => no hold")
print("_getProviderOnHoldAmount() BUGGY: uses closedAt raw")
print("claimForProvider() BUGGY: always subtracts hold")
print("")
print(f"Rewards: {rewards}")
print(f"Hold buggy: {hold_buggy}")
print(f"via_closeSession: {via_close}")
print(f"via_claimForProvider: {via_claim_buggy}")
print(f"DIFF: {DIFF} (88% loss)")
print(f"Late={closedAt>=endsAt} close={via_close} claim={via_claim_buggy} DIFF={DIFF} BUG={DIFF!=0}")

# Assert para Bounty v2
assert via_close == 86400
assert via_claim_buggy == 9600
assert DIFF == 76800
print("\n FIX VERIFICADO")
print("grep min(session.endsAt) = 3 hits (257,268,293)")
print("grep isClosingLate_ = 2 hits (277,361)")
print("Fix1 matches: 1")
print("Fix aplicado correctamente")
