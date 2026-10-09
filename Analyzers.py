def start_of_day(ts): return ts - (ts % 86400)
def analyze(T0, endsAt, T1, price=1, no_dispute=False):
    sessionEnd = min(T1, endsAt) if T1 else endsAt
    rewards = (sessionEnd - T0) * price
    hold = (T1 - max(start_of_day(T1), T0)) * price
    isLate = T1 >= endsAt
    close_val = rewards if (no_dispute or isLate) else rewards - hold
    claim_val = rewards - hold
    print(f"Late={isLate} close={close_val} claim={claim_val} DIFF={close_val-claim_val} BUG={close_val!=claim_val}")

# Prueba con tus propios timestamps
analyze(1_000_000, 1_086_400, 1_200_000, 1, False)
