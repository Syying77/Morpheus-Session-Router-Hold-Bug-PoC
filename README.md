# Morpheus SessionRouter Hold Inconsistency - Bounty v2

Severity: High | Loss: 88% | DIFF: 76800

# Summary
After PR #830 fixed user rewards to use min(closedAt, endsAt), provider hold path was left using raw closedAt. Two payout paths for same session give different results.

- `closeSession()`: 86,400 tokens (correct, hold=0 when late)
- `claimForProvider()`: 9,600 tokens (buggy, always subtracts hold)
- "DIFF: 76,800 = 88% loss"
 Run PoC

forge install foundry-rs/forge-std --no-commit
forge test -vv
