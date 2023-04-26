const Web3 = require('web3');
const secp256k1 = require('secp256k1');
const fs = require('fs');
const crypto = require('crypto')
var CryptoJS = require("crypto-js");
const TxStatus = { UNCOMMIT: 0, SETTLE: 1, ABORT: 2, COMPELETE: 3, TIMEOUT: 4 };

function getPublicKey(privateKey) {
    let pubKey = secp256k1.publicKeyCreate(Buffer.from(privateKey.slice(2), 'hex'), false);
    return "0x" + Buffer.from(pubKey).toString('hex');
}

const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
var userKey = '0x55b99466a43e0ccb52a11a42a3b4e10bfba630e8427570035f6db7b5c22f681e';
var teeKey = '0x55b99466a43e0ccb52a11a42a3b4e10bfba630e8427570035f6db7b5c22f689e';


let user = web3.eth.accounts.privateKeyToAccount(userKey);
let tee = web3.eth.accounts.privateKeyToAccount(teeKey);

function encryption(prikey, pubKey, data) {
    const ecdh = crypto.createECDH('secp256k1');
    ecdh.setPrivateKey(Buffer.from(prikey.substring(2, 66), 'hex'));
    let key = ecdh.computeSecret(Buffer.from(pubKey.substring(2, 132), 'hex'), null, 'hex');
    var iv = '0123456789abcdef';

    key = CryptoJS.enc.Utf8.parse(key);
    iv = CryptoJS.enc.Utf8.parse(iv);

    var encrypted = CryptoJS.AES.encrypt(data, key, {
        iv: iv,
        mode: CryptoJS.mode.CBC,
        padding: CryptoJS.pad.Pkcs7
    });

    return web3.utils.fromAscii(encrypted.toString())
}

async function send(to, data, pkey, value = 0) {
    let hex = await web3.eth.accounts.signTransaction({
        to: to,
        data: data === null ? data : data.encodeABI(),
        gasPrice: web3.utils.toHex(0),
        gas: web3.utils.toHex(50e5),
        value: value
    }, pkey);

    let receipt = await web3.eth.sendSignedTransaction(hex.rawTransaction)
    if (to === null) {
        return receipt.contractAddress;
    }

    return receipt;
}

async function deploy(path, params, priv) {
    let obj = JSON.parse(fs.readFileSync(path));
    let it = new web3.eth.Contract(obj.abi);

    let data = await it.deploy({
        data: obj.bytecode,
        arguments: params
    });

    let addr = await send(null, data, priv);
    return new web3.eth.Contract(obj.abi, addr);
}

async function sign(message, prikey) {
    let sign = await web3.eth.accounts.sign(message, prikey);
    return sign.signature
}

async function generate_parties() {
    let parties = new Array(13);
    for (let i = 0; i < parties.length; i++) {
        parties[i] = web3.eth.accounts.privateKeyToAccount(web3.utils.keccak256("account" + i));
    }
    return parties
}

function create_input(i) {
    return web3.utils.keccak256("party" + i)
}

function writeData(data) {
    fs.writeFile('data/data.txt', `${JSON.stringify(data)}\n`, { 'flag': 'a' }, function (err) {
        if (err) throw err;
    });
}

async function process() {
    let service = await deploy("../build/contracts/CloakService.json", [user.address, getPublicKey(tee.privateKey)], tee.privateKey)
    console.log(user.address)
    console.log(getPublicKey(tee.privateKey))
    let userContract = await deploy("../build/contracts/Oracle.json", ["0x213a035BA341A259C42dbc7669CF1fD007951A6F","0x213a035BA341A259C42dbc7669CF1fD007951A6F","0x213a035BA341A259C42dbc7669CF1fD007951A6F","0x213a035BA341A259C42dbc7669CF1fD007951A6F","0x213a035BA341A259C42dbc7669CF1fD007951A6F","0x213a035BA341A259C42dbc7669CF1fD007951A6F","0x213a035BA341A259C42dbc7669CF1fD007951A6F","0x213a035BA341A259C42dbc7669CF1fD007951A6F","0x213a035BA341A259C42dbc7669CF1fD007951A6F","0x213a035BA341A259C42dbc7669CF1fD007951A6F"], tee.privateKey)
    console.log(userContract._address)
    let accounts = await generate_parties();

    // requestRandom getVerifiableRandom
    let read = ["0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000"]
    let return_len = 38
    let new_states = await userContract.methods.get_states(read, return_len).call()
    // propose
    {
    let tx = await send(service._address,
            service.methods.challengeTEE(0, 100, 3, userContract._address),
            accounts[0].privateKey
        )
    }
    // commit
    {
        let tx = await send(service._address,
            service.methods.commit(0, new_states, "0x0000000000000000000000000000000000000000000000000000000000000000"),
            tee.privateKey
        )
        console.log("commit gas: ", tx.cumulativeGasUsed)
        writeData({
            "name": "commit",
            "n": 0,
            "gasUsed": tx.cumulativeGasUsed
        })
    }
    // complete
    {
        let tx = await send(service._address,
            service.methods.complete(0, new_states, "0x0000000000000000000000000000000000000000000000000000000000000000"),
            tee.privateKey
        )
        console.log("complete gas: ", tx.cumulativeGasUsed)
        writeData({
            "name": "complete",
            "n": 0,
            "gasUsed": tx.cumulativeGasUsed
        })
    }

}

process()


