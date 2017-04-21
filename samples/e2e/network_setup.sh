#!/bin/bash

UP_DOWN=$1
CH_NAME=$2

#COMPOSE_FILE=docker-compose.yaml
COMPOSE_FILE=docker-compose-no-tls.yaml

function printHelp () {
	echo "Usage: ./network_setup <up|down> <channel-name>"
}

function validateArgs () {
	if [ -z "${UP_DOWN}" ]; then
		echo "Option up / down / restart not mentioned"
		printHelp
		exit 1
	fi
	if [ -z "${CH_NAME}" ]; then
		echo "setting to default channel 'mychannel'"
		CH_NAME=mychannel
	fi
}

function clearContainers () {
        CONTAINER_IDS=$(docker ps -aq)
        if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" = " " ]; then
                echo "---- No containers available for deletion ----"
        else
                docker rm -f $CONTAINER_IDS
        fi
}

function removeUnwantedImages() {
        DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
        if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" = " " ]; then
                echo "---- No images available for deletion ----"
        else
                docker rmi -f $DOCKER_IMAGE_IDS
        fi
}

function generateOrdereBlock () {
	echo
	echo "##########################################################"
	echo "############## Generate certificates #####################"
	echo "##########################################################"
        ./../../bin/cryptogen generate --config=./crypto-config.yaml
	echo
	echo

	echo "##########################################################"
	echo "#########  Generating Orderer Genesis block ##############"
	echo "##########################################################"
	export ORDERER_CFG_PATH=$PWD
	./../../bin/configtxgen -profile TwoOrgs -outputBlock orderer.block
	echo
	echo

	echo "#################################################################"
	echo "### Generating channel configuration transaction 'channel.tx' ###"
	echo "#################################################################"
	./../../bin/configtxgen -profile TwoOrgs -outputCreateChannelTx channel.tx -channelID $CH_NAME
	echo
	echo

}

function networkUp () {
        generateOrdereBlock

	CHANNEL_NAME=$CH_NAME docker-compose -f $COMPOSE_FILE up -d 2>&1
	if [ $? -ne 0 ]; then
		echo "ERROR !!!! Unable to pull the images "
		exit 1
	fi
	docker logs -f cli
}

function networkDown () {
        docker-compose -f $COMPOSE_FILE down
        #Cleanup the chaincode containers
	clearContainers
	#Cleanup images
	removeUnwantedImages
        # remove orderer block and channel transaction
	rm -rf orderer.block channel.tx crypto-config
}

validateArgs

#Create the network using docker compose
if [ "${UP_DOWN}" == "up" ]; then
	networkUp
elif [ "${UP_DOWN}" == "down" ]; then ## Clear the network
	networkDown
elif [ "${UP_DOWN}" == "restart" ]; then ## Restart the network
	networkDown
	networkUp
else
	printHelp
	exit 1
fi
