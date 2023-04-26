

pragma solidity ^0.8.0;

contract Scores {


    address public _examinator;
    uint public _passPoints;
    bytes[5] public _avgScore;
    bytes[5] public _totalPoints;
    bytes[5] public _totalExaminees;
    mapping(uint => bytes[5]) public solutions;
    mapping(address => mapping(uint => bytes[5])) public answers;
    mapping(address => bytes[5]) public points;
    mapping(address => bytes[5]) public passed;
    constructor(uint pass, uint point) public {
        _examinator = msg.sender;
        _passPoints = pass;
    }

    // CloakService Variable
    address owner = msg.sender;
    uint constant teeCHash = 0x843840c89da7573a4cb8bf1ff08c652181b7ddb51e9b39f5ed0434b7d3fe7166;
    uint constant teePHash = 0x7a5d26934a2858048e82bf5295b2f67c1055d01b863991795ac7e900e8ee5c59;
    function get_states(bytes[] memory read, uint return_len) public view returns (bytes[] memory) {
        bytes[] memory oldStates = new bytes[](return_len);
        oldStates[0] = abi.encode(0);
        oldStates[1] = abi.encode(_examinator);
        oldStates[2] = abi.encode(1);
        oldStates[3] = abi.encode(_passPoints);
        oldStates[4] = abi.encode(2);
        oldStates[5] = _avgScore[0];
        oldStates[6] = _avgScore[1];
        oldStates[7] = _avgScore[2];
        oldStates[8] = abi.encode(3);
        oldStates[9] = _totalPoints[0];
        oldStates[10] = _totalPoints[1];
        oldStates[11] = _totalPoints[2];
        oldStates[12] = abi.encode(4);
        oldStates[13] = _totalExaminees[0];
        oldStates[14] = _totalExaminees[1];
        oldStates[15] = _totalExaminees[2];
        uint read_idx = 0;
        uint os_idx = 16;
        uint keys_count = 0;
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[1]=1
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 4] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 4] = solutions[abi.decode(read[read_idx + 2 + i], (uint))][0];
            oldStates[os_idx + 4 + i * 4] = solutions[abi.decode(read[read_idx + 2 + i], (uint))][1];
            oldStates[os_idx + 5 + i * 4] = solutions[abi.decode(read[read_idx + 2 + i], (uint))][2];
            oldStates[os_idx + 6 + i * 4] = solutions[abi.decode(read[read_idx + 2 + i], (uint))][3];
            oldStates[os_idx + 7 + i * 4] = solutions[abi.decode(read[read_idx + 2 + i], (uint))][4];
        }
        os_idx = os_idx + 2 + keys_count * 6;
        read_idx = read_idx + 2 + keys_count * 1; //3
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[4]=1
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 5] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 5] = read[read_idx + 3 + i];
            oldStates[os_idx + 4 + i * 5] = answers[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (uint))][0];
            oldStates[os_idx + 5 + i * 5] = answers[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (uint))][1];
            oldStates[os_idx + 6 + i * 5] = answers[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (uint))][2];
            oldStates[os_idx + 7 + i * 5] = answers[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (uint))][3];
            oldStates[os_idx + 8 + i * 5] = answers[abi.decode(read[read_idx + 2 + i], (address))][abi.decode(read[read_idx + 3 + i], (uint))][4];
        }
        os_idx = os_idx + 2 + keys_count * 7;
        read_idx = read_idx + 2 + keys_count * 2; //7
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[8]=1
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 4] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 4] = points[abi.decode(read[read_idx + 2 + i], (address))][0];
            oldStates[os_idx + 4 + i * 4] = points[abi.decode(read[read_idx + 2 + i], (address))][1];
            oldStates[os_idx + 5 + i * 4] = points[abi.decode(read[read_idx + 2 + i], (address))][2];
            oldStates[os_idx + 6 + i * 4] = points[abi.decode(read[read_idx + 2 + i], (address))][3];
            oldStates[os_idx + 7 + i * 4] = points[abi.decode(read[read_idx + 2 + i], (address))][4];
        }
        os_idx = os_idx + 2 + keys_count * 6;
        read_idx = read_idx + 2 + keys_count * 1; //15
        oldStates[os_idx] = read[read_idx];
        oldStates[os_idx + 1] = read[read_idx + 1];
        keys_count = abi.decode(read[read_idx + 1], (uint)); //read[16]
        for (uint i = 0; i < keys_count; i = i + 1) {
            oldStates[os_idx + 2 + i * 4] = read[read_idx + 2 + i];
            oldStates[os_idx + 3 + i * 4] = passed[abi.decode(read[read_idx + 2 + i], (address))][0];
            oldStates[os_idx + 4 + i * 4] = passed[abi.decode(read[read_idx + 2 + i], (address))][1];
            oldStates[os_idx + 5 + i * 4] = passed[abi.decode(read[read_idx + 2 + i], (address))][2];
            oldStates[os_idx + 6 + i * 4] = passed[abi.decode(read[read_idx + 2 + i], (address))][3];
            oldStates[os_idx + 7 + i * 4] = passed[abi.decode(read[read_idx + 2 + i], (address))][4];
        }
        return oldStates;
    }
    function set_states(bytes[] memory read, uint old_states_len, bytes[] memory data, uint[] memory proof) public {
        require(msg.sender == owner, 'msg.sender is not tee');
        require(proof[0] == teeCHash, 'code hash error');
        require(proof[1] == teePHash, 'policy hash error');
        uint256 osHash = uint256(keccak256(abi.encode(get_states(read, old_states_len))));
        require(proof[2] == osHash, 'old states hash error');
        _examinator = abi.decode(data[1], (address));
        _passPoints = abi.decode(data[3], (uint));
        _avgScore[0] = data[5];
        _avgScore[1] = data[6];
        _avgScore[2] = data[7];
        _totalPoints[0] = data[9];
        _totalPoints[1] = data[10];
        _totalPoints[2] = data[11];
        _totalExaminees[0] = data[13];
        _totalExaminees[1] = data[14];
        _totalExaminees[2] = data[15];
        uint data_idx = 16;
        uint keys_count = 0;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            solutions[abi.decode(data[data_idx + 2 + i * 4], (uint))][0] = data[data_idx + 3 + i * 4];
            solutions[abi.decode(data[data_idx + 2 + i * 4], (uint))][1] = data[data_idx + 4 + i * 4];
            solutions[abi.decode(data[data_idx + 2 + i * 4], (uint))][2] = data[data_idx + 5 + i * 4];
        }
        data_idx = data_idx + 2 + keys_count * 4;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            answers[abi.decode(data[data_idx + 2 + i * 5], (address))][abi.decode(data[data_idx + 3 + i * 5], (uint))][0] = data[data_idx + 4 + i * 5];
            answers[abi.decode(data[data_idx + 2 + i * 5], (address))][abi.decode(data[data_idx + 3 + i * 5], (uint))][1] = data[data_idx + 5 + i * 5];
            answers[abi.decode(data[data_idx + 2 + i * 5], (address))][abi.decode(data[data_idx + 3 + i * 5], (uint))][2] = data[data_idx + 6 + i * 5];
        }
        data_idx = data_idx + 2 + keys_count * 5;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            points[abi.decode(data[data_idx + 2 + i * 4], (address))][0] = data[data_idx + 3 + i * 4];
            points[abi.decode(data[data_idx + 2 + i * 4], (address))][1] = data[data_idx + 4 + i * 4];
            points[abi.decode(data[data_idx + 2 + i * 4], (address))][2] = data[data_idx + 5 + i * 4];
        }
        data_idx = data_idx + 2 + keys_count * 4;
        keys_count = abi.decode(data[data_idx + 1], (uint));
        for (uint i = 0; i < keys_count; i = i + 1) {
            passed[abi.decode(data[data_idx + 2 + i * 4], (address))][0] = data[data_idx + 3 + i * 4];
            passed[abi.decode(data[data_idx + 2 + i * 4], (address))][1] = data[data_idx + 4 + i * 4];
            passed[abi.decode(data[data_idx + 2 + i * 4], (address))][2] = data[data_idx + 5 + i * 4];
        }
    }
}