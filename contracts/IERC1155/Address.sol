// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev 提供与地址相关的工具函数，包括判断一个地址是否为合约地址。
 */
library Address {
    /**
     * @dev 判断一个地址是否是合约地址。
     * 
     * @param account 地址
     * @return bool 如果是合约地址返回true，否则返回false
     */
    function isContract(address account) internal view returns (bool) {
        // 根据 Solidity 的 docs，合约地址的 code length 会大于 0。
        uint256 size;
        // inline assembly 用来查询账户的代码大小
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev 向指定地址发送指定金额的以太币。
     * 
     * @param recipient 接收者地址
     * @param amount 发送的金额
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // 使用 `call` 代替 `transfer`，避免 gas 限制的问题
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev 调用目标地址的函数。
     * 
     * @param target 目标地址
     * @param data 要调用的数据（包含函数签名和参数）
     * @return 返回目标函数的返回值
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev 调用目标地址的函数，带有自定义错误消息。
     * 
     * @param target 目标地址
     * @param data 要调用的数据（包含函数签名和参数）
     * @param errorMessage 错误消息
     * @return 返回目标函数的返回值
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev 向目标地址发送指定的以太币并调用其函数。
     * 
     * @param target 目标地址
     * @param data 要调用的数据（包含函数签名和参数）
     * @param value 发送的以太币数量
     * @return 返回目标函数的返回值
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev 向目标地址发送指定的以太币并调用其函数，带有自定义错误消息。
     * 
     * @param target 目标地址
     * @param data 要调用的数据（包含函数签名和参数）
     * @param value 发送的以太币数量
     * @param errorMessage 错误消息
     * @return 返回目标函数的返回值
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    /**
     * @dev 内部实现函数调用的核心逻辑。
     */
    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) private returns (bytes memory) {
        // 确保目标地址可接收调用
        require(isContract(target), "Address: call to non-contract");

        // 执行调用
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        if (success) {
            return returndata;
        } else {
            // 如果失败，回退错误消息
            if (returndata.length > 0) {
                // 如果目标地址返回了错误信息，则使用返回的错误消息
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    /**
     * @dev 执行目标地址的静态调用
     * 
     * @param target 目标地址
     * @param data 要调用的数据（包含函数签名和参数）
     * @return 返回目标函数的返回值
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev 执行目标地址的静态调用，带有自定义错误消息。
     * 
     * @param target 目标地址
     * @param data 要调用的数据（包含函数签名和参数）
     * @param errorMessage 错误消息
     * @return 返回目标函数的返回值
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
