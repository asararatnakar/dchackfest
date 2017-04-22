#!/bin/bash

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com
export CORE_PEER_LOCALMSPID="OrdererMSP"
export CHANNEL_NAME=mychannel

peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f channel.tx

export CORE_PEER_LOCALMSPID="Org0MSP"
export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/cacerts/org1.example.com-cert.pem
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com

peer channel join -b $CHANNEL_NAME.block
peer chaincode install -n mycc -v 1.0 -p github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02 >&log.txt
peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR	('Org0MSP.member','Org1MSP.member')"

sleep 15

peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
peer chaincode invoke -o orderer.example.com:7050  -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}' 
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
