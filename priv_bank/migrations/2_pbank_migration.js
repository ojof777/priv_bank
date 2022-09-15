const priv_Bank = artifacts.require("priv_Bank");

module.exports = function (deployer) {
  deployer.deploy(priv_Bank);
};