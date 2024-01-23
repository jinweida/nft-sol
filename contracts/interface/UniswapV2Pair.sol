pragma solidity ^0.8.0;

interface UniswapV2Pair  {
   
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external  returns (uint liquidity);

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external  returns (uint amount0, uint amount1) ;

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external  ;

    // force balances to match reserves
    function skim(address to) external  ;
    // force reserves to match balances
    function sync() external ;
}