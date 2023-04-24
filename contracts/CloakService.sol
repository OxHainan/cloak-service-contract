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
        uint256 maxBlockNumber4Nego;
        uint256 maxBlockNumber4Comp;
    }

    address[] public teeAddrList;
    mapping(address => bytes) public pks;
    mapping(address => bool) hasAnnounced;
    address public manager;
    mapping(uint256 => Proposal) public prpls;
    uint256 maxBlockNumber4Comp;

    constructor(address _manager, bytes memory pk) {
        manager = _manager;
        teeAddrList.push(msg.sender);
        maxBlockNumber4Comp = 3;
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

    modifier onlyTee(uint256 txId) {
        require(msg.sender == prpls[txId].teeAddr, "Require tee caller");
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

    modifier txNotClosed(uint256 txId) {
        Proposal memory prpl = prpls[txId];
        require(
            prpl.status != TxStatus.NEGOFAILED &&
            prpl.status != TxStatus.ABORTED &&
            prpl.status != TxStatus.COMPLETED,
            "Require status not in NEGOFAILED, ABORTED or COMPLETED"
        );
        _;
    }

    function announcePk(bytes memory pk) public checkPublicKey(pk) {
        require(!hasAnnounced[msg.sender], "Address has already announced");
        pks[msg.sender] = pk;
        hasAnnounced[msg.sender] = true;
    }

    function getPk(
        address[] calldata addrs
    ) public view returns (bytes[] memory) {
        bytes[] memory res = new bytes[](addrs.length);
        for (uint i = 0; i < addrs.length; i++) {
            require(hasAnnounced[addrs[i]], "Address has no announced");
            res[i] = pks[addrs[i]];
        }
        return res;
    }

    event Deploy(address indexed addr);
    function deploy(bytes calldata bytecode) public {
        bytes32 salt = keccak256(abi.encodePacked(address(this), msg.sender));
        address addr = Create2.deploy(0, salt, bytecode);
        emit Deploy(addr);
    }

    function challengeTEE(
        uint256 txId, 
        uint256 deposit,
        uint256 maxBlockNumber4Nego,
        address verifiedContractAddr
    ) external notExistTx(txId) {
        require(deposit > 0, "require deposit larger than 0");
        Proposal storage prpl = prpls[txId];
        prpl.isValid = true;
        prpl.deposit = deposit;
        prpl.maxBlockNumber4Nego = maxBlockNumber4Nego;
        prpl.maxBlockNumber4Comp = maxBlockNumber4Comp;
        prpl.teeAddr = teeAddrList[0];
        prpl.verifiedContractAddr = verifiedContractAddr;
        prpl.status = TxStatus.PROPOSED;
    }

    event Acknowledge(uint256 txId, bytes ack, address party);
    function acknowledge(
        uint256 txId,
        bytes calldata ack
    ) external existTx(txId) checkTxStatus(txId, TxStatus.PROPOSED) {
        emit Acknowledge(txId, ack, msg.sender);
    }

    function failNegotiation(
        uint256 txId
    ) external existTx(txId) checkTxStatus(txId, TxStatus.PROPOSED) onlyTee(txId) {
        Proposal storage prpl = prpls[txId];
        prpl.status = TxStatus.NEGOFAILED;
    }

    event ChallengeParties(uint256 txId, address[] misbehavedPartyAddrs);
    function challengeParties(
        uint256 txId,
        address[] calldata misbehavedPartyAddrs
    ) external existTx(txId) txNotClosed(txId) onlyTee(txId) {
        emit ChallengeParties(txId, misbehavedPartyAddrs);
    }

    event PartyResponse(uint256 txId, bytes[] input, address party);
    function partyResponse(
        uint256 txId,
        bytes[] calldata input
    ) external existTx(txId)  txNotClosed(txId) {
        emit PartyResponse(txId, input, msg.sender);
    }

    function punishParties(
        uint256 txId,
        address[] calldata misbehavedPartyAddrs
    ) external existTx(txId) txNotClosed(txId) onlyTee(txId) {
        Proposal storage prpl = prpls[txId];
        deduct(misbehavedPartyAddrs, prpl.deposit);
        prpl.status = TxStatus.ABORTED;
    }

    function punishTEE(
        uint256 txId
    ) external existTx(txId) txNotClosed(txId) txNotClosed(txId) {
        Proposal storage prpl = prpls[txId];
        require(
            block.number > prpl.maxBlockNumber4Nego.add(prpl.maxBlockNumber4Comp),
            "Require enough block number"
        );
        deduct(teeAddrList[0], prpl.deposit);
        prpl.status = TxStatus.ABORTED;
    }

    function commit(
        uint256 txId, bytes calldata verifyData, bytes calldata setData
    ) external existTx(txId) txNotClosed(txId) onlyTee(txId) {
        Proposal storage prpl = prpls[txId];
        prpl.verifiedContractAddr.functionCall(verifyData);
        prpl.verifiedContractAddr.functionCall(setData);
    }

    function complete(
        uint256 txId, bytes calldata data
    ) external existTx(txId) txNotClosed(txId) onlyTee(txId) {
        Proposal storage prpl = prpls[txId];
        prpl.verifiedContractAddr.functionCall(data);
        prpl.status = TxStatus.COMPLETED;
    }
}
