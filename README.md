
## Tool for Morpheus Team - 1 Click Reproduce

### Steps to reproduce:

git clone https://github.com/Syying77/Morpheus-Session-Router-Hold-Bug-PoC.git
cd Morpheus-Session-Router-Hold-Bug-PoC
python3 auto_analyzer.py
# Output: Late=True close=86400 claim=9600 DIFF=76800 BUG=True






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
