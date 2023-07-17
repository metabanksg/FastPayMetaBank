var USDT = artifacts.require('./Token/USDT.sol')

module.exports = function (deployer, network) {
  deployer.deploy(USDT)
}
