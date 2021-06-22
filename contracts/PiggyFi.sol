// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import  "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import  "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//import "./IBEP20.sol";
//import "./IVBEP20.sol";

/// @author [Email](mailto:oluwafemialofe@yahoo.com) [Telegram](t.me/@DreWhyte)
contract PiggyFi is Initializable, OwnableUpgradeable{

    ////////////////////////////////////////
    //                                    //
    //         STATE VARIABLES            //
    //                                    //
    ////////////////////////////////////////

    /// @dev EIP712 struct usage to verify signer
    struct Auth {
      string username;
      string action;
    }

    string private constant EIP712_DOMAIN  = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";

    string private constant AUTH_TYPE = "Auth(string username,string action)";

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN));

    bytes32 private constant AUTH_TYPEHASH = keccak256(abi.encodePacked(AUTH_TYPE));

    bytes32 private DOMAIN_SEPARATOR;

    /// @dev Users profile
    struct User {
      address publicKey;
      string username;
      uint daiBalance;
      uint underlyingBalance;
      uint vTokenBalance;
    }

    /// @dev Vendors profile
    /// @dev username unique
    struct Vendor {
      address publicKey;
      string username;
      uint daiBalance;
      int[] openOrders;
    }

    struct Credentials {
      uint8 v;
      bytes32 r;
      bytes32 s;
    }

    /// @dev Users savings on PiggyFi
    mapping (address => User) users;

    /// @dev Vendors providing liquidity
    mapping (address => Vendor) vendors;

    /// @dev For username Lookup
    mapping (string => bool) usernames;

    ////////////////////////////////////////
    //                                    //
    //              EVENTS                //
    //                                    //
    ////////////////////////////////////////

    event SignatureExtracted(address indexed signer, string indexed action);

    /// @dev Contructor
    /// @param _name App name
    function __PiggyFi_init(string memory _name, string memory _version, uint256 _chainId) public initializer {
      DOMAIN_SEPARATOR = keccak256(abi.encode(
              EIP712_DOMAIN_TYPEHASH,
              keccak256(abi.encodePacked(_name)),       // string _name
              keccak256(abi.encodePacked(_version)),    // string _version
              _chainId,                                 // uint256 _chainId
              address(this)                             // address _verifyingContract
          ));
    }

    ////////////////////////////////////////
    //                                    //
    //              FUNCTIONS             //
    //                                    //
    ////////////////////////////////////////

    function hashAuth(Auth memory auth) private view returns (bytes32) {
        return keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    AUTH_TYPEHASH,
                    keccak256(bytes(auth.username)),
                    keccak256(bytes(auth.action))
                ))
            ));
    }

    function getSigner(Auth memory _auth, Credentials memory _credential) public returns (address signer) {
        signer = ecrecover(hashAuth(_auth), _credential.v, _credential.r, _credential.s);

        emit SignatureExtracted(signer, _auth.action);

        return signer;
    }

    /// @dev Create a new user profile
    function newUser(User memory _user) public returns(User memory profile)
    {

    }
}
