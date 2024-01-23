pragma solidity ^0.8.0;

import "../interface/UniswapV2Pair.sol";
import "../interface/IUniswapV2Router02.sol";
import "../interface/IERC20.sol";
import '../libraries/TransferHelper.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract FetchReserves is Ownable{
    // StaticAddress.ParallelKit
    uint public value;
    constructor(){ 

    }

    function doGetProfit(address router1,
        address router2,
        uint amountIn_1,
        uint amountOutMin_1,
        uint amountOutMin_2,
        address[] calldata path_1,
        address[] calldata path_2,
        uint deadline,
        address profit
        ) external{
            
            TransferHelper.safeTransferFrom(path_1[0], msg.sender, address(this), amountIn_1);
            
            uint balance0 = IERC20Uniswap(path_1[0]).balanceOf(address(this));

            IUniswapV2Router02(router1).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn_1,amountOutMin_1,path_1,address(this),deadline);

            IUniswapV2Router02(router2).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountOutMin_1,amountOutMin_2,path_2,address(this),deadline);

            uint balance1 = IERC20Uniswap(path_1[0]).balanceOf(address(this));
            require(balance1>balance0,'no profit');

            TransferHelper.safeTransferFrom(path_1[0],  address(this),profit,balance1);
    }

    function doGetProfitSingleSwap(address router1,
        uint amountIn_1,
        uint amountOutMin_1,
        address[] calldata path_1,
        uint deadline
        ) external{
            
            TransferHelper.safeTransferFrom(path_1[0], msg.sender, address(this), amountIn_1);
            
            uint balance0 = IERC20Uniswap(path_1[0]).balanceOf(address(this));

            IUniswapV2Router02(router1).swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn_1,amountOutMin_1,path_1,address(this),deadline);

            uint balance1 = IERC20Uniswap(path_1[0]).balanceOf(address(this));
            require(balance1>balance0,'no profit');

            TransferHelper.safeTransferFrom(path_1[0],  address(this),msg.sender,balance1);
            
    }


    function emergencyWithdraw(address _to,address _token) public onlyOwner {
        require(IERC20Uniswap(_token).balanceOf(address(this)) > 0, "Insufficient contract balance");
        IERC20Uniswap(_token).transfer(_to, IERC20Uniswap(_token).balanceOf(address(this)));
    }
          // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyNative(address _to,uint256 amount) public onlyOwner {
        TransferHelper.safeTransferNative(_to,amount)  ;
    }

}