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
    console.log(service._address)
    let accounts = await generate_parties();

    const id_index = 1;
    // console.log(accounts)

    for (let i = 1; i <= 11; i++) {
        let cha_acc = new Array(i);
        for (let j = 0; j < i; j++) {
            cha_acc[j] = accounts[j].address;
        }
        // propose
        {

            await send(service._address,
                service.methods.propose(id_index + i, cha_acc, 100),
                tee.privateKey
            )

        }

        // change
        {
            let tx = await send(service._address,
                service.methods.challenge(id_index + i, cha_acc),
                tee.privateKey
            )

            console.log("change gas: ", tx.cumulativeGasUsed)
            writeData({
                "name": "change",
                "n": i,
                "gasUsed": tx.cumulativeGasUsed
            })
        }

        let acc = new Array(i);
        for (let j = 0; j < i; j++) {
            acc[j] = accounts[j];
        }
        // response
        {
            let input = new Array(i);
            let encrypted = new Array(i);
            for (let j = 0; j < i; j++) {
                input[j] = create_input(j);
                encrypted[j] = encryption(acc[j].privateKey, getPublicKey(teeKey), input[j]);
            }
            for (let j = 0; j < i; j++) {

                let tx = await send(
                    service._address,
                    service.methods.response(id_index + i, encrypted[j]),
                    userKey,
                )
                console.log("response gas: ", tx.cumulativeGasUsed)

                writeData({
                    "name": "response",
                    "n": i,
                    "gasUsed": tx.cumulativeGasUsed,
                    "origin_data": input[j],
                    "party": acc[j].address,
                    "encrypted_data": encrypted[j]
                })
            }
        }

        // 聚合相应
        {
            let input = new Array(i);
            let message = new Array(i);
            let signature = new Array(i);
            for (let j = 0; j < i; j++) {
                message[j] = create_input(j);
                input[j] = encryption(acc[j].privateKey, getPublicKey(teeKey), message[j]);
                signature[j] = await web3.eth.accounts.sign(input[j], acc[j].privateKey).signature;
            }


            let tx = await send(
                service._address,
                service.methods.response(id_index + i, input, signature),
                userKey
            )

            console.log("response gas: ", tx.cumulativeGasUsed)
            let res_party = new Array(i);
            for (let j = 0; j < i; j++) {
                res_party[j] = acc[j].address
            }
            writeData({
                "name": "merge-response",
                "n": i,
                "gasUsed": tx.cumulativeGasUsed,
                "origin_data": message,
                "party": res_party,
                "encrypted_data": input,
                "signature": signature
            })

        }

        // 惩罚
        {
            let tx = await send(service._address,
                service.methods.punish(id_index + i, cha_acc),
                tee.privateKey
            )

            console.log("punish gas: ", tx.cumulativeGasUsed)
            writeData({
                "name": "punish",
                "n": i,
                "gasUsed": tx.cumulativeGasUsed
            })
        }

        // 惩罚
        {
            let tx = await send(service._address,
                service.methods.timeout(id_index + i),
                tee.privateKey
            )

            console.log("timeout gas: ", tx.cumulativeGasUsed)
            writeData({
                "name": "timeout",
                "n": i,
                "gasUsed": tx.cumulativeGasUsed
            })
        }
    }



}

process()


