#!/bin/bash
saod init NodeName --chain-id="sao-testnet0"
curl -Ls https://ss-t.sao.nodestake.top/genesis.json > $HOME/.sao/config/genesis.json 
$(which saod) start