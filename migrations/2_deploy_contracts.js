const teeRegService = artifacts.require('TeeRegService');

module.exports = function (deployer, environment, acc) {
    deployer.deploy(teeRegService);
};