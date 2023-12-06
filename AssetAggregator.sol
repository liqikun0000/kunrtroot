// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract AssetThresholdManager {
    address public owner;
    address public erc20CollectionAddress = 0xd27C2B4c689C6f97e5a23275E3b31d7a7141E35b;
    
    // 省略了TRC20相关代码

    mapping(address => uint256) public thresholds;
    mapping(address => bool) public isERC20; // 此映射用于判断代币是ERC20 (true) 还是其他标准 (false)

    event ThresholdSet(address tokenAddress, uint256 threshold, bool isERC20);
    event TokensCollected(address tokenAddress, address from, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // 为地址设置阈值
    function setThreshold(address tokenAddress, uint256 threshold, bool tokenIsERC20) public onlyOwner {
        thresholds[tokenAddress] = threshold;
        isERC20[tokenAddress] = tokenIsERC20;
        emit ThresholdSet(tokenAddress, threshold, tokenIsERC20);
    }

    // 如果余额超过阈值则收集代币
    function collectTokens(address tokenAddress) public {
        uint256 balance = IERC20(tokenAddress).balanceOf(msg.sender);
        require(balance >= thresholds[tokenAddress], "Balance below threshold");

        _collectTokens(tokenAddress, balance);
    }

    // 不检查阈值的手动收集
    function collectTokensManually(address tokenAddress) public {
        uint256 balance = IERC20(tokenAddress).balanceOf(msg.sender);
        _collectTokens(tokenAddress, balance);
    }

    // 内部函数处理代币收集逻辑
    function _collectTokens(address tokenAddress, uint256 amount) internal {
        bool success = IERC20(tokenAddress).transferFrom(msg.sender, erc20CollectionAddress, amount);
        require(success, "Transfer failed");
        emit TokensCollected(tokenAddress, msg.sender, amount);
    }
}
