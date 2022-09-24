// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

/**
 * @title MultiSigWallet
 * @dev Wallet that requires signature of multiole owners for submitting transactions
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract MultiSigWallet {
    // deposit eth into contract account
    event Deposit(address indexed sender, uint amount);
    // submit a transaction for execution 
    event Submit(uint indexed txId);
    // sign the transaction for a single owner
    event Approve(address indexed owner, uint indexed txId);
    // revoke signature by an owner for a transaction
    event Revoke(address indexed owner, uint indexed txId);
    // excute a transaction only if we have enough signatures
    event Execute(uint indexed txId);

    // note that we need to store the array of owners separately from the mapping,
    // as solidity mappings have all possible keys, and we cannot (nor should we) iterate
    // across the key/value pairs
    address[] public owners;
    mapping(address => bool) public isOwner;
    // number of approvals required before a transaction can be executed. 
    // NOTE: check to ensure that this is greater than size of owners
    uint public required;
    
    struct Transaction {
        address to;
        // amount of ether set to to address
        uint value;
        // data sent to the to address
        bytes data;
        bool executed;
    }

    Transaction[] public transactions;
    // transation id => (owner address => approved?)
    mapping(uint => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only owners allowed to call this function");
        _;
    }

    modifier txExists(uint _txId) {
        // NOTE: another way we could do this in a gas efficient way
        // is by implementing a view method for iterating through 
        // transactions array and checking if txId exists, as it does 
        // not cost gas to call a view method.
        require(_txId < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notApproved(uint _txId) {
        require(!approved[_txId][msg.sender], "Transaction already approved");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "Transaction already executed");
        _;
    }

    modifier hasEnoughApprovals(uint _txId) {
        require(_getApproalCount(_txId) >= required, "Insufficient approvals");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "Owners required");
        require(
            _required > 0 && _required <= _owners.length,
            "Invalid required number of owners"
        );

        for (uint i; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Null address provided");
            require(!isOwner[_owners[i]], "Owner is not unique");
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }

        required =_required;
    }

    // NOTE: receive is a keyword in solidity functions. It is used to define a 
    // fallback function to simply receive ether. The function signature must 
    // always be as shown here
    receive() external payable {
        emit Deposit({
            sender: msg.sender, 
            amount: msg.value
        });
    }

    function submit(address _to, uint _value, bytes calldata _data) 
            external
            onlyOwner {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false
        }));
        emit Submit({txId: transactions.length - 1});
    }

    function approve(uint _txId)
            external
            onlyOwner
            txExists(_txId) 
            notApproved(_txId)
            notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        emit Approve({owner: msg.sender, txId: _txId});
    }

    function _getApproalCount(uint _txId) private view returns (uint count) {
        for (uint i; i < owners.length; i++) {
            if(approved[_txId][owners[i]]) {
                count++;
            }
        }
        // return count; // this is implied by adding the name in the return signature
    }

    function execute(uint _txId) 
            external 
            txExists(_txId)
            notExecuted(_txId)
            hasEnoughApprovals(_txId) {
        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Transaction failed");
        emit Execute(_txId);
    }

    function revoke(uint _txId) 
            external 
            onlyOwner 
            txExists(_txId) 
            notExecuted(_txId) {
        require(approved[_txId][msg.sender], "Transaction not approved");
        emit Revoke({owner: msg.sender, txId: _txId});
    }
}