// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Deposit {
    using SafeMath for uint256;
    mapping(address => uint256) public coins;

    receive() external payable {
        require(msg.value > 0, "Invalid arguement with value");
        coins[msg.sender] = coins[msg.sender].add(msg.value);
    }

    function withdrawl(uint256 amount) external {
        require(coins[msg.sender] >= amount, "Coin is not enough");
        coins[msg.sender] = coins[msg.sender].sub(amount);
        Address.sendValue(payable(msg.sender), amount);
    }

    function deduct(address party, uint256 amount) internal {
            require(coins[party] >= amount, "Require amount larger than coin");
            coins[party] = coins[party].sub(amount);
    }

    function deduct(address[] memory parties, uint256 amount) internal {
        for (uint256 i = 0; i < parties.length; i++) {
            deduct(parties[i], amount);
        }
    }
}
