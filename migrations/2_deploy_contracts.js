var router = artifacts.require('./FastPayMetabank.sol')

const own = 'TNEu7Qyq3TcMFRQNzzuqvFvExG9sDnDp7o'

module.exports = function (deployer, network) {
  deployer.deploy(router, own)
}
