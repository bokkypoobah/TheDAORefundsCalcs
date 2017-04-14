#!/bin/sh

# ------------------------------------------------------------------------------
# Retrieve The DAO ETC Refund contract balance. From block 1,920,000 to latest
#
# Usage:
#   1. Download this script to getTheDAOETCRefundBalance
#   2. `chmod 700 getTheDAOETCRefundBalance`
#   3. Run `parity --pruning archive --chain classic` in a terminal and wait
#      until the syncing is complete
#   4. Then run this script `./getTheDAOETCRefundBalance` in a separate window.
#
# Enjoy. (c) BokkyPooBah 2017. The MIT licence.
# ------------------------------------------------------------------------------

geth attach rpc:http://localhost:8545 << EOF  | grep "RESULT: " | sed "s/RESULT: //"

var skipBlocks = 4 * 60 * 4; // 4 hours
var startBlockNumber = 1920000;
// var endBlockNumber = parseInt(startBlockNumber) + skipBlocks * 2000; 
var endBlockNumber = eth.blockNumber;
var refundContractAddress = "0xbf4ed7b27f1d666546e30d74d50d173d20bca754";
var extraBalanceRefundContractAddress = "0x755cdba6AE4F479f7164792B318b2a06c759833B";

console.log("RESULT: Checking balance from " + startBlockNumber + " to " + endBlockNumber);

for (var i = startBlockNumber; i < endBlockNumber; i += skipBlocks) {
  var balance = eth.getBalance(refundContractAddress, i);
  var extraBalance = eth.getBalance(extraBalanceRefundContractAddress, i);
  var timestamp = eth.getBlock(i).timestamp;
  console.log("RESULT: " + i + "\t" + timestamp + "\t" + web3.fromWei(balance, "ether") + "\t" + web3.fromWei(extraBalance, "ether"));
}

EOF
