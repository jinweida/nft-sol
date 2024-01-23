
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



interface IMaxityNGO {
    function name() external view returns (string memory);
    function email() external view returns (string memory);
    function org() external view returns (string memory);
    function orgNumber() external view returns (string memory);

    function contactAddress() external view returns (string memory);
    function phone() external view returns (string memory);
    function website() external view returns (string memory);
    function ambassador() external view returns (string memory);
    function category() external view returns (string memory);
    function wallet() external view returns (address);
    function docs() external view returns (string memory);
    function purpose() external view returns (string memory);


}
