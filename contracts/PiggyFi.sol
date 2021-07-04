// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./IBEP20.sol";
import "./IVBEP20.sol";

/// @author [Email](mailto:oluwafemialofe@yahoo.com) [Telegram](t.me/@DreWhyte)
contract PiggyFi is Initializable, OwnableUpgradeable {
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

    string private constant EIP712_DOMAIN =
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";

    string private constant AUTH_TYPE = "Auth(string username,string action)";

    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256(abi.encodePacked(EIP712_DOMAIN));

    bytes32 private constant AUTH_TYPEHASH =
        keccak256(abi.encodePacked(AUTH_TYPE));

    // solhint-disable-next-line
    bytes32 private DOMAIN_SEPARATOR;

    /// @dev Users profile
    struct User {
        address publicKey;
        string username;
        uint256 daiBalance;
        uint256 underlyingBalance;
        uint256 vTokenBalance;
        bool isUser;
    }

    /// @dev Vendors profile
    /// @dev username unique
    struct Vendor {
        address publicKey;
        string username;
        uint256 daiBalance;
        int256[] openOrders;
    }

    struct Credential {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /// @dev Users savings on PiggyFi
    mapping(address => User) public users;

    /// @dev Vendors providing liquidity
    mapping(address => Vendor) public vendors;

    /// @dev For username Lookup
    mapping(string => bool) public usernames;

    ////////////////////////////////////////
    //                                    //
    //              EVENTS                //
    //                                    //
    ////////////////////////////////////////

    event SignatureExtracted(address indexed signer, string indexed action);

    /// @dev Contructor
    /// @param _name App name
    // solhint-disable-next-line
    function __PiggyFi_init(
        string memory _name,
        string memory _version,
        uint256 _chainId
    ) public initializer {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(abi.encodePacked(_name)), // string _name
                keccak256(abi.encodePacked(_version)), // string _version
                _chainId, // uint256 _chainId
                address(this) // address _verifyingContract
            )
        );
    }

    ////////////////////////////////////////
    //                                    //
    //              FUNCTIONS             //
    //                                    //
    ////////////////////////////////////////

    function hashAuth(Auth memory auth) private view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            AUTH_TYPEHASH,
                            keccak256(bytes(auth.username)),
                            keccak256(bytes(auth.action))
                        )
                    )
                )
            );
    }

    function getSigner(Auth memory _auth, Credential memory _credential)
        public
        returns (address signer)
    {
        signer = ecrecover(
            hashAuth(_auth),
            _credential.v,
            _credential.r,
            _credential.s
        );

        emit SignatureExtracted(signer, _auth.action);

        return signer;
    }

    /// @dev Create a new user profile
    /// @param _credential signature details
    function newUser(User memory _user, Credential memory _credential)
        public
        returns (User memory profile)
    {
        require(usernames[_user.username] != true, "Username already taken");

        Auth memory _auth = Auth({username: _user.username, action: "newUser"});

        address signer = getSigner(_auth, _credential);

        require(users[signer].isUser != true, "Account already exist");

        usernames[_user.username] = true;

        users[signer] = User({
            publicKey: signer,
            username: _user.username,
            daiBalance: 0,
            underlyingBalance: 0,
            vTokenBalance: 0,
            isUser: true
        });

        return users[signer];
    }
}
