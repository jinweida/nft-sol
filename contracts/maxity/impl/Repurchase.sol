// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '../../uniswapv2/interfaces/IUniswapV2Pair.sol';
import  '../../uniswapv2/libraries/TransferHelper.sol';
import '../interface/IMasterChef.sol';

contract Repurchase is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IMasterChef  public masterChef;

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _caller;

    address public constant BASECOIN = 0x2D6E6A6430F0121d6949D743DF54730b40C5c74F;
    address public constant REWARDTOKEN = 0xbaee9B65349929Bd78f9878555bF78027Df7f101;
    address public constant PAIR = 0x7461714666Ee7f2eF82c04a58D2C8C16cA0e6D8f;
    address public constant blackHoleAddress = 0x456D9eFa4f8039De66C8fD4a6d22953D33C6977d;
    address public constant DAOAddress = 0x0Ef67c16904Af312796560dF80E60581C43C4e24;
    address public emergencyAddress;
    event RepurchaseSwap(uint256 amountHalf,uint256 amountHole,uint256 amountDao);

    constructor (address _emergencyAddress,address _masterChef) public {
        require(_emergencyAddress != address(0), "Is zero address");
        masterChef = IMasterChef(_masterChef);
    }

    function setMasterChef(address _masterChef) public onlyOwner{
        masterChef = IMasterChef(_masterChef);
    }
    
    function setEmergencyAddress(address _newAddress) public onlyOwner {
        require(_newAddress != address(0), "Is zero address");
        emergencyAddress = _newAddress;
    }

    function addCaller(address _newCaller) public onlyOwner returns (bool) {
        require(_newCaller != address(0), "NewCaller is zero address");
        return EnumerableSet.add(_caller, _newCaller);
    }

    function delCaller(address _delCaller) public onlyOwner returns (bool) {
        require(_delCaller != address(0), "DelCaller is zero address");
        return EnumerableSet.remove(_caller, _delCaller);
    }

    function getCallerLength() public view returns (uint256) {
        return EnumerableSet.length(_caller);
    }

    function isCaller(address _call) public view returns (bool) {
        return EnumerableSet.contains(_caller, _call);
    }

    function getCaller(uint256 _index) public view returns (address){
        require(_index <= getCallerLength() - 1, "Index out of bounds");
        return EnumerableSet.at(_caller, _index);
    }
    function swapV() external view returns (uint256 amountOut){
        
        // require(IERC20(USDT).balanceOf(address(this)) >= amountIn, "Insufficient contract balance");
        uint256 amountIn = IERC20(REWARDTOKEN).balanceOf(address(this));
        uint256 amountHalf = amountIn.div(2);
        {
            (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(PAIR).getReserves();
            uint256 amountInWithFee = amountHalf.mul(9975);
            amountOut = amountHalf.mul(9975).mul(reserve0) / reserve1.mul(10000).add(amountInWithFee);
            //IERC20(USDT).safeTransfer(DDX_USDT, amountHalf);
            // IUniswapV2Pair(DDX_USDT).swap(amountOut, 0, blackHoleAddress, new bytes(0));
        }
    }

    function swap() external onlyCaller returns (uint256 amountIn,uint256 amountOut){

        uint256 beforeToken = IERC20(REWARDTOKEN).balanceOf(address(this));
        masterChef.withdraw(0,0);
        uint256 afterToken = IERC20(REWARDTOKEN).balanceOf(address(this));

        amountIn = afterToken - beforeToken;
        if(amountIn>0){
            uint256 amountHalf = amountIn.div(2);
            uint256 amountHole = 0;
            {
                (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(PAIR).getReserves();
                uint256 amountInWithFee = amountHalf.mul(9975);
                amountOut = amountHalf.mul(9975).mul(reserve1) / reserve0.mul(10000).add(amountInWithFee);
                IERC20(BASECOIN).safeTransfer(PAIR, amountHalf);
                IUniswapV2Pair(PAIR).swap(0, amountOut, blackHoleAddress, new bytes(0));
                amountHole = amountOut;
            }

            {
                (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(PAIR).getReserves();
                uint256 amountInWithFee = amountHalf.mul(9975);
                amountOut = amountHalf.mul(9975).mul(reserve1) / reserve0.mul(10000).add(amountInWithFee);
                IERC20(BASECOIN).safeTransfer(PAIR, amountHalf);
                IUniswapV2Pair(PAIR).swap(0, amountOut, DAOAddress, new bytes(0));
            }
            emit RepurchaseSwap(amountHalf,amountHole,amountOut);
        }
    }

    modifier onlyCaller() {
        require(isCaller(msg.sender), "Only isCaller can call this method");
        _;
    }



    function emergencyWithdraw(address _token) public onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) > 0, "Insufficient contract balance");
        IERC20(_token).transfer(emergencyAddress, IERC20(_token).balanceOf(address(this)));
    }

      // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyNative(uint256 amount) public onlyOwner {
        TransferHelper.safeTransferNative(msg.sender,amount)  ;
    }
}

