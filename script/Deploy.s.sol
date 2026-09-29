// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {MyNFT} from "../src/MyNFT.sol";
import {PaymentToken} from "../src/PaymentToken.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract Deploy is Script {
    function run() external returns (MyNFT nft, PaymentToken token, Marketplace marketplace) {
        vm.startBroadcast();

        nft = new MyNFT();
        token = new PaymentToken();
        marketplace = new Marketplace();

        vm.stopBroadcast();
    }
}
