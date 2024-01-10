// SPDX-License-Identifier: Apache-2.0
pragma solidity >= 0.8.7;

contract TENET 
{
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
        string appAddr;
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
        string calldata p2pConnectInfo,
        string calldata appAddr
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
        teeNodeInfo.appAddr = appAddr;
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

    struct ApiInfo {
	    string appAddr; // 合约地址或url地址(对于web2应用)
	    string method; // 方法
	    uint timeout; // 此接口承诺的最长执行时间
    }
    mapping(string => ApiInfo) apiInfoMap; // key: appAddr+method

    function registerApi(
        string calldata peerId,
        string calldata appAddr,
        string calldata method,
        uint timeout
    ) external {
        TEENodeInfo storage teeNodeInfo = teeRegMap[peerId];
        require(teeNodeInfo.operator == msg.sender, "Permission denied: not operator");
        require(keccak256(abi.encodePacked(teeNodeInfo.appAddr)) == keccak256(abi.encodePacked(appAddr)), "Permission denied: node not belong to the app");
        ApiInfo storage apiInfo = apiInfoMap[string(abi.encodePacked(appAddr,method))];
        apiInfo.appAddr = appAddr;
        apiInfo.method = method;
        apiInfo.timeout = timeout;
    }

    struct Transaction {
        bytes txId;
        uint256 nonce;
        uint256 gasPrice;
        uint256 gasLimit;
        address to;
        uint256 value;
        bytes input;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 chainId;
    }
    struct ChallengeData {
	    bytes challengeId; // 挑战ID，即对应本次交易ID
	    bytes requestId; // 调用链ID，可使用depth=0的交易ID
	    Transaction tx; // 即常规交易所包含参数
	    uint timeout; // block height
	    address caller; // 挑战方
	    address callee; // 被挑战方
	    uint callDepth; // 当前调用深度
	    uint status; // [challenging=1, frozen=2, responsed=3, timeout=4, punished=5]
    }
    struct ResponseData {
        bytes challengeId;
        address caller;
        address callee;
        bytes[] param;
        bytes[] output;
        bytes[] newStates;
        Transaction tx;
    }
    mapping(bytes => ChallengeData) challengeMap; // key = challengeId
    mapping(bytes => ResponseData) responseMap; // key = challengeId

    function newChallenge(ChallengeData calldata data) public {
        ChallengeData storage challengeData = challengeMap[data.challengeId];
	    require(challengeData.challengeId.length == 0, "Challenge existed");
        challengeMap[data.challengeId] = data;
    }

    function updateChallenge(
        string calldata appAddr,
        bytes calldata challengeId, 
        uint timeout,
        uint status,
        string calldata peerId,
        bytes calldata sig
    ) public {
        bytes memory data = abi.encodePacked(appAddr, challengeId, timeout, status, peerId);
        bytes32 data32;
        assembly {
            data32 := mload(add(data, 32))
        }
        verifyTEESig(data32, peerId, sig);
        ChallengeData storage challengeData = challengeMap[challengeId];
	    require(challengeData.challengeId.length != 0, "Challenge not existed");
        if (timeout != 0) {
            challengeData.timeout = timeout;
        }
        if (status != 0) {
            challengeData.status = status;
        }
    }

    function response(ResponseData calldata data) public {
        ResponseData storage responseData = responseMap[data.challengeId];
	    require(responseData.challengeId.length == 0, "Response existed");
        responseMap[data.challengeId] = data;
    }

    function verifyTEESig(bytes32 data, string calldata peerId, bytes calldata sig) internal {
        TEENodeInfo storage teeNodeInfo = teeRegMap[peerId];
        require(recoverSigner(data, sig) == stringToAddress(teeNodeInfo.teePublicKey), "Failed to verify TEE sig");
    }

    function recoverSigner(bytes32 message,bytes memory sig) internal pure returns(address){
        (uint8 v,bytes32 r,bytes32 s) = splitSignature(sig);
        return ecrecover(message,v,r,s);
    }

    function splitSignature(bytes memory sig) internal pure returns(uint8 v,bytes32 r,bytes32 s){
        require(sig.length == 65);
        assembly{
            r:=mload(add(sig,32))
            s:=mload(add(sig,64))
            v:=byte(0,mload(add(sig,96)))
        }
        return (v,r,s);
    }

    function stringToAddress(string memory str) internal pure returns (address) {
        address addr;
        assembly {
            addr := mload(add(str, 20))
        }
        return addr;
    }

}