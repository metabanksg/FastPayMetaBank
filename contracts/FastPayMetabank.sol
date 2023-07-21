// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TransferHelperTron.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract FastPayMetabank is Ownable {
    event AddMerchantAddress(address indexed merchant, address indexed addr);

    event CashSweep(
        address indexed merchant,
        address indexed token,
        uint256 sweepAmt,
        uint256 sweepCount
    );

    event Claim(address indexed caller, address indexed token, uint256 amount);

    mapping(address => mapping(address => uint256)) public balanceOf;

    mapping(address => address[]) public merchantAddress;

    address private withdrawAddress;

    address private manager;

    constructor(address _address) {
        withdrawAddress = _address;
        manager = msg.sender;
    }

    modifier onlyManager() {
        require(manager == msg.sender, "Manager: caller is not the manager");
        _;
    }

    function addMerchantAddress(
        address _merchant,
        address _addr
    ) external onlyManager {
        require(_merchant != _addr);
        require(address(0) != _merchant);

        merchantAddress[_merchant].push(_addr);

        emit AddMerchantAddress(_merchant, _addr);
    }

    function cashSweep(
        address _token,
        uint256 _start
    ) external returns (uint256 sweepAmt, uint256 sweepCount) {
        require(address(0) != _token);
        (sweepAmt, sweepCount) = sweep(msg.sender, _token, _start);

        emit CashSweep(msg.sender, _token, sweepAmt, sweepCount);

        return (sweepAmt, sweepCount);
    }

    function sweep(
        address _merchant,
        address _token,
        uint256 _start
    ) internal returns (uint256, uint256) {
        address[] memory addresses = merchantAddress[_merchant];
        uint256 sweepAmount = 0;
        uint256 count = 0;

        for (uint256 index = _start; index < addresses.length; index++) {
            if (count > 500) {
                break;
            }
            count++;
            if (index > addresses.length || address(0) == addresses[index]) {
                break;
            }

            uint256 balance = IERC20(_token).balanceOf(addresses[index]);
            uint256 allowance = IERC20(_token).allowance(
                addresses[index],
                address(this)
            );

            if (balance > 0 && allowance >= balance) {
                TransferHelperTron.safeTransferFrom(
                    _token,
                    addresses[index],
                    address(this),
                    balance
                );
                sweepAmount = SafeMath.add(sweepAmount, balance);
            }
        }

        balanceOf[_merchant][_token] += sweepAmount;

        return (sweepAmount, addresses.length - _start);
    }

    function getTimes() public view returns (uint256) {
        return block.timestamp;
    }

    function changeManager(address _newManager) external onlyOwner {
        manager = _newManager;
    }

    function withdrawFunds(address _token, uint256 _amt) external onlyManager {
        require(address(0) != _token);
        uint256 pay_amt;
        if (_amt == 0) {
            pay_amt = IERC20(_token).balanceOf(address(this));
        } else {
            pay_amt = _amt;
        }
        TransferHelperTron.safeTransfer(_token, withdrawAddress, pay_amt);
    }
}