// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.7;
import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./Deposit.sol";

contract CloakService is Deposit {
    using SafeMath for uint256;
    using Address for address;
    enum TxStatus {
        PROPOSED,
        NEGOFAILED,
        ABORTED,
        COMPLETED
    }

    struct Proposal {
        bool isValid;
        TxStatus status;
        address verifiedContractAddr;
        uint256 deposit;
        address teeAddr;
        uint256 maxBlockNumber4Negotiation;
        uint256 maxBlockNumber4Compete;
    }

    address[] public teeAddrList;
    mapping(address => bytes) public pks;
    mapping(address => bool) hasAnnounced;
    address public manager;
    mapping(uint256 => Proposal) public prpls;
    uint256 maxBlockNumber4Compete;

    constructor(address _manager, bytes memory pk) {
        manager = _manager;
        teeAddrList[0] = msg.sender;
        maxBlockNumber4Compete = 3;
        announcePk(pk);
    }

    modifier checkPublicKey(bytes memory pk) {
        require(pk.length == 65, "Invalid public key length");
        require(pk[0] == 0x04, "Unkown public key format");
        _;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Invalid manager");
        _;
    }

    function setTEEAddress(
        address teeAddr,
        bytes memory pk
    ) public onlyManager {
        teeAddrList[0] = teeAddr;
        announcePk(pk);
    }

    modifier existTx(uint256 txId) {
        require(prpls[txId].isValid, "Require existed transcation");
        _;
    }

    modifier notExistTx(uint256 txId) {
        require(!prpls[txId].isValid, "Transcation existed");
        _;
    }

    modifier checkTxStatus(uint256 txId, TxStatus status) {
        require(prpls[txId].status == status, "Transaction status invalid");
        _;
    }

    function announcePk(bytes memory pk) public checkPublicKey(pk) {
        require(!hasAnnounced[msg.sender], "Address has already announced");
        pks[msg.sender] = pk;
        hasAnnounced[msg.sender] = true;
    }

    function getPk(
        address[] memory addrs
    ) public view returns (bytes[] memory) {
        bytes[] memory res = new bytes[](addrs.length);
        for (uint i = 0; i < addrs.length; i++) {
            require(hasAnnounced[addrs[i]], "Address has no announced");
            res[i] = pks[addrs[i]];
        }
        return res;
    }

    event Deploy(address indexed addr);
    function deploy(bytes memory bytecode) public {
        bytes32 salt = keccak256(abi.encodePacked(address(this), msg.sender));
        address addr = Create2.deploy(0, salt, bytecode);
        emit Deploy(addr);
    }

    function challengeTEE(
        uint256 txId, 
        uint256 deposit,
        uint256 maxBlockNumber4Negotiation
    ) external notExistTx(txId) {
        require(
            block.number <= maxBlockNumber4Negotiation,
            "Require enough block number"
        );
        Proposal storage prpl = prpls[txId];
        prpl.deposit = deposit;
        prpl.maxBlockNumber4Negotiation = maxBlockNumber4Negotiation;
        prpl.maxBlockNumber4Compete = maxBlockNumber4Compete;
        prpl.teeAddr = teeAddrList[0];
        prpl.status = TxStatus.PROPOSED;
    }

    event Acknowledge(uint256 txId, bytes ack, address party);
    function acknowledge(uint256 txId, bytes memory ack) external {
        emit Acknowledge(txId, ack, msg.sender);
    }

    function failNegotiation(uint256 txId) external {
        Proposal storage prpl = prpls[txId];
        require(msg.sender == prpl.teeAddr, "Require tee caller");
        prpl.status = TxStatus.NEGOFAILED;
    }

    event ChallengeParties(uint256 txId, address[] misbehavedPartyAddrs);
    function challengeParties(
        uint256 txId,
        address[] memory misbehavedPartyAddrs
    ) external {
        require(msg.sender == prpls[txId].teeAddr, "Require tee caller");
        emit ChallengeParties(txId, misbehavedPartyAddrs);
    }

    event PartyResponse(uint256 txId, bytes[] input, bytes[] signature, address party);
    function partyResponse(
        uint256 txId,
        bytes[] memory input,
        bytes[] memory signature
    ) external existTx(txId) {
        emit PartyResponse(txId, input, signature, msg.sender);
    }

    function punishParties(
        uint256 txId,
        address[] memory misbehavedPartyAddrs
    ) external {
        Proposal storage prpl = prpls[txId];
        require(msg.sender == prpl.teeAddr, "Require tee caller");
        deduct(misbehavedPartyAddrs, prpl.deposit);
        prpl.status = TxStatus.ABORTED;
    }

    function punishTEE(uint256 txId) external existTx(txId) {
        Proposal storage prpl = prpls[txId];
        require(
            block.number > prpl.maxBlockNumber4Negotiation.add(prpl.maxBlockNumber4Compete),
            "Require enough block number"
        );
        require(
            prpl.status != TxStatus.NEGOFAILED &&
            prpl.status != TxStatus.ABORTED &&
            prpl.status != TxStatus.COMPLETED 
        );
        deduct(teeAddrList[0], prpl.deposit);
        prpl.status = TxStatus.ABORTED;
    }

    function commit(uint256 txId, bytes memory data) existTx(txId) external {
        Proposal storage prpl = prpls[txId];
        require(msg.sender == prpls[txId].teeAddr, "Require tee caller");
        prpl.verifiedContractAddr.functionCall(data);
    }

    function complete(uint256 txId, bytes memory data) existTx(txId) external {
        Proposal storage prpl = prpls[txId];
        require(msg.sender == prpls[txId].teeAddr, "Require tee caller");
        prpl.verifiedContractAddr.functionCall(data);
        prpl.status = TxStatus.COMPLETED;
    }
}
