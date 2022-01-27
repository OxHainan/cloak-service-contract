// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.7;
import "@openzeppelin/contracts/utils/Create2.sol";
import "./Deposit.sol";

contract CloakService is Deposit{
    using SafeMath for uint256;
    using Address for address;
    enum TxStatus {UNCOMMIT, SETTLE, ABORT, COMPELETE, TIMEOUT, COMMIT}

    struct Proposal {
        bool isValid;
        TxStatus status;
        address verifiedContractAddr;
        uint256 deposit;
        uint256 initBlockNumber;
        bytes[] newStateCommit;
        bytes returnCommit;

        // party-relevant
        address[] partyAddrs;
        bytes32[] partyInputHash;
        mapping(address => bool) partyChallenged;
        mapping(address => bool) partyResponsed;
        mapping(address => uint256) partyIndex;
    }

    mapping(address => bool) public teeAddrs;
    mapping(address => bytes) public pks;
    mapping(address => bool) hasAnnounced;
    address public manager;
    mapping(uint256 => Proposal) public prpls;
    uint256 maxBlockNumber4Response;
    uint256 maxBlockNumber4Compete;

    constructor(address _manager, bytes memory pk) {
        manager = _manager;
        teeAddrs[msg.sender] = true;
        maxBlockNumber4Response = 3;
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

    function setTEEAddress(address _teeAddr, bytes memory pk) public onlyManager {
        teeAddrs[_teeAddr] = true;
        announcePk(pk);
    }
    
    modifier onlyTEE() {
        require(teeAddrs[msg.sender], "Require tee caller");
        _;
    }

    modifier existTx(uint256 txId) {
        require(prpls[txId].isValid, "Require existed transcation");
        _;
    }

    function announcePk(bytes memory pk) checkPublicKey(pk) public {
        require(!hasAnnounced[msg.sender], "Address has already announced");
        pks[msg.sender] = pk;
        hasAnnounced[msg.sender] = true;
    }

    function getPk(address[] memory addrs) public view returns(bytes[] memory) {
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

    function propose(uint256 txId, address verifiedContractAddr, address[] memory partyAddress, 
            bytes32[] memory inputHash, uint256 deposit) onlyTEE external {
        Proposal storage prpl = prpls[txId];
        require(!prpl.isValid, "txId exist");
        freeze(manager, deposit);
        freeze(partyAddress, deposit);
        prpl.isValid = true;
        prpl.verifiedContractAddr = verifiedContractAddr;
        for (uint256 i; i < partyAddress.length; i++) {
            prpl.partyAddrs.push(partyAddress[i]);
            prpl.partyInputHash.push(inputHash[i]);
            prpl.partyIndex[partyAddress[i]] = i;
        }

        prpl.deposit = deposit;
        prpl.initBlockNumber = block.number;
        prpl.status = TxStatus.SETTLE;
    }

    function commit(uint256 txId, bytes memory data, bytes memory returnCommit) onlyTEE existTx(txId) external {
        Proposal storage prpl = prpls[txId];
        require(prpl.status == TxStatus.SETTLE, "Require SETTLE tansaction status");
        prpl.verifiedContractAddr.functionCall(data);
        prpl.returnCommit = returnCommit;
        prpl.status = TxStatus.COMMIT;
    }

    function complete(uint256 txId, bytes memory data) onlyTEE existTx(txId) external {
        Proposal storage prpl = prpls[txId];
        require(prpl.status == TxStatus.COMMIT, "Require COMMIT tansaction status");
        prpl.verifiedContractAddr.functionCall(data);
        unfreeze(manager, prpl.deposit);
        unfreeze(prpl.partyAddrs, prpl.deposit);
        prpl.status = TxStatus.COMPELETE;
    }

    function challenge(uint256 txId, address[] memory misbehavedPartyAddrs) onlyTEE existTx(txId) external {
        Proposal storage prpl = prpls[txId];
        require(prpl.status == TxStatus.SETTLE, "Require SETTLE tansaction status");
        for (uint256 i; i < misbehavedPartyAddrs.length; i++) {
            require(misbehavedPartyAddrs[i] != manager, "Challenge manager is not allowed");
            require(prpl.partyAddrs[prpl.partyIndex[misbehavedPartyAddrs[i]]] == misbehavedPartyAddrs[i], "Require existed party");
            prpl.partyChallenged[misbehavedPartyAddrs[i]] = true;
        }
    }

    event Response (
        uint256 indexed txId,
        bytes indexed input
    );

    function response(uint256 txId, bytes memory input) existTx(txId) external {
        Proposal storage prpl = prpls[txId];
        require(prpl.status == TxStatus.SETTLE, "Require SETTLE tansaction status");
        require(prpl.partyChallenged[msg.sender], "Require challenged");
        bytes32  inputHash = prpl.partyInputHash[prpl.partyIndex[msg.sender]];
        require(inputHash == keccak256(input), "Require same input hash");
        prpl.partyResponsed[msg.sender] = true;
        emit Response(txId, input);
    }

    function punish(uint256 txId, address[] memory misbehavedPartyAddrs) onlyTEE existTx(txId) external {
        Proposal storage prpl = prpls[txId];
        uint256 beneficiaryLen = prpl.partyAddrs.length.sub(misbehavedPartyAddrs.length).add(1);
        require(beneficiaryLen >= 1 , "Invalid beneficiaryLen");
        require(block.number > prpl.initBlockNumber.add(maxBlockNumber4Response), "Require enough block number");
        require(prpl.status == TxStatus.SETTLE, "Require SETTLE tansaction status");
        address[] memory beneficiaries = new address[](beneficiaryLen);
        uint256 b = 0;
        for (uint256 i; i < prpl.partyAddrs.length; i++) {
            bool misbehaved = false;
            for (uint256 j; j < misbehavedPartyAddrs.length; j++) {
                require(prpl.partyChallenged[misbehavedPartyAddrs[j]], "Require challenged");
                require(!prpl.partyResponsed[misbehavedPartyAddrs[j]], "Require not responsed");
                if (prpl.partyAddrs[i] == misbehavedPartyAddrs[j]) {
                    misbehaved = true;
                }
            }
            if (!misbehaved) {
                beneficiaries[b++] = prpl.partyAddrs[i];
            }
        }
        beneficiaries[b] = manager;
        clearFrozen(misbehavedPartyAddrs, prpl.deposit);
        compensate(beneficiaries, misbehavedPartyAddrs.length, prpl.deposit);
        unfreeze(beneficiaries, prpl.deposit);
        prpl.status = TxStatus.ABORT;
    }

    function timeout(uint256 txId) existTx(txId) external {
        Proposal storage prpl = prpls[txId];
        require(prpl.status == TxStatus.SETTLE, "Require SETTLE tansaction status");
        require(block.number > prpl.initBlockNumber.add(maxBlockNumber4Compete), "Require enough block number");
        clearFrozen(manager, prpl.deposit);
        compensate(prpl.partyAddrs, 1, prpl.deposit);
        unfreeze(prpl.partyAddrs, prpl.deposit);
        prpl.status = TxStatus.TIMEOUT;
    }
}
