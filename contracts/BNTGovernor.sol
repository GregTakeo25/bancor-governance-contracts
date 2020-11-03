// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./ISmartToken.sol";

/// @title The BNT Governor contract is used to govern the BNT ERC20 token by restricting its launch-time initial
/// administrative privileges.
contract BNTGovernor is AccessControl {
    // The governor role is used to globally govern the contract and its roles.
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    // The minter role is used to control who can request the BNT ERC20 token to mint additional tokens.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // The address of the BNT ERC20 token.
    ISmartToken public token;

    /// @dev Initializes the contract.
    ///
    /// @param bntToken The address of the BNT ERC20 token.
    constructor(ISmartToken bntToken) public {
        require(address(bntToken) != address(0), "ERR_INVALID_ADDRESS");

        token = bntToken;

        // Set up administrative roles.
        _setRoleAdmin(GOVERNOR_ROLE, GOVERNOR_ROLE);
        _setRoleAdmin(MINTER_ROLE, GOVERNOR_ROLE);

        // Allow the deployer to initially govern the contract.
        _setupRole(GOVERNOR_ROLE, _msgSender());
    }

    /// @dev Accepts the ownership of the token. Only allowed by the GOVERNOR role.
    function acceptTokenOwnership() external {
        require(hasRole(GOVERNOR_ROLE, _msgSender()), "ERR_ACCESS_DENIED");

        token.acceptOwnership();
    }

    /// @dev Issues new BNT tokens. Only allowed by the MINTER role.
    ///
    /// @param to Account to receive the new amount.
    /// @param amount Amount to increase the supply by.
    ///
    function issue(address to, uint256 amount) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERR_ACCESS_DENIED");

        token.issue(to, amount);
    }

    /// @dev Removes existing BNT tokens. Only allowed by the MINTER role or the owners themselves.
    ///
    /// @param from Account to remove the amount from.
    /// @param amount Amount to decrease the supply by.
    ///
    function destroy(address from, uint256 amount) external {
        address msgSender = _msgSender();
        require(hasRole(MINTER_ROLE, msgSender) || from == msgSender, "ERR_ACCESS_DENIED");

        token.destroy(from, amount);
    }
}
