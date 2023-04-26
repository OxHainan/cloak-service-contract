

pragma solidity ^0.8.0;

contract Oracle {


    uint public publishWithBytesFunc = 100;
    mapping(uint => uint) public businessTypeToAddr;
    mapping(uint => mapping(uint => uint)) public typeToTopicsValue;
    mapping(uint => uint) public typeToTopicsLength;
    mapping(uint => mapping(uint => uint)) public topicToAddrValue;
    mapping(uint => uint) public topicToAddrLength;
    uint public reqId;
    uint public randomNumbers;
    uint public block_number = 125;
    address public party0;
    address public party1;
    address public party2;
    address public party3;
    address public party4;
    address public party5;
    address public party6;
    address public party7;
    address public party8;
    address public party9;
    constructor(address _party0, address _party1, address _party2, address _party3, address _party4, address _party5, address _party6, address _party7, address _party8, address _party9) public {
        party0 = _party0;
        party1 = _party1;
        party2 = _party2;
        party3 = _party3;
        party4 = _party4;
        party5 = _party5;
        party6 = _party6;
        party7 = _party7;
        party8 = _party8;
        party9 = _party9;
    }
    function request(uint callbackAddr, uint callbackFunc, uint reqData) public returns (uint) {
        require(callbackFunc >= 0);
        require(reqData > 0);
        uint reqIdReplied = reqId;
        reqId = reqId + 1;
        return reqIdReplied;
    }
    function replyWithBytes(uint _reqId, uint callbackAddr, uint callbackFunc, uint statusCode, uint responseData) public returns (bool) {
        bool success = true;
        return success;
    }
    function replyWithUint(uint _reqId, uint callbackAddr, uint callbackFunc, uint statusCode, uint responseData) public returns (bool) {
        bool success = true;
        return success;
    }
    function replyWithUintArray(uint _reqId, uint callbackAddr, uint callbackFunc, uint statusCode, uint responseData, uint responseDataSize) public returns (bool) {
        bool success = true;
        return success;
    }
    function getSubscriptionInfo(uint businessType, uint index) public returns (uint) {
        return typeToTopicsValue[businessType][index];
    }
    function subscribe(uint businessType, uint busiContractAddr, uint topic) public {
        uint contractAddr = businessTypeToAddr[businessType];
        if (contractAddr != 0) {
            businessTypeToAddr[businessType] = busiContractAddr;
        }
        uint element = topic;
        bool isStrExisted = false;
        uint i = 0;
        if (i < typeToTopicsLength[businessType]) {
            if (typeToTopicsValue[businessType][i] == element) {
                isStrExisted = true;
            }
        }
        if (!isStrExisted) {
            uint index = typeToTopicsLength[businessType];
            typeToTopicsValue[businessType][index] = topic;
            typeToTopicsLength[businessType] = index + 1;
        }
        uint addr = 0;
        uint addr_index = 10086;
        i = 0;
        if (i < topicToAddrLength[topic]) {
            if (topicToAddrValue[topic][i] == addr) {
                addr_index = i;
            }
        }
        if (addr_index == 10086) {
            uint index = topicToAddrLength[topic];
            topicToAddrValue[topic][index] = 0;
            topicToAddrLength[topic] = index + 1;
        }
    }
    function unsubscribe(uint businessType, uint topic) public {
        uint addr = 0;
        uint addr_index = 10086;
        uint i = 0;
        if (i < topicToAddrLength[topic]) {
            if (topicToAddrValue[topic][i] == addr) {
                addr_index = i;
            }
        }
        if (addr_index != 10086) {
            require(addr_index >= topicToAddrLength[topic]);
            uint i = addr_index;
            if (i < topicToAddrLength[topic] - 1) {
                uint temp = i + 1;
                topicToAddrValue[topic][i] = temp;
            }
            uint tem_index = topicToAddrLength[topic] - 1;
            topicToAddrLength[topic] = topicToAddrLength[topic] - 1;
        }
        uint str = topic;
        uint strIndex = 10086;
        if (topicToAddrLength[topic] == 0) {
            uint i = 0;
            if (i < topicToAddrLength[topic]) {
                if (typeToTopicsValue[businessType][i] == str) {
                    strIndex = 0;
                }
            }
            require(strIndex >= topicToAddrLength[topic]);
            if (strIndex < topicToAddrLength[topic] - 1) {
                uint temp = strIndex + 1;
                typeToTopicsValue[businessType][strIndex] = typeToTopicsValue[businessType][temp];
            }
            topicToAddrLength[topic] = topicToAddrLength[topic] - 1;
        }
    }
    function publishWithBytes(uint businessType, uint topic, uint responseData) public returns (bool) {
        uint callbackAddr = businessTypeToAddr[businessType];
        bool success = true;
        return success;
    }
    function hasStrExisted(uint businessType, uint element) public returns (bool) {
        uint i = 0;
        bool result = false;
        if (i < typeToTopicsLength[businessType]) {
            if (typeToTopicsValue[businessType][i] == element) {
                result = true;
            }
        }
        return result;
    }
    function getAddrIndex(uint topic, uint addr) public returns (uint) {
        uint i = 0;
        uint addr_index = 10086;
        if (i < topicToAddrLength[topic]) {
            if (topicToAddrValue[topic][i] == addr) {
                addr_index = i;
            }
        }
        return addr_index;
    }
    function getStrIndex(uint businessType, uint str) public returns (uint) {
        uint i = 0;
        uint addr_index = 10086;
        if (i < typeToTopicsLength[businessType]) {
            if (typeToTopicsValue[businessType][i] == str) {
                addr_index = i;
            }
        }
        return addr_index;
    }
    function removeFromAddrArray(uint topic, uint index) public {
        require(index >= topicToAddrLength[topic]);
        uint i = 0;
        if (i < topicToAddrLength[topic] - 1) {
            uint temp = i + 1;
            topicToAddrValue[topic][i] = temp;
        }
        topicToAddrLength[topic] = topicToAddrLength[topic] - 1;
    }
    function removeFromStrArray(uint businessType, uint index) public {
        if (index < typeToTopicsLength[businessType]) {
            uint i = 0;
            if (i < typeToTopicsLength[businessType] - 1) {
                uint temp = i + 1;
                typeToTopicsValue[businessType][i] = typeToTopicsValue[businessType][temp];
            }
            typeToTopicsLength[businessType] = typeToTopicsLength[businessType] - 1;
        }
    }
    function getAddressOfType(uint businessType) public returns (uint) {
        return businessTypeToAddr[businessType];
    }
    function getTopics(uint businessType, uint index) public returns (uint) {
        return typeToTopicsValue[businessType][index];
    }
    function getAddressesOfTopic(uint topic, uint index) public returns (uint) {
        return topicToAddrValue[topic][index];
    }
    function setBusinessTypeAddr(uint businessType, uint busiContractAddr) public {
        businessTypeToAddr[businessType] = busiContractAddr;
    }
    function randomCallback(uint _reqId, uint _statusCode, uint responseData) public {
        randomNumbers = responseData;
    }
    function getRandomResult() public returns (uint) {
        return randomNumbers;
    }

    // CloakService Variable
    address owner = msg.sender;
    uint constant teeCHash = 0x5a56414ecf36d43b08cb19e5048a9bd8112e021b0c832a867ab9ae0ec9fffcf8;
    uint constant teePHash = 0x29deca019190c0ee26c18a5d87c6b826ce0e1089e92419c67f745683701cc405;
    function get_states(bytes[] memory read, uint return_len) public view returns (bytes[] memory) {
        bytes[] memory oldStates = new bytes[](return_len);
        oldStates[0] = abi.encode(0);
        oldStates[1] = abi.encode(publishWithBytesFunc);
        oldStates[2] = abi.encode(1);
        oldStates[3] = abi.encode(reqId);
        oldStates[4] = abi.encode(2);
        oldStates[5] = abi.encode(randomNumbers);
        oldStates[6] = abi.encode(3);
        oldStates[7] = abi.encode(block_number);
        oldStates[8] = abi.encode(4);
        oldStates[9] = abi.encode(party0);
        oldStates[10] = abi.encode(5);
        oldStates[11] = abi.encode(party1);
        oldStates[12] = abi.encode(6);
        oldStates[13] = abi.encode(party2);
        oldStates[14] = abi.encode(7);
        oldStates[15] = abi.encode(party3);
        oldStates[16] = abi.encode(8);
        oldStates[17] = abi.encode(party4);
        oldStates[18] = abi.encode(9);
        oldStates[19] = abi.encode(party5);
        oldStates[20] = abi.encode(10);
        oldStates[21] = abi.encode(party6);
        oldStates[22] = abi.encode(11);
        oldStates[23] = abi.encode(party7);
        oldStates[24] = abi.encode(12);
        oldStates[25] = abi.encode(party8);
        oldStates[26] = abi.encode(13);
        oldStates[27] = abi.encode(party9);
        uint read_idx = 0;
        uint os_idx = 28;
        uint keys_count = 0;
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(businessTypeToAddr[abi.decode(read[read_idx + 2 + i], (uint))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 3] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 3] = read[read_idx + 3 + i];
            oldStates[os_idx + 4 + i * 3] = abi.encode(typeToTopicsValue[abi.decode(read[read_idx + 2 + i], (uint))][abi.decode(read[read_idx + 3 + i], (uint))]);
        }
        os_idx = os_idx + 2 + keys_count * 3;
        read_idx = read_idx + 2 + keys_count * 2; //
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(typeToTopicsLength[abi.decode(read[read_idx + 2 + i], (uint))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 3] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 3] = read[read_idx + 3 + i];
            oldStates[os_idx + 4 + i * 3] = abi.encode(topicToAddrValue[abi.decode(read[read_idx + 2 + i], (uint))][abi.decode(read[read_idx + 3 + i], (uint))]);
        }
        os_idx = os_idx + 2 + keys_count * 3;
        read_idx = read_idx + 2 + keys_count * 2; //
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(topicToAddrLength[abi.decode(read[read_idx + 2 + i], (uint))]);
        }
        return oldStates;
    }
    function set_states(bytes[] memory read, uint old_states_len, bytes[] memory data, uint[] memory proof) public {
        require(msg.sender == owner, 'msg.sender is not tee');
        require(proof[0] == teeCHash, 'code hash error');
        require(proof[1] == teePHash, 'policy hash error');
        uint256 osHash = uint256(keccak256(abi.encode(get_states(read, old_states_len))));
        require(proof[2] == osHash, 'old states hash error');
        publishWithBytesFunc = abi.decode(data[1], (uint));
        reqId = abi.decode(data[3], (uint));
        randomNumbers = abi.decode(data[5], (uint));
        block_number = abi.decode(data[7], (uint));
        party0 = abi.decode(data[9], (address));
        party1 = abi.decode(data[11], (address));
        party2 = abi.decode(data[13], (address));
        party3 = abi.decode(data[15], (address));
        party4 = abi.decode(data[17], (address));
        party5 = abi.decode(data[19], (address));
        party6 = abi.decode(data[21], (address));
        party7 = abi.decode(data[23], (address));
        party8 = abi.decode(data[25], (address));
        party9 = abi.decode(data[27], (address));
        uint data_idx = 28;
        uint keys_count = 0;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            businessTypeToAddr[abi.decode(data[data_idx + 2 + i * 2], (uint))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            typeToTopicsValue[abi.decode(data[data_idx + 2 + i * 3], (uint))][abi.decode(data[data_idx + 3 + i * 3], (uint))] = abi.decode(data[data_idx + 4 + i * 3], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 3;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            typeToTopicsLength[abi.decode(data[data_idx + 2 + i * 2], (uint))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            topicToAddrValue[abi.decode(data[data_idx + 2 + i * 3], (uint))][abi.decode(data[data_idx + 3 + i * 3], (uint))] = abi.decode(data[data_idx + 4 + i * 3], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 3;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            topicToAddrLength[abi.decode(data[data_idx + 2 + i * 2], (uint))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
    }
}