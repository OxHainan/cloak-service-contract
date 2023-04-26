

pragma solidity ^0.8.0;

contract SupplyChain {


    address public business;
    mapping(uint => bytes[5]) public in_receipts;
    mapping(uint => bytes[5]) public out_receipts;
    bytes[5] public income;
    mapping(address => bytes[5]) public balances;
    mapping(address => mapping(address => bytes[5])) public receivables;
    constructor() public {
        business = msg.sender;
    }

    // CloakService Variable
    address owner = msg.sender;
    uint constant teeCHash = 0xba45dffcdaf7084c6c8ebdc9f92201454cdd2ddb98b8e14dafdaa1ed652d9e3c;
    uint constant teePHash = 0xe12d0dd644f48678e9a3c5c76e9e61044c96a193122ded514bbe6ce64b0abcf4;

    function get_states(bytes[] memory read, uint return_len) public view returns (bytes[] memory) {
        bytes[] memory oldStates = new bytes[](return_len);
        oldStates[0] = abi.encode(0);
        oldStates[1] = abi.encode(business);
        oldStates[2] = abi.encode(1);
        oldStates[3] = income[0];
        oldStates[4] = income[1];
        oldStates[5] = income[2];
        oldStates[5] = income[3];
        oldStates[5] = income[4];
        uint read_idx = 0;
        uint os_idx = 8;
        uint keys_count = 0;
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[1]=0
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 4] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 4] = in_receipts[abi.decode(read[read_idx + 2 + i], (uint))][0];
            oldStates[os_idx + 4 + i * 4] = in_receipts[abi.decode(read[read_idx + 2 + i], (uint))][1];
            oldStates[os_idx + 5 + i * 4] = in_receipts[abi.decode(read[read_idx + 2 + i], (uint))][2];
            oldStates[os_idx + 6 + i * 4] = in_receipts[abi.decode(read[read_idx + 2 + i], (uint))][3];
            oldStates[os_idx + 7 + i * 4] = in_receipts[abi.decode(read[read_idx + 2 + i], (uint))][4];
        }
        os_idx = os_idx + 2 + keys_count * 6;
        read_idx = read_idx + 2 + keys_count * 1; //2
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[3]=0
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 4] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 4] = out_receipts[abi.decode(read[read_idx + 2 + i], (uint))][0];
            oldStates[os_idx + 4 + i * 4] = out_receipts[abi.decode(read[read_idx + 2 + i], (uint))][1];
            oldStates[os_idx + 5 + i * 4] = out_receipts[abi.decode(read[read_idx + 2 + i], (uint))][2];
            oldStates[os_idx + 6 + i * 4] = out_receipts[abi.decode(read[read_idx + 2 + i], (uint))][3];
            oldStates[os_idx + 7 + i * 4] = out_receipts[abi.decode(read[read_idx + 2 + i], (uint))][4];
        }
        os_idx = os_idx + 2 + keys_count * 6;
        read_idx = read_idx + 2 + keys_count * 1; //4
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[5]=1
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 4] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][0];
            oldStates[os_idx + 4 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][1];
            oldStates[os_idx + 5 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][2];
            oldStates[os_idx + 6 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][3];
            oldStates[os_idx + 7 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][4];
        }
        os_idx = os_idx + 2 + keys_count * 6;
        read_idx = read_idx + 2 + keys_count * 1; //7
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[8]=1
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 5] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 5] = read[read_idx + 3 + i];
            oldStates[os_idx + 4 + i * 5] = receivables[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][0];
            oldStates[os_idx + 5 + i * 5] = receivables[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][1];
            oldStates[os_idx + 6 + i * 5] = receivables[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][2];
            oldStates[os_idx + 7 + i * 5] = receivables[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][3];
            oldStates[os_idx + 8 + i * 5] = receivables[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][4];
        }
        return oldStates;
    }
    function set_states(bytes[] memory read, uint old_states_len, bytes[] memory data, uint[] memory proof) public {
        require(msg.sender == owner, 'msg.sender is not tee');
        require(proof[0] == teeCHash, 'code hash error');
        require(proof[1] == teePHash, 'policy hash error');
        uint256 osHash = uint256(keccak256(abi.encode(get_states(read, old_states_len))));
        require(proof[2] == osHash, 'old states hash error');
        business = abi.decode(data[1], (address));
        income[0] = data[3];
        income[1] = data[4];
        income[2] = data[5];
        uint data_idx = 6;
        uint keys_count = 0;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            in_receipts[abi.decode(data[data_idx + 2 + i * 4], (uint))][0] = data[data_idx + 3 + i * 4];
            in_receipts[abi.decode(data[data_idx + 2 + i * 4], (uint))][1] = data[data_idx + 4 + i * 4];
            in_receipts[abi.decode(data[data_idx + 2 + i * 4], (uint))][2] = data[data_idx + 5 + i * 4];
        }
        data_idx = data_idx + 2 + keys_count * 4;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            out_receipts[abi.decode(data[data_idx + 2 + i * 4], (uint))][0] = data[data_idx + 3 + i * 4];
            out_receipts[abi.decode(data[data_idx + 2 + i * 4], (uint))][1] = data[data_idx + 4 + i * 4];
            out_receipts[abi.decode(data[data_idx + 2 + i * 4], (uint))][2] = data[data_idx + 5 + i * 4];
        }
        data_idx = data_idx + 2 + keys_count * 4;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            balances[abi.decode(data[data_idx + 2 + i * 4], (address))][0] = data[data_idx + 3 + i * 4];
            balances[abi.decode(data[data_idx + 2 + i * 4], (address))][1] = data[data_idx + 4 + i * 4];
            balances[abi.decode(data[data_idx + 2 + i * 4], (address))][2] = data[data_idx + 5 + i * 4];
        }
        data_idx = data_idx + 2 + keys_count * 4;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            receivables[abi.decode(data[data_idx + 2 + i * 5], (address))][abi.decode(data[data_idx + 3 + i * 5], (address))][0] = data[data_idx + 4 + i * 5];
            receivables[abi.decode(data[data_idx + 2 + i * 5], (address))][abi.decode(data[data_idx + 3 + i * 5], (address))][1] = data[data_idx + 5 + i * 5];
            receivables[abi.decode(data[data_idx + 2 + i * 5], (address))][abi.decode(data[data_idx + 3 + i * 5], (address))][2] = data[data_idx + 6 + i * 5];
        }
    }
}