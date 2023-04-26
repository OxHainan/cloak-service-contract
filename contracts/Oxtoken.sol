

pragma solidity ^0.8.0;

contract OXToken {


    uint public seq = 0;
    uint public MintRequestLength = 0;
    mapping(address => uint) public MintRequestAmounts;
    mapping(address => uint) public MintRequestReceipts;
    mapping(address => uint) public mintMap;
    uint public BurnRequestLength = 0;
    mapping(address => uint) public BurnRequestAmounts;
    mapping(address => uint) public BurnRequestReceipts;
    mapping(address => uint) public burnMap;
    uint public name = 110;
    uint public symbol = 119;
    uint public decimals = 18;
    address public bankerAddress;
    address public _owner;
    address public burner;
    address public party0;
    address public party1;
    address public party2;
    address public party3;
    address public party4;
    mapping(address => bool) public minters;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;
    uint public totalSupply;
    mapping(address => bool) public voters;
    constructor(address _banker, address _burner, address _party0, address _party1, address _party2, address _party3, address _party4, uint _name, uint _symbol, uint _decimals) public {
        bankerAddress = _banker;
        burner = _burner;
        _owner = msg.sender;
        party0 = _party0;
        party1 = _party1;
        party2 = _party2;
        party3 = _party3;
        party4 = _party4;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        voters[_owner] = false;
        voters[bankerAddress] = false;
        voters[burner] = false;
    }
    function onlyBurner() public {
        require(msg.sender == burner);
    }
    function getBankerAddress() public returns (address) {
        return bankerAddress;
    }
    function isBurner() public returns (bool) {
        return msg.sender == burner;
    }
    function setBurner(address _burner) public {
        require(_owner == msg.sender);
        require(balances[burner] == 0);
        burner = _burner;
    }
    function getBurner() public returns (address) {
        return burner;
    }
    function mintRequest(uint _amount) public returns (address) {
        require(_owner == msg.sender);
        require(_amount > 0);
        seq = seq + 1;
        uint random = seq;
        random = random + 55;
        random = random + seq;
        address id = _owner;
        MintRequestLength = MintRequestLength + 1;
        MintRequestAmounts[id] = _amount;
        MintRequestReceipts[id] = 55;
        mintMap[id] = MintRequestLength - 1;
    }
    function burnRequest(uint _amount) public returns (address) {
        require(msg.sender == burner);
        require(_amount > 0);
        require(balances[burner] >= _amount);
        seq = seq + 1;
        uint random = 10000000 + seq;
        random = random + 55;
        random = random + seq;
        address id = _owner;
        BurnRequestLength = BurnRequestLength + 1;
        BurnRequestAmounts[id] = _amount;
        BurnRequestReceipts[id] = 55;
        burnMap[id] = BurnRequestLength - 1;
        return id;
    }
    function transfer(address _to, uint _value) public returns (bool) {
        require(_to != _owner);
        require(msg.sender != burner);
        if (msg.sender == _owner) {
            require(_to != burner);
        }
        require(balances[msg.sender] >= _value);
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - _value;
        uint add_c1 = balances[_to] + _value;
        require(add_c1 >= balances[_to]);
        balances[_to] = add_c1;
        return true;
    }
    function doMint(uint _value) public returns (bool) {
        require(msg.sender == bankerAddress);
        bool isMinter = minters[msg.sender];
        require(isMinter);
        require(_value <= totalSupply);
        totalSupply = totalSupply - _value;
        uint add_c1 = balances[_owner] + _value;
        require(add_c1 >= balances[_owner]);
        balances[_owner] = add_c1;
        return true;
    }
    function doBurn(uint _value) public returns (bool) {
        require(msg.sender == bankerAddress);
        require(_value <= totalSupply);
        totalSupply = totalSupply - _value;
        require(_value <= balances[burner]);
        balances[burner] = balances[burner] - _value;
        return true;
    }

    // CloakService Variable
    address owner = msg.sender;
    uint constant teeCHash = 0x7d545e6bf1ea4df93b7530ef4d5bb3332d5fbf50b489b810703bbc488367286a;
    uint constant teePHash = 0xcc10efcc369b50239bb458c408062e186e8d788bb9eff6674d15aed16189efc3;
    function get_states(bytes[] memory read, uint return_len) public view returns (bytes[] memory) {
        bytes[] memory oldStates = new bytes[](return_len);
        oldStates[0] = abi.encode(0);
        oldStates[1] = abi.encode(seq);
        oldStates[2] = abi.encode(1);
        oldStates[3] = abi.encode(MintRequestLength);
        oldStates[4] = abi.encode(2);
        oldStates[5] = abi.encode(BurnRequestLength);
        oldStates[6] = abi.encode(3);
        oldStates[7] = abi.encode(name);
        oldStates[8] = abi.encode(4);
        oldStates[9] = abi.encode(symbol);
        oldStates[10] = abi.encode(5);
        oldStates[11] = abi.encode(decimals);
        oldStates[12] = abi.encode(6);
        oldStates[13] = abi.encode(bankerAddress);
        oldStates[14] = abi.encode(7);
        oldStates[15] = abi.encode(_owner);
        oldStates[16] = abi.encode(8);
        oldStates[17] = abi.encode(burner);
        oldStates[18] = abi.encode(9);
        oldStates[19] = abi.encode(party0);
        oldStates[20] = abi.encode(10);
        oldStates[21] = abi.encode(party1);
        oldStates[22] = abi.encode(11);
        oldStates[23] = abi.encode(party2);
        oldStates[24] = abi.encode(12);
        oldStates[25] = abi.encode(party3);
        oldStates[26] = abi.encode(13);
        oldStates[27] = abi.encode(party4);
        oldStates[28] = abi.encode(14);
        oldStates[29] = abi.encode(totalSupply);
        uint read_idx = 0;
        uint os_idx = 30;
        uint keys_count = 0;
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[1]=0 ; 
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(MintRequestAmounts[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //2
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[3]=0 ; 
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(MintRequestReceipts[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //4
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read; 
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(mintMap[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //6
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read;
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(BurnRequestAmounts[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //8
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read;
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(BurnRequestReceipts[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //10
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read;
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(burnMap[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //12
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read;
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(minters[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //14 ; 14 ;
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[15]=2; read[15]=0
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(balances[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 2;
        read_idx = read_idx + 2 + keys_count * 1; //18 ; 16
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[19]=1;  read[17]=1
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 3] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 3] = read[read_idx + 3 + i];
            oldStates[os_idx + 4 + i * 3] = abi.encode(allowed[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (address))]);
        }
        os_idx = os_idx + 2 + keys_count * 3;
        read_idx = read_idx + 2 + keys_count * 2; //
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 2] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 2] = abi.encode(voters[abi.decode(read[read_idx + 2 + i], (address))]);
        }
        return oldStates;
    }
    function set_states(bytes[] memory read, uint old_states_len, bytes[] memory data, uint[] memory proof) public {
        require(msg.sender == owner, 'msg.sender is not tee');
        require(proof[0] == teeCHash, 'code hash error');
        require(proof[1] == teePHash, 'policy hash error');
        uint256 osHash = uint256(keccak256(abi.encode(get_states(read, old_states_len))));
        require(proof[2] == osHash, 'old states hash error');
        seq = abi.decode(data[1], (uint));
        MintRequestLength = abi.decode(data[3], (uint));
        BurnRequestLength = abi.decode(data[5], (uint));
        name = abi.decode(data[7], (uint));
        symbol = abi.decode(data[9], (uint));
        decimals = abi.decode(data[11], (uint));
        bankerAddress = abi.decode(data[13], (address));
        _owner = abi.decode(data[15], (address));
        burner = abi.decode(data[17], (address));
        party0 = abi.decode(data[19], (address));
        party1 = abi.decode(data[21], (address));
        party2 = abi.decode(data[23], (address));
        party3 = abi.decode(data[25], (address));
        party4 = abi.decode(data[27], (address));
        totalSupply = abi.decode(data[29], (uint));
        uint data_idx = 30;
        uint keys_count = 0;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            MintRequestAmounts[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            MintRequestReceipts[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            mintMap[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            BurnRequestAmounts[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            BurnRequestReceipts[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            burnMap[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            minters[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (bool));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            balances[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 2;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            allowed[abi.decode(data[data_idx + 2 + i * 3], (address))][abi.decode(data[data_idx + 3 + i * 3], (address))] = abi.decode(data[data_idx + 4 + i * 3], (uint));
        }
        data_idx = data_idx + 2 + keys_count * 3;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            voters[abi.decode(data[data_idx + 2 + i * 2], (address))] = abi.decode(data[data_idx + 3 + i * 2], (bool));
        }
    }
}