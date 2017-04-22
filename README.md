# Step by step instructions

## With Non-TLS
-------------------------------------------------------------------------------------------------
### Generate Org certificates

**Make sure to set the os_arch env**

```
os_arch=$(echo "$(uname -s)-$(uname -m)" | awk '{print tolower($0)}')
```

```
./../../$os_arch/bin/cryptogen generate --config=./crypto-config.yaml
```

### Generate the orderer.block and channel configuration transactions

##### export the env variable, so that configtxgen will pick the certs and configtx.yaml from current DIR
`export ORDERER_CFG_PATH=$PWD`

Generate the orderer genesis block

```
./../../$os_arch/bin/configtxgen -profile TwoOrgs -outputBlock orderer.block
```

Generate the channel configuration block
```
./../../$os_arch/bin/configtxgen -profile TwoOrgs -outputCreateChannelTx channel.tx -channelID mychannel
```

### Launch the docker based local network

**Make sure to export the OS ARCH TAG**

```
export ARCH_TAG=$(uname -m)
CHANNEL_NAME=mychannel docker-compose -f docker-compose-no-tls.yaml up -d
```

#### Check logs for the action
```
docker logs -f cli
```

**NOTE**:
* If you want to execute the commands manually comment this [entry](https://github.com/asararatnakar/dchackfest/blob/master/samples/e2e/docker-compose-no-tls.yaml#L116)
* Connect to the CLI container
	`docker exec -it cli bash`
* Enter commands manually from this file [here](https://github.com/asararatnakar/dchackfest/blob/master/samples/e2e/scripts/script-no-tls.sh)

-------------------------------------------------------------------------------------------------

## With TLS

-------------------------------------------------------------------------------------------------
Everything is same as above except that you would need to update the docker-compose with keystore entries

Use the helper commands given [here](https://github.com/asararatnakar/dchackfest#helper-commands),
				OR
change the entries manually in your docker-compose.yaml and launch the network with following command

```
export ARCH_TAG=$(uname -m)
CHANNEL_NAME=mychannel docker-compose -f docker-compose.yaml up -d
```

#### Check logs for the action
```
docker logs -f cli
```

**NOTE**:
* If you want to execute the commands manually comment this [entry](https://github.com/asararatnakar/dchackfest/blob/master/samples/e2e/docker-compose-template.yaml#L196)
* Connect to the CLI container
	`docker exec -it cli bash`
* Enter commands manually from this file [here](https://github.com/asararatnakar/dchackfest/blob/master/samples/e2e/scripts/script-tls.sh)

-------------------------------------------------------------------------------------------------

## Helper commands

Use these commands to update the private key entries in your docker-compose file
```
        PRIV_KEY=$(ls crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/keystore/)
        sed -i "s/ORDERER_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml
        PRIV_KEY=$(ls crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/keystore/)
        sed -i "s/PEER0_ORG1_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml
        PRIV_KEY=$(ls crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/keystore/)
        sed -i "s/PEER1_ORG1_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml
        PRIV_KEY=$(ls crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/keystore/)
        sed -i "s/PEER0_ORG2_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml
        PRIV_KEY=$(ls crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/keystore/)
        sed -i "s/PEER1_ORG2_PRIVATE_KEY/${PRIV_KEY}/g" docker-compose.yaml
```
