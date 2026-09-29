// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Marketplace {

    using SafeERC20 for IERC20;

    error PriceMustBeGreaterThanZero();
    error NotSeller();
    error NFTNotListed();
    error AlreadyListed();
    error NotOwner();
    error FeeTooHigh();

    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price;
    }

    address public owner;
    uint256 public feePercent = 2;

    mapping(uint256 => Listing) public listings;

    event NFTListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );

    event NFTSold(
        address indexed buyer,
        address indexed seller,
        address indexed nftAddress,
        uint256 tokenId,
        uint256 price,
        uint256 fee
    );

    event ListingCancelled(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );

    event FeeUpdated(
        uint256 oldFee,
        uint256 newFee
    );

    constructor() {
        owner = msg.sender;
    }

    function listNFT(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    ) public {

        if (price == 0) {
            revert PriceMustBeGreaterThanZero();
        }

        if (listings[tokenId].seller != address(0)) {
            revert AlreadyListed();
        }

        IERC721(nftAddress).transferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        listings[tokenId] = Listing({
            seller: msg.sender,
            tokenId: tokenId,
            price: price
        });

        emit NFTListed(
            msg.sender,
            nftAddress,
            tokenId,
            price
        );
    }

    function buyNFT(
        address nftAddress,
        uint256 tokenId,
        address paymentToken
    ) public {

        Listing memory listing = listings[tokenId];

        if (listing.seller == address(0)) {
            revert NFTNotListed();
        }

        uint256 fee = (listing.price * feePercent) / 100;
        uint256 sellerAmount = listing.price - fee;

        IERC20(paymentToken).safeTransferFrom(
            msg.sender,
            owner,
            fee
        );

        IERC20(paymentToken).safeTransferFrom(
            msg.sender,
            listing.seller,
            sellerAmount
        );

        IERC721(nftAddress).transferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        emit NFTSold(
            msg.sender,
            listing.seller,
            nftAddress,
            tokenId,
            listing.price,
            fee
        );

        delete listings[tokenId];
    }

    function cancelListing(
        address nftAddress,
        uint256 tokenId
    ) public {

        Listing memory listing = listings[tokenId];

        if (listing.seller == address(0)) {
            revert NFTNotListed();
        }

        if (listing.seller != msg.sender) {
            revert NotSeller();
        }

        IERC721(nftAddress).transferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        emit ListingCancelled(
            msg.sender,
            nftAddress,
            tokenId
        );

        delete listings[tokenId];
    }

    function setFeePercent(
        uint256 _feePercent
    ) public {

        if (msg.sender != owner) {
            revert NotOwner();
        }

        if (_feePercent > 10) {
            revert FeeTooHigh();
        }

        uint256 oldFee = feePercent;

        feePercent = _feePercent;

        emit FeeUpdated(
            oldFee,
            _feePercent
        );
    }
}



/* NFT Marketplace - Sepolia Deployment

Network: Ethereum Sepolia
Chain ID: 11155111

MyNFT:
0xcE57a195B057567647A21E6a481D38cc63f37F47

PaymentToken:
0x8ADe3678D17b39531f103c3c3473A9A9c87cbDf9

Marketplace:
0xD7379C39Ac0cdf080f7450d93807e0deF73036c6 */