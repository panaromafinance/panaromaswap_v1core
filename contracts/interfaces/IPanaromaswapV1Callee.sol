pragma solidity >=0.5.0;

interface IPanaromaswapV1Callee {
    function panaromaswapV1Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
