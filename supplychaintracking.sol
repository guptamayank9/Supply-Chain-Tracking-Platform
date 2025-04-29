// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title SimpleSupplyChain
 * @dev Minimalist smart contract for supply chain tracking with 2-3 core functions
 */
contract SimpleSupplyChain {
    // Product structure with essential information
    struct Product {
        uint256 id;
        string name;
        string data;        // JSON string with product details
        address owner;      // Current custodian
        bool exists;
    }

    // Tracking event for product movement
    struct TrackingEvent {
        uint256 timestamp;
        string location;
        string status;      // e.g., "manufactured", "shipped", "delivered"
        address handler;    // Person/entity handling the product
    }
    
    // State variables
    mapping(uint256 => Product) public products;
    mapping(uint256 => TrackingEvent[]) public productHistory;
    address public admin;
    
    // Events
    event ProductCreated(uint256 indexed productId, address creator);
    event ProductTracked(uint256 indexed productId, string location, string status);
    
    // Constructor
    constructor() {
        admin = msg.sender;
    }
    
    // Modifier
    modifier productExists(uint256 _productId) {
        require(products[_productId].exists, "Product does not exist");
        _;
    }
    
    /**
     * @dev Register a new product in the supply chain
     * @param _productId Unique identifier for the product
     * @param _name Name of the product
     * @param _data Additional data in JSON format
     * @param _location Initial location of the product
     */
    function createProduct(
        uint256 _productId,
        string calldata _name,
        string calldata _data,
        string calldata _location
    ) external {
        require(!products[_productId].exists, "Product already exists");
        
        // Create product
        products[_productId] = Product({
            id: _productId,
            name: _name,
            data: _data,
            owner: msg.sender,
            exists: true
        });
        
        // Record initial tracking event
        TrackingEvent memory initialEvent = TrackingEvent({
            timestamp: block.timestamp,
            location: _location,
            status: "created",
            handler: msg.sender
        });
        
        productHistory[_productId].push(initialEvent);
        
        emit ProductCreated(_productId, msg.sender);
    }
    
    /**
     * @dev Track product movement and status changes
     * @param _productId ID of the product to track
     * @param _location Current location of the product
     * @param _status Status update (e.g., shipped, in-transit, delivered)
     */
    function trackProduct(
        uint256 _productId,
        string calldata _location,
        string calldata _status
    ) external productExists(_productId) {
        // Record tracking event
        TrackingEvent memory newEvent = TrackingEvent({
            timestamp: block.timestamp,
            location: _location,
            status: _status,
            handler: msg.sender
        });
        
        productHistory[_productId].push(newEvent);
        
        emit ProductTracked(_productId, _location, _status);
    }
    
    /**
     * @dev Transfer ownership of a product to a new custodian
     * @param _productId ID of the product to transfer
     * @param _newOwner Address of the new owner/custodian
     * @param _location Location where the transfer occurs
     */
    function transferProduct(
        uint256 _productId,
        address _newOwner,
        string calldata _location
    ) external productExists(_productId) {
        require(msg.sender == products[_productId].owner, "Only current owner can transfer");
        require(_newOwner != address(0), "Invalid new owner address");
        
        // Update product owner
        products[_productId].owner = _newOwner;
        
        // Record transfer event
        TrackingEvent memory transferEvent = TrackingEvent({
            timestamp: block.timestamp,
            location: _location,
            status: "transferred",
            handler: msg.sender
        });
        
        productHistory[_productId].push(transferEvent);
        
        emit ProductTracked(_productId, _location, "transferred");
    }
}
