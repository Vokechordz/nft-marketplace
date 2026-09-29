// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {MyNFT} from "../src/MyNFT.sol";

contract MyNFTTest is Test {

    MyNFT nft;

    address alice = address(1);

    function setUp() public {
        nft = new MyNFT();
    }

    function testMint() public {
        vm.prank(alice);

        nft.mint();

        assertEq(nft.ownerOf(0), alice);
    }
}