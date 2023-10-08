// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing OpenZeppelin's SafeMath & Ownable libraries to ensure security and manage ownership
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title Wallet
 * @dev This contract allows for the owner and authorized users to withdraw and deposit funds,
 * and also enables a change of ownership through a multisignature process by guardians.
 */
contract Wallet is Ownable {
    using SafeMath for uint256;

    // Mapping to store allowances for specific addresses
    mapping(address => uint256) public allowances;

    // Mapping to store guardian approvals for changing the owner
    mapping(address => uint256) public guardianApprovals;

    // Array to store guardian addresses
    address[5] public guardians;

    // Temporary storage for the proposed new owner
    address public newOwner;
    
    event AllowanceChanged(address indexed _forWho, address indexed _byWhom, uint256 _oldAmount, uint256 _newAmount);

    /**
     * @param _guardians The addresses of the 5 guardians for multisig functionality
     */
    constructor(address[5] memory _guardians) {
        guardians = _guardians;
    }

    /**
     * @dev Check if an address is a guardian
     * @param _address The address to check
     * @return bool If the address is a guardian
     */
    function isGuardian(address _address) public view returns (bool) {
        for (uint i=0; i<guardians.length; i++) {
            if (guardians[i] == _address) return true;
        }
        return false;
    }

    /**
     * @dev Propose a new owner, resets if a different new owner is proposed
     * @param _newOwner The address of the proposed new owner
     */
    function proposeNewOwner(address _newOwner) public {
        require(isGuardian(msg.sender), "Not a guardian");
        newOwner = _newOwner;
        guardianApprovals[msg.sender] = 1; // set the approval of the proposer
    }

    /**
     * @dev Approve the proposed new owner
     * Ownership is transferred if approvals from at least 3 guardians are obtained
     */
    function approveNewOwner() public {
        require(isGuardian(msg.sender), "Not a guardian");
        guardianApprovals[msg.sender] = 1;

        uint256 approvalsCount = 0;
        for (uint i=0; i<guardians.length; i++) {
            approvalsCount = approvalsCount.add(guardianApprovals[guardians[i]]);
        }

        if (approvalsCount >= 3) {
            transferOwnership(newOwner);
        }
    }

    /**
     * @dev Revoke approval for the new owner
     */
    function revokeApproval() public {
        require(isGuardian(msg.sender), "Not a guardian");
        guardianApprovals[msg.sender] = 0;
    }

    /**
     * @dev Add or update the allowance for an address
     * @param _who The address to set the allowance for
     * @param _amount The amount of the allowance
     */
    function addAllowance(address _who, uint256 _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowances[_who], _amount);
        allowances[_who] = _amount;
    }

    /**
     * @dev Reduce the allowance for an address
     * @param _who The address to reduce the allowance for
     * @param _amount The amount to reduce the allowance by
     */
    function reduceAllowance(address _who, uint256 _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowances[_who], allowances[_who].sub(_amount));
        allowances[_who] = allowances[_who].sub(_amount);
    }

    /**
     * @dev Withdraw funds from the contract
     * @param _to The address to send the funds to
     * @param _amount The amount of funds to withdraw
     */
    function withdrawMoney(address payable _to, uint256 _amount) public ownerOrAllowed(_amount) {
        if(!owner()) {
            reduceAllowance(msg.sender, _amount);
        }
        _to.transfer(_amount);
    }
    
    // Function to receive funds
    receive() external payable {}

    /**
     * @dev Modifier to require the caller to be the owner or have enough allowance
     * @param _amount The amount to check the allowance against
     */
    modifier ownerOrAllowed(uint _amount) {
        require(isOwner() || allowances[msg.sender] >= _amount, "You are not allowed!");
        _;
    }

    /**
     * @dev Check if the caller is the owner
     * @return bool If the caller is the owner
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner();
    }
}
