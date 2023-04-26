

pragma solidity ^0.8.0;

contract ERC20Token {


    uint public supply = 0;
    mapping(address => bytes[5]) public balances;
    mapping(address => mapping(address => uint)) public allowances;
    mapping(address => mapping(address => bytes[5])) public pending;
    mapping(address => bool) public has_pending;
    mapping(address => bool) public registered;
    constructor(uint s) public {
        supply = s;
        registered[msg.sender] = true;
        has_pending[msg.sender] = false;
    }
    function allowance(address _owner, address _spender) public returns (uint) {
        return allowances[_owner][_spender];
    }
    function register() public {
        registered[msg.sender] = true;
        has_pending[msg.sender] = false;
    }
    function totalSupply() public returns (uint) {
        return supply;
    }

    // CloakService Variable
    address owner = msg.sender;
    uint constant teeCHash = 0x6b70e2365f4994ad61fe89b06fb26f9382ad8c53e038c16a9b9e5b04b30c6787;
    uint constant teePHash = 0x7b40976142f9ab89eb610251e0d568e66a8627c52d04eece11ae178fe1bfb325;
    function get_states(bytes[] memory read, uint return_len) public view returns (bytes[] memory) {
        bytes[] memory oldStates = new bytes[](return_len);
        oldStates[0] = abi.encode(0);
        oldStates[1] = abi.encode(supply);
        uint read_idx = 0;
        uint os_idx = 2;
        uint keys_count = 0;
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[1]=2 ; read[1]=2 ; read[1]=0
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 4] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][0];
            oldStates[os_idx + 4 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][1];
            oldStates[os_idx + 5 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][2];
            oldStates[os_idx + 6 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][3];
            oldStates[os_idx + 7 + i * 4] = balances[abi.decode(read[read_idx + 2 + i], (address))][4];
        }
        os_idx = os_idx + 2 + keys_count * 6;
        read_idx = read_idx + 2 + keys_count * 1; //4 ; 4 ; 2
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[5]=0 ; read[5]=1 ; read[3]=1
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 3] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 3] = read[read_idx + 3 + i];
            oldStates[os_idx + 4 + i * 3] = abi.encode(allowances[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 3;
        read_idx = read_idx + 2 + keys_count * 2; //6 ;
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[7]=0 ;
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 5] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 5] = read[read_idx + 3 + i];
            oldStates[os_idx + 4 + i * 5] = pending[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][0];
            oldStates[os_idx + 5 + i * 5] = pending[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][1];
            oldStates[os_idx + 6 + i * 5] = pending[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][2];
            oldStates[os_idx + 7 + i * 5] = pending[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][3];
            oldStates[os_idx + 8 + i * 5] = pending[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))][4];
        }
        os_idx = os_idx + 2 + keys_count * 7;
        read_idx = read_idx + 2 + keys_count * 2; //8
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[9]=0
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(has_pending[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //10
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[11]=0
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(registered[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        return oldStates;
    }
    function set_states(bytes[] memory read, uint old_states_len, bytes[] memory data, uint[] memory proof) public {
        require(msg.sender == owner, 'msg.sender is not tee');
        require(proof[0] == teeCHash, 'code hash error');
        require(proof[1] == teePHash, 'policy hash error');
        uint256 osHash = uint256(keccak256(abi.encode(get_states(read, old_states_len))));
        require(proof[2] == osHash, 'old states hash error');
        supply = abi.decode(data[1], (uint));
        uint data_idx = 2;
        uint keys_count = 0;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            balances[abi.decode(data[data_idx + 2 + i * 4], (address))][0] = data[data_idx + 3 + i * 4];
            balances[abi.decode(data[data_idx + 2 + i * 4], (address))][1] = data[data_idx + 4 + i * 4];
            balances[abi.decode(data[data_idx + 2 + i * 4], (address))][2] = data[data_idx + 5 + i * 4];
        }
        data_idx = data_idx + 2 + keys_count * 4;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            allowances[abi.decode(data[data_idx + 2 + i * 3], (address))][abi.decode(data[data_idx + 3 + i * 3], (address))] = abi.decode(data[data_idx + 4 + i * 3], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 3;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            pending[abi.decode(data[data_idx + 2 + i * 5], (address))][abi.decode(data[data_idx + 3 + i * 5], (address))][0] = data[data_idx + 4 + i * 5];
            pending[abi.decode(data[data_idx + 2 + i * 5], (address))][abi.decode(data[data_idx + 3 + i * 5], (address))][1] = data[data_idx + 5 + i * 5];
            pending[abi.decode(data[data_idx + 2 + i * 5], (address))][abi.decode(data[data_idx + 3 + i * 5], (address))][2] = data[data_idx + 6 + i * 5];
        }
        data_idx = data_idx + 2 + keys_count * 5;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            has_pending[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (bool));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            registered[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (bool));
        }
    }
}