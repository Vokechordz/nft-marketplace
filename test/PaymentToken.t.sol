// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {PaymentToken} from "../src/PaymentToken.sol";

contract PaymentTokenTest is Test {
    PaymentToken token;

    address alice = address(1);

    function setUp() public {
        token = new PaymentToken();
    }

    function testMint() public {
        token.mint(alice, 1000);

        assertEq(token.balanceOf(alice), 1000);
    }
}
