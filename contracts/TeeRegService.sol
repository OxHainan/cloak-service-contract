// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.7;

contract TeeRegService {
    enum QuoteState {DEFAULT, FAILED, PASSED}
    struct TEENodeInfo {
        uint32 quoteSize;
        bytes quoteBuf;
        uint32 supSize;
        bytes supBuf;
        string teePublicKey;
        string p2pConnectInfo; //e.g. ip4/7.7.7.7/tcp/4242/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N
        address operator;
        QuoteState quoteState;
    }
    mapping(string => TEENodeInfo) teeRegMap; // key: peerId
    string[] teeRegList;

    function registerTEE(
        string memory peerId,
        uint32 quoteSize,
        bytes calldata quoteBuf,
        uint32 supSize,
        bytes calldata supBuf,
        string calldata teePublicKey,
        string calldata p2pConnectInfo
    ) external {
        TEENodeInfo storage teeNodeInfo = teeRegMap[peerId];
        require(teeNodeInfo.operator == address(0), "TEE registered already");
        teeNodeInfo.quoteSize = quoteSize;
        teeNodeInfo.quoteBuf = quoteBuf;
        teeNodeInfo.supSize = supSize;
        teeNodeInfo.supBuf = supBuf;
        teeNodeInfo.teePublicKey = teePublicKey;
        teeNodeInfo.p2pConnectInfo = p2pConnectInfo;
        teeNodeInfo.quoteState = QuoteState.PASSED;
        teeNodeInfo.operator = msg.sender;
        teeRegList.push(peerId);
    }

    function deleteTEE(string calldata peerId) external {
        TEENodeInfo storage teeNodeInfo = teeRegMap[peerId];
        require(teeNodeInfo.operator == msg.sender, "Permission denied: not operator");
        for (uint i = 0; i < teeRegList.length; i++) {
            if (keccak256(abi.encodePacked(teeRegList[i])) == keccak256(abi.encodePacked(peerId))) {
                teeRegList[i] = teeRegList[teeRegList.length - 1];
                teeRegList.pop();
                break;
            }
        }
        teeNodeInfo.quoteSize = 0;
        teeNodeInfo.quoteBuf = new bytes(0);
        teeNodeInfo.supSize = 0;
        teeNodeInfo.supBuf = new bytes(0);
        teeNodeInfo.teePublicKey = "";
        teeNodeInfo.p2pConnectInfo = "";
        teeNodeInfo.quoteState = QuoteState.DEFAULT;
        teeNodeInfo.operator = address(0);
    }

    function getQuote(string calldata peerId) external view returns (uint32, bytes memory, uint32, bytes memory) {
        TEENodeInfo memory teeNodeInfo = teeRegMap[peerId];
        return (teeNodeInfo.quoteSize, teeNodeInfo.quoteBuf, teeNodeInfo.supSize, teeNodeInfo.supBuf);
    }
}
