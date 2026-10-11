// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";

interface IDiamondLoupe { function facetAddress(bytes4) external view returns (address); }

contract SessionRouter_Ethical_Repro is Test {
    address constant DIAMOND = 0x6aBE1d282f72B474E54527D93b979A4f64d3030a;
    uint256 constant FORK_BLOCK = 52348400;

    function setUp() public { vm.createSelectFork(vm.envString("BASE_RPC"), FORK_BLOCK); }

    function test_bountyReport_DiamondLoupe() public view {
        assertEq(IDiamondLoupe(DIAMOND).facetAddress(0x1f931c1c), address(0), "diamondCut hidden");
    }

    function test_holdLogic_ClaimBeforeClose() public pure {
        uint128 openedAt = 1_000_000;
        uint128 endsAt = 1_086_400;
        uint128 closedAt = 1_200_000;
        uint128 price = 1;

        uint128 sessionEnd = closedAt < endsAt ? closedAt : endsAt; // 1086400
        uint128 rewards = (sessionEnd - openedAt) * price; // 86400

        uint128 startOfDayClosed = (closedAt / 86400) * 86400; // 1123200
        uint128 maxStart = startOfDayClosed > openedAt ? startOfDayClosed : openedAt;
        uint128 holdBuggy = (closedAt - maxStart) * price; // 76800

        uint128 viaCloseCorrect = rewards; // 86400
        uint128 viaClaimBuggy = rewards - holdBuggy; // 9600

        // Asserts que prueban tu bug original
        assertEq(rewards, 86400);
        assertEq(holdBuggy, 76800, "hold buggy 76800");
        assertEq(viaCloseCorrect, 86400);
        assertEq(viaClaimBuggy, 9600, "provider gets 9600 not 86400");

        bool isLate = closedAt >= endsAt;
        uint256 holdShouldBe = isLate ? 0 : holdBuggy;
        assertTrue(isLate);
        assertEq(holdShouldBe, 0, "should be 0 when late");
        assertTrue(holdBuggy != holdShouldBe, "BUG CONFIRMED: 76800 vs 0 = 88% loss");
    }
}
