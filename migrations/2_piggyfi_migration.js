// migrations/NN_deploy_upgradeable_box.js
const { deployProxy } = require('@openzeppelin/truffle-upgrades');

const PiggyFi = artifacts.require('PiggyFi');

module.exports = async function (deployer) {
  const instance = await deployProxy(PiggyFi, ["PiggyFi", "1"], { deployer });
};
