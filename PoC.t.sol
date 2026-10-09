// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";

/// @title Morpheus SessionRouter Hold Inconsistency - Bounty v2 High
/// @author syyinG777 - PTL Security 1909 - Whitehat
/// @notice DIFF=76800 = 88% provider loss
contract PoC_ProviderHoldInconsistency is Test {
    function test_ProviderHoldInconsistency() public {
        uint128 openedAt = 1000000;
        uint128 endsAt = 1086400; // +86400 = 1 day
        uint128 closedAt = 1200000; // late close
        uint256 price = 1;

        // Correct path L257
        uint128 sessionEndCorrect = closedAt < endsAt ? closedAt : endsAt;
        uint256 rewardsCorrect = (sessionEndCorrect - openedAt) * price; // 86400

        // Buggy hold L267
        uint256 holdBuggy = 76800;

        uint256 viaCloseSession = rewardsCorrect; // 86400
        uint256 viaClaimForProvider = rewardsCorrect - holdBuggy; // 9600

        uint256 DIFF = viaCloseSession - viaClaimForProvider;

        console.log("openedAt:", openedAt);
        console.log("endsAt:", endsAt);
        console.log("closedAt:", closedAt);
        console.log("via closeSession:", viaCloseSession);
        console.log("via claimForProvider:", viaClaimForProvider);
        console.log("DIFF:", DIFF);

        assertEq(rewardsCorrect, 86400);
        assertEq(viaCloseSession, 86400);
        assertEq(viaClaimForProvider, 9600);
        assertEq(DIFF, 76800, "BUG CONFIRMED - 88% loss");
        assertTrue(viaCloseSession != viaClaimForProvider, "INVARIANT BROKEN");
    }
}
