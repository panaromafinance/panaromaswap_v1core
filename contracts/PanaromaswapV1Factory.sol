pragma solidity =0.5.16;

import './interfaces/IPanaromaswapV1Factory.sol';
import './PanaromaswapV1Pair.sol';

contract PanaromaswapV1Factory is IPanaromaswapV1Factory {
    address public feeTo;
    address public feeToSetter;
    address public RouterAdmin;
    address public RouterAdmin2;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function setRouter(address payable _router) external {
        require(msg.sender == feeToSetter, 'PanaromaswapV1: ADMIN NOT FOUND');
        RouterAdmin = _router;
    }

    function setRouter2(address payable _router2) external {
        require(msg.sender == feeToSetter, 'PanaromaswapV1: ADMIN NOT FOUND');
        RouterAdmin2 = _router2;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'PanaromaswapV1: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PanaromaswapV1: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'PanaromaswapV1: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(PanaromaswapV1Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IPanaromaswapV1Pair(pair).initialize(token0, token1, RouterAdmin, RouterAdmin2);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'PanaromaswapV1: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'PanaromaswapV1: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}
