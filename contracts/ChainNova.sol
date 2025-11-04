// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ChainNova
 * @dev Decentralized dynamic ledger and registrar with data categorization and user registration.
 */
contract ChainNova {
    struct Entry {
        bytes32 dataHash;        // Data hash (quantum-resistant recommended)
        address submitter;       // Submitter’s address
        uint256 timestamp;       // Block timestamp at entry submission
        string category;         // Data category or tag (e.g., “document”, “transaction”)
        string metadataURI;      // Off-chain metadata location (IPFS, Arweave)
    }

    // User registration storing additional info (optional)
    struct User {
        string username;
        bool registered;
    }

    mapping(address => User) public users;

    // Mapping entry IDs to Entries
    mapping(uint256 => Entry) private entries;
    uint256 private entryCount;

    event UserRegistered(address indexed user, string username);
    event EntrySubmitted(uint256 indexed entryId, bytes32 indexed dataHash, address indexed submitter, string category, uint256 timestamp, string metadataURI);

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }

    /**
     * @dev Register as a user with a unique username
     * @param username Desired username as string
     */
    function registerUser(string calldata username) external {
        require(!users[msg.sender].registered, "Already registered");
        require(bytes(username).length > 0, "Username required");

        users[msg.sender] = User({
            username: username,
            registered: true
        });

        emit UserRegistered(msg.sender, username);
    }

    /**
     * @dev Submit new data entry associated with user and category
     * @param dataHash Hash of data (use quantum-resistant hash)
     * @param category Category or type tag of data
     * @param metadataURI Off-chain metadata URI (optional)
     */
    function submitEntry(bytes32 dataHash, string calldata category, string calldata metadataURI) external onlyRegistered {
        require(dataHash != bytes32(0), "Invalid data hash");
        require(bytes(category).length > 0, "Category required");

        entryCount++;
        entries[entryCount] = Entry({
            dataHash: dataHash,
            submitter: msg.sender,
            timestamp: block.timestamp,
            category: category,
            metadataURI: metadataURI
        });

        emit EntrySubmitted(entryCount, dataHash, msg.sender, category, block.timestamp, metadataURI);
    }

    /**
     * @dev Returns total submitted entries count
     */
    function getEntryCount() external view returns (uint256) {
        return entryCount;
    }

    /**
     * @dev Retrieve entry details by ID
     * @param entryId Entry ID to retrieve
     */
    function getEntry(uint256 entryId) external view returns (
        bytes32 dataHash,
        address submitter,
        uint256 timestamp,
        string memory category,
        string memory metadataURI
    ) {
        require(entryId > 0 && entryId <= entryCount, "Entry does not exist");

        Entry storage e = entries[entryId];
        return (e.dataHash, e.submitter, e.timestamp, e.category, e.metadataURI);
    }

    /**
     * @dev Verify if a hash matches the stored hash for a given entry
     * @param entryId Entry ID
     * @param dataHash Hash to verify
     */
    function verifyEntry(uint256 entryId, bytes32 dataHash) external view returns (bool) {
        require(entryId > 0 && entryId <= entryCount, "Entry does not exist");
        return entries[entryId].dataHash == dataHash;
    }
}
