require('dotenv').config();

const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const { ethers } = require("ethers");
const PiggyFi = artifacts.require('PiggyFi');
const truffleAssert = require('truffle-assertions');

let provider = new ethers.providers.JsonRpcProvider('https://rinkeby.infura.io/v3/05c12b07721045d2824c506f3aef90c2');
let wallet = new ethers.Wallet(process.env.USER_A_PRIVATE_KEY, provider);

// Start test block
contract('PiggyFi savings platform', function (accounts) {
    let piggy;

    const [userA, userB, vendorA] = accounts;

    console.log(accounts);

    //Deploy a new PiggyFi contract for each test
    beforeEach(async function () {
      //await deployProxy(PiggyFi, ["PiggyFi", "1", 4], {initializer: '__PiggyFi_init'});

      piggy = await PiggyFi.at("0xccc3d93142B6de14E8B1c737b62E9E5a54f1e91f",{from: userA});
    });


    it('retrieve the correct address that signs a message', async function () {

      const domain = {
          name: 'PiggyFi',
          version: '1',
          chainId: 4,
          verifyingContract: piggy.address
      };

      const types = {
          Auth: [
              {name: 'username', type: 'string'},
              {name: 'action', type: 'string'},
          ]
      };

      const value = {
          username: 'DreWhyte',
          action: 'newUser'
      };

      const signature = await wallet._signTypedData(domain, types, value);
      const {v, r, s} = ethers.utils.splitSignature(signature);

      //0xe84b6Dc1B28dce622D704B0479878896b6943267

      const response = await piggy.getSigner(['DreWhyte','newUser'], [v, r, s],{from: userA});

      truffleAssert.eventEmitted(response, 'SignatureExtracted', (event) => {
          return event.signer === userA && event.action === 'newUser';
      });
    });

});
