require('dotenv').config();

const { ethers } = require("ethers");

let provider = new ethers.providers.JsonRpcProvider('https://rinkeby.infura.io/v3/05c12b07721045d2824c506f3aef90c2');
let userAWallet = new ethers.Wallet(process.env.USER_A_PRIVATE_KEY);
let signer = provider.getSigner();

userAWallet = userAWallet.connect(provider);

const domain = {
    name: 'PiggyFi',
    version: '1',
    chainId: 4,
    verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC'
};

const types = {
    Auth: [
        {name: 'username', type: 'string'},
        {name: 'from', type: 'string'},
    ]
};

const value = {
    username: 'DreWhyte',
    from: '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB'
};

console.log(signer._signTypedData);
