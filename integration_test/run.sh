#!/bin/sh

TESTDIR=/tmp/rust_tapyruscore_rpc_test

rm -rf ${TESTDIR}
mkdir -p ${TESTDIR}/1 ${TESTDIR}/2
echo ${GENESIS_BLOCK_WITH_SIG} > ${TESTDIR}/1/genesis.${NETWORK_ID}
echo ${GENESIS_BLOCK_WITH_SIG} > ${TESTDIR}/2/genesis.${NETWORK_ID}

# To kill any remaining open tarpyrusd.
killall -9 tapyrusd

tapyrusd -dev -networkid=${NETWORK_ID} \
    -datadir=${TESTDIR}/1 \
    -port=12348 \
    -server=0 \
    -printtoconsole=0 &
PID1=$!

# Make sure it's listening on its p2p port.
sleep 3

BLOCKFILTERARG=""
FALLBACKFEEARG="-fallbackfee=0.00001000"

tapyrusd -dev -networkid=${NETWORK_ID}$BLOCKFILTERARG $FALLBACKFEEARG \
    -datadir=${TESTDIR}/2 \
    -connect=127.0.0.1:12348 \
    -rpcport=12349 \
    -rpcuser=rpcuser \
    -rpcpassword=rpcpassword \
    -server=1 \
    -txindex=1 \
    -printtoconsole=0 \
    -zmqpubrawblock=tcp://0.0.0.0:28332 \
    -zmqpubrawtx=tcp://0.0.0.0:28333 &
PID2=$!

# Let it connect to the other node.
sleep 5

RPC_URL=http://localhost:12349 \
    RPC_USER=rpcuser \
    RPC_PASS=rpcpassword \
    TESTDIR=${TESTDIR} \
    PRIVATE_KEY=${PRIVATE_KEY} \
    cargo run

RESULT=$?

kill -9 $PID1 $PID2

exit $RESULT
