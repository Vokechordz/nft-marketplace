// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {MyNFT} from "../src/MyNFT.sol";
import {PaymentToken} from "../src/PaymentToken.sol";

contract MarketplaceTest is Test {
    Marketplace marketplace;
    MyNFT nft;
    PaymentToken token;

    address alice = address(1);
    address bob = address(2);

    function setUp() public {
        marketplace = new Marketplace();
        nft = new MyNFT();
        token = new PaymentToken();
    }

    function testListNFT() public {
        vm.prank(alice);
        nft.mint();

        vm.prank(alice);
        nft.approve(address(marketplace), 0);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 100);

        assertEq(nft.ownerOf(0), address(marketplace));

        (address seller, uint256 tokenId, uint256 price) = marketplace.listings(0);

        assertEq(seller, alice);
        assertEq(tokenId, 0);
        assertEq(price, 100);
    }

    function testNFTListedEvent() public {
        vm.prank(alice);
        nft.mint();

        vm.prank(alice);
        nft.approve(address(marketplace), 0);

        vm.expectEmit(true, true, true, true);

        emit Marketplace.NFTListed(alice, address(nft), 0, 100);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 100);
    }

    function testBuyNFT() public {
        vm.prank(alice);
        nft.mint();

        vm.prank(alice);
        nft.approve(address(marketplace), 0);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 100);

        token.mint(bob, 100);

        vm.prank(bob);
        token.approve(address(marketplace), 100);

        vm.prank(bob);
        marketplace.buyNFT(address(nft), 0, address(token));

        assertEq(nft.ownerOf(0), bob);
        assertEq(token.balanceOf(alice), 98);
        assertEq(token.balanceOf(address(this)), 2);
        assertEq(token.balanceOf(bob), 0);
    }

    function testNFTSoldEvent() public {
        vm.prank(alice);
        nft.mint();

        vm.prank(alice);
        nft.approve(address(marketplace), 0);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 100);

        token.mint(bob, 100);

        vm.prank(bob);
        token.approve(address(marketplace), 100);

        vm.expectEmit(true, true, true, true);

        emit Marketplace.NFTSold(bob, alice, address(nft), 0, 100, 2);

        vm.prank(bob);
        marketplace.buyNFT(address(nft), 0, address(token));
    }

    function testCancelListing() public {
        vm.prank(alice);
        nft.mint();

        vm.prank(alice);
        nft.approve(address(marketplace), 0);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 100);

        vm.prank(alice);
        marketplace.cancelListing(address(nft), 0);

        assertEq(nft.ownerOf(0), alice);

        (address seller, uint256 tokenId, uint256 price) = marketplace.listings(0);

        assertEq(seller, address(0));
        assertEq(tokenId, 0);
        assertEq(price, 0);
    }

    function testListingCancelledEvent() public {
        vm.prank(alice);
        nft.mint();

        vm.prank(alice);
        nft.approve(address(marketplace), 0);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 100);

        vm.expectEmit(true, true, true, true);

        emit Marketplace.ListingCancelled(alice, address(nft), 0);

        vm.prank(alice);
        marketplace.cancelListing(address(nft), 0);
    }

    function testCannotListNFTForZeroPrice() public {
        vm.prank(alice);
        nft.mint();

        vm.prank(alice);
        nft.approve(address(marketplace), 0);

        vm.expectRevert(Marketplace.PriceMustBeGreaterThanZero.selector);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 0);
    }

    function testCannotCancelSomeoneElsesListing() public {
        vm.prank(alice);
        nft.mint();

        vm.prank(alice);
        nft.approve(address(marketplace), 0);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 100);

        vm.expectRevert(Marketplace.NotSeller.selector);

        vm.prank(bob);
        marketplace.cancelListing(address(nft), 0);
    }

    function testCannotBuyNFTThatIsNotListed() public {
        vm.expectRevert(Marketplace.NFTNotListed.selector);

        vm.prank(bob);
        marketplace.buyNFT(address(nft), 0, address(token));
    }

    function testCannotListNFTTwice() public {
        vm.prank(alice);
        nft.mint();

        vm.prank(alice);
        nft.approve(address(marketplace), 0);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 100);

        vm.expectRevert(Marketplace.AlreadyListed.selector);

        vm.prank(alice);
        marketplace.listNFT(address(nft), 0, 200);
    }

    function testOnlyOwnerCanChangeFee() public {
        vm.expectRevert(Marketplace.NotOwner.selector);

        vm.prank(bob);
        marketplace.setFeePercent(5);
    }

    function testOwnerCanChangeFee() public {
        marketplace.setFeePercent(5);

        assertEq(marketplace.feePercent(), 5);
    }

    function testFeeUpdatedEvent() public {
        vm.expectEmit(false, false, false, true);

        emit Marketplace.FeeUpdated(2, 5);

        marketplace.setFeePercent(5);
    }

    function testCannotSetFeeAbove10Percent() public {
        vm.expectRevert(Marketplace.FeeTooHigh.selector);

        marketplace.setFeePercent(11);
    }
}
