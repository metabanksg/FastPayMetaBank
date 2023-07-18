var router = artifacts.require('./FastPayMetabank.sol')

const own = 'TLuDrGSmc5rbo6HhZ9ufodZ9qM9ukRnKdQ'

module.exports = function (deployer, network) {
  deployer.deploy(router, own)
}
