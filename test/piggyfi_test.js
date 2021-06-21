require('dotenv').config();

const { deployProxy } = require('@openzeppelin/truffle-upgrades');
const { ethers } = require("ethers");
const PiggyFi = artifacts.require('PiggyFi');
const truffleAssert = require('truffle-assertions');

let provider = new ethers.providers.JsonRpcProvider('https://rinkeby.infura.io/v3/05c12b07721045d2824c506f3aef90c2');
let wallet = new ethers.Wallet("c8c49b67b4878582a6ff17f6f86d83f1c8c3f0778ad51041c2d3b9360bec4772");

wallet = wallet.connect(provider);

// Start test block
contract('PiggyFi savings platform', function (accounts) {
    let piggy;

    const [userA, userB, vendorA] = accounts;

    //Deploy a new PiggyFi contract for each test
    beforeEach(async function () {
      await deployProxy(PiggyFi, ["PiggyFi", "1", 4], {initializer: '__PiggyFi_init'});

      piggy = await PiggyFi.deployed();
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

      const response = await piggy._getSigner(['DreWhyte','newUser'], [v, r, s])

      truffleAssert.eventEmitted(response, 'SignatureExtracted', (event) => {
          console.log(event.param1);
          //return ev.param1 === userA && ev.param2 === 'newUser';
      });
    });

});
