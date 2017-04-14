#!/bin/sh

# ------------------------------------------------------------------------------
# Reconcile the ExtraBalance account contributions using the data from
# * https://github.com/arachnid/extrabalance/extrabalance.json, renamed
#   to arachnid_extrabalance.txt
# * https://github.com/bokkypoobah/TheDAOData/blob/master/CreatedTokenEventsWithNonZeroExtraBalance_v3.txt
#
# Usage:
#   1. Download this script to getTheDAOETCData.sh .
#   2. Download the two files above
#   2. `chmod 700 getTheDAOETCData.sh`
#   3  Run `geth --rpc console` or `parity` in a separate terminal window. 
#   4. Then run this script `./getTheDAOETCData.sh`
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT licence.
# ------------------------------------------------------------------------------

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

var theDAOStartingBlock = 1428757;
// var theDAOPreHardForkBlock = 1920000;
var theDAOPreHardForkBlock = parseInt(theDAOStartingBlock) + 200000;

var theDAOABIFragment = [{"anonymous":false,"inputs":[{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"amount","type":"uint256"}],"name":"CreatedToken","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_amount","type":"uint256"}],"name":"Transfer","type":"event"}];
var theDAOAddress = "0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413";
var theDAO = web3.eth.contract(theDAOABIFragment).at(theDAOAddress);
var theDAOCreateTokenEvent = theDAO.CreatedToken({}, {fromBlock: theDAOStartingBlock, toBlock: theDAOPreHardForkBlock});
console.log("RESULT: address\tamount\t_from\t_to\tblockHash\tblockNumber\tevent\tlogIndex\ttransactionHash\ttransactionIndex");
theDAOCreateTokenEvent.watch(function(error, result) {
 console.log("RESULT: CreateToken: " + JSON.stringify(result));
});


exit;

var skipBlocks = 4 * 60 * 24; // 1 hour
var startBlockNumber = 1920000;
// var endBlockNumber = parseInt(startBlockNumber) + skipBlocks * 2000; 
var endBlockNumber = eth.blockNumber;
var refundContractAddress = "0x9f5304da62a5408416ea58a17a92611019bd5ce3";

console.log("RESULT: Checking balance from " + startBlockNumber + " to " + endBlockNumber);

for (var i = startBlockNumber; i < endBlockNumber; i += skipBlocks) {
  var balance = eth.getBalance(refundContractAddress, i);
  var timestamp = eth.getBlock(i).timestamp;
  console.log("RESULT: " + i + "\t" + timestamp + "\t" + web3.fromWei(balance, "ether"));
}



exit;

var theDAOStartingBlock = 1428757;

var theDAOABIFragment = [{"anonymous":false,"inputs":[{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"amount","type":"uint256"}],"name":"CreatedToken","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_amount","type":"uint256"}],"name":"Transfer","type":"event"}];
var theDAOAddress = "0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413";
var theDAO = web3.eth.contract(theDAOABIFragment).at(theDAOAddress);
var theDAOTransferEvent = theDAO.Transfer({}, {fromBlock: theDAOStartingBlock, toBlock: 'latest'});
console.log("address\tamount\t_from\t_to\tblockHash\tblockNumber\tevent\tlogIndex\ttransactionHash\ttransactionIndex");
theDAOTransferEvent.watch(function(error, result){
  console.log("RESULT: " + result.address + "\t" + result.args._amount / 1e16 + "\t" + result.args._from + "\t" + 
    result.args._to + "\t" + result.blockHash + "\t" + result.blockNumber + "\t" + result.event + "\t" + 
    result.logIndex + "\t" + result.transactionHash + "\t" + result.transactionIndex);
});

EOF
