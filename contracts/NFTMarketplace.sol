// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3; // version of solidity

/*_tranfer, _mint, _setTokenURI are functions from the openzeppelin library
  _tranfer is used to transfer the token from the seller to the contract address to create the market item for the token id
  _mint is used to mint the token
  _setTokenURI is used to set the token URI
  _tokenIds is used to count the number of tokens
  _itemsSold is used to count the number of tokens sold
*/




//INTERNAL IMPORTS FROM OPENZEPPELIN
import "@openzeppelin/contracts/utils/Counters.sol"; // to count the number of tokens
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // to store the token
import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; // to create the token
import "hardat/console.sol"; // to debug the smart contract
// inherit from ERC721Storage

contract NFTMarketplace is ERC721Storage

{
    using Conters for Counters.Counter; // to count the number of tokens

    uint256 listingPrice = 0.0025 ether; // the price to list the token

    Counters.Counter private _itemIds; // to count the number of tokens
    Counters.Counter private _itemsSold; // to count the number of tokens sold

    address payable owner; // the owner of the contract

    mapping(uint256 => MarketItem) private idMaarketItem; // mapping to store the token id and the market item

    struct MarketItem // the market item struct to store the token id, seller, owner, price and sold status of the token
    {
        uint256 tokenId; // token id
        address payable seller; // seller
        address payable owner; // owner
        uint256 price; // price
        bool sold; // sold
    }
    // event to notify the creation of the market item for the token id in the blockchain

    event MarketItemCreated
    (
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    // modifier to check if the caller is the owner of the contract

    modifier onlyOwner()
    {
         // only the owner of the contract can call this function to update the listing price of the token
         require(msg.sender == owner, "Only owner can call this function");
        _; // continue execution of the function after the modifier is executed
    }
    // constructor to deploy the smart contract and set the name and symbol of the token
    constructor() ERC721 ("NFT Metavarse Token", "MYNFT")
    {
        owner = payable(msg.sender); // who ever deploy the smart contract becomes the owner
    }
    // the market place will charge a fee for every transaction
    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner
    {
        listingPrice = _listingPrice;  // update the listing price of the token in the marketplace by the owner of the contract
    }

    //fetch the listing price of the token in the marketplace by the owner of the contract to the caller of the function
    function getListingPrice() public view returns(uint256)
    {
        // return the listing price of the token in the marketplace by the owner of the contract to the caller of the function
        return listingPrice;
    }

    // create nft token function
    function createToken(string memory tokenURI, unt256 price) public returns(uint256)
    {
        _tokenIds.increment(); // increment the token id to create the token

        // fetch the token id to create the token from the mapping using the token id as the key to the mapping
        unt256 newTokenId = _tokenIds.current();
        // mint the token to the caller of the function to create the token using the token id as the key to the mapping and the token URI as the value to the mapping
        mint(msg.sender, newTokenId);
        // set the token URI to the caller of the function to create the token using the token id as the key to the mapping and the token URI as the value to the mapping
        setTokenURI(newTokenId, tokenURI);

        // create the market item for the token id in the marketplace using the token id as the key to the mapping and the price as the value to the mapping
        createMarketItem(newTokenId, price);

        // return the token id to the caller of the function to create the token using the token id as the key to the mapping and the token URI as the value to the mapping
        return newTokenId;
    }
    // create market item function
    function createMarketItem(uint256 tokenId, uint256 price )private
    {
        // the price of the token must be greater than 0 to create the market item for the token id in the marketplace
        require(price > 0, "Price must be at least 1");
        // the price must be equal to the listing price to create the market item for the token id in the marketplace
        require(msg.value == listingprice,"price must be equal to listing price");


        idMaarketItem[tokenId] = MarketItem(
            tokenId, // token id
            payable(msg.sender),// seller of the token
            payable(address(this)),// money goes to the contract address to create the market item for the token id in the marketplace
            price,// price
            false // sold
        );
        // transfer the token from the seller to the contract address to create the market item for the token id
        tranfer(msg.sender, address(this), tokenId);
        // emit the event to the blockchain to notify the creation of the market item for the token id
        emit idMarketItemCreated(tokenId, msg.sender, address(this), price, false);
    }
    // Function for reselling the token in the marketplace
    function reSellToken(uint256 tokenid, uint256 price)public payable
    {
        //only the owner of the token can resell in the marketplace
        require((idMarketItem[tokenId].owner == msg.sender), "only owner can resell the token");
        // the price must be equal to the listing price to resell the token in the marketplace
        require(msg.value == listingprice,"price must be equal to listing price");
        // the token is not sold yet
        idMarketItem[tokenId].sold = false;
        // the price of the token is updated to the new price to resell the token in the marketplace again
        idMarketItem[tokenId].price = price;
        // the seller of the token is updated to the new seller to resell the token in the marketplace again
        idMarketItem[tokenId].seller = payable(msg.sender);
        // the owner of the token is updated to the contract address to resell the token in the marketplace
        idMarketItem[tokenId].owner = payable(address(this));

        _itemsold.decrement(); // the number of tokens sold is decremented

        // transfer the token from the seller to the contract address to create the market item for the token id
        tranfer(msg.sender, address(this), tokenId);
    }
    // function to create market item sale
    function createMarketSell(uint256 tokenId) public payable
    {
        // fetch the price of the token from the mapping using the token id as the key to the mapping
        uint256 price = idMarketItem[tokenId].price;

        // the buyer must pay the price of the token to complete the purchase of the token in the marketplace
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

    // the owner of the token is updated to the buyer of the token in the marketplace to complete the purchase of the token in the marketplace
    idMarketItem[tokenId].owner = payable(msg.sender);
    // the token is sold to the buyer of the token in the marketplace to complete the purchase of the token in the marketplace
    idMarketItem[tokenId].sold = true;
    // the owner of the token is updated to the contract address to resell the token in the marketplace
    idMarketItem[tokenId].owner = payable(address(0));

    _itemsold.increment(); // the number of tokens sold is incremented

    // transfer the token from the contract address to the buyer of the token in the marketplace to complete the purchase of the token in the marketplace
    tranfer(address(this), msg.sender, tokenId);

    // the owner of the contract gets the listing price of the token in the marketplace for every transaction
    payable(owner).transfer(listingPrice); // whenever someone sells the token I get some comission
    payable(idMarketItem[tokenId].seller).tranfer(msg.value); // whenever someone buys the token the seller gets the money

    }
    // getting unsold NFT data
    function fetchMarketItem() public view returns(MarketItem[] memory)
    {
        uint256 itemCount = _tokenIds.current(); // the number of tokens
        uint256 unsoldItemCount = _tokenIds.current() - _itemsSold.current(); // the number of unsold tokens in the marketplace
        uint256 currentIndex = 0; // the current index of the token in the marketplace

        MarketItem[] memory items = new MarketItem[](unsoldItemCount); // array to store the unsold tokens in the marketplace
        for (uint256 i = 0; i < itemCount; i++) // loop through the tokens in the marketplace
        {
            if(idMarketItem[i + 1].owner == address(this)) // if the token is not sold
            {
                uint256 currentId = idMarketItem[i + 1].tokenId; // the current token id in the marketplace
                MarketItem storage currentItem = idMarketItem[currentId]; // the current token item
                items[currentIndex] = currentItem; // add the current token to the array of unsold tokens in the marketplace
                currentIndex += 1; // increment the current index of the token in the marketplace by 1
            }

        }
         // return the array of unsold tokens in the marketplace
         returns items;
    }
    // Purchase nft token function
    function fetchMyNFT() public view returns (MarketItem[] memory)
    {
        uint256 totalCount = _tokenIds.current(); // the number of tokens in the marketplace for the caller of the function
        uint256 itemCount = 0; // the number of tokens in the marketplace for the caller of the function that are not sold
        uint256 currentIndex = 0; // the current index of the token in the marketplace for the caller of the function

        for (uint256 i = 0; i < totalCount ; i++) // loop through the tokens in the marketplace for the caller of the function
        {
            if(idMarketItem[i + 1].owner == msg.sender) // check the owner of the token in the marketplace for the caller of the function
            {
                itemCount += 1; // increment the number of tokens in the marketplace for the caller of the function that are not sold by 1
            }
        }
        MarketItem[] memory items = new MarketItem[](itemCount);// array to store the tokens in the marketplace for the caller of the function that are not sold
        for (uint256 i = 0; i < totalCount ; i++) // loop through the tokens in the marketplace for the caller of the function
        {
            if (idMarketItem[i+1].owner == msg.sender) // check the owner of the token in the marketplace for the caller of the function
            {
                uint256 currentId = idMarketItem[i + 1].tokenId; // the current token id in the marketplace for the caller of the function
                MarketItem storage currentItem = idMarketItem[currentId]; // the current token item in the marketplace for the caller of the function
                items[currentIndex] = currentItem; // add the current token to the array of tokens in the marketplace for the caller of the function that are not sold
                currentIndex += 1; // increment the current index of the token in the marketplace for the caller of the function by 1
            }
        }
        return items; // return the array of tokens in the marketplace for the caller of the function that are not sold
    }

    // single user items
    function fetchItemsListed()public view returns (MarketItem [] memory)
    {
        uint256 totalItemCount = _tokenIds.current(); // the number of tokens in the marketplace for the caller of the function
        uint256 itemCount = 0; // the number of tokens in the marketplace for the caller of the function that are not sold
        uint256 currentIndex = 0; // the current index of the token in the marketplace for the caller of the function

        for (uint256 i = 0; i < totalCount; i++)
        {
            if(id MarketItem[i + 1].seller == msg.sender)// check the seller of the token in the marketplace for the caller of the function
            {
                itemCount += 1; // increment the number of tokens in the marketplace for the caller of the function that are not sold by 1
            }

        }
        MarketItem[] memory items = new MarketItem[](itemCount);// array to store the tokens in the marketplace for the caller of the function that are not sold
        for(uint256 i = 0; i < totalItemCount; i++) // loop through the tokens in the marketplace for the caller of the function
        {
            if(idMarketItem[i = 1].seller == msg.sender)
            {
                uint256 currentId = i +1 ; // the current token id in the marketplace for the caller of the function

                MarketItem storage currentItem = idMarketItem[currentId];// the current token item in the marketplace for the caller of the function
                items[currentIndex] = currentItem; // add the current token to the array of tokens in the marketplace for the caller of the function that are not sold
                currenentIndex += 1; // increment the current index of the token in the marketplace for the caller of the function by 1

            }
        }
        return items; // return the array of tokens in the marketplace for the caller of the function that are not sold
    }
}