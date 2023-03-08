# Sao-Network

Cấu hình khuyến nghị:
2 Cores;
4 Gb Ram;
SSD: 100GB.

1/ Cập nhật hệ thống:

    sudo apt update && sudo apt upgrade -y

2/ Tải về bộ cài đặt cần thiết:

    sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential manpages-dev git make ncdu -y
    
3/ Cài đặt Golang v1.19.1:

    ver="1.19.1"
    cd $HOME
    wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
    rm "go$ver.linux-amd64.tar.gz"
    
    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
    source $HOME/.bash_profile
    
4/ Tải về bộ cài đặt node:

    git clone https://github.com/SaoNetwork/sao-consensus.git
    cd sao-consensus

    git checkout testnet0

    make

5/ Cài đặt Moniker và chainID:

    saod init NodeName --chain-id=sao-testnet0
    
 Tải về khối Genesis:
 
    curl -Ls https://ss-t.sao.nodestake.top/genesis.json > $HOME/.sao/config/genesis.json 
    
 Tải về addressbook Sao:
 
    curl -Ls https://ss-t.sao.nodestake.top/addrbook.json > $HOME/.sao/config/addrbook.json
    
  Tải Snapshot để đỡ mất thời gian Sync từ đầu:
  
    SNAP_NAME=$(curl -s https://ss-t.sao.nodestake.top/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")

    curl -o - -L https://ss-t.sao.nodestake.top/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/.sao

Add state Sync
        SNAP_RPC="https://rpc-t.sao.nodestake.top:443"
        LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
        BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
        TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)
        echo $LATEST_HEIGHT $BLOCK_HEIGHT $TRUST_HASH
        sudo systemctl stop saod
        saod tendermint unsafe-reset-all --home ~/.sao/
        sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
        s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
        s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
        s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
        s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" ~/.sao/config/config.toml
        more ~/.sao/config/config.toml | grep 'rpc_servers'
        more ~/.sao/config/config.toml | grep 'trust_height'
        more ~/.sao/config/config.toml | grep 'trust_hash'
Add Peer
        PEERS="61e9e3927c1d25d91e8fefbdc880791e7974bfb5@159.223.19.154:27656,4a4c330115ed36bf8a5c8ffbc568d165ee91bd72@207.154.243.48:20656,244c464e3d500ee3f242fa3a10ae50d4cd02fc26@164.90.221.101:26656,d99276e75a528b1e5a40bee3fe41ffe80a3a5b1b@195.3.221.58:47656,59cef823c1a426f15eb9e688287cd1bc2b6ea42d@152.70.126.187:26656,39320c6f494f7e091ce9b40e7ed49b1abb6b6c5d@95.217.57.232:46656"
        sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.sao/config/config.toml

        sudo systemctl restart saod
 6/ Tạo hệ thống systemD:
 
    sudo tee /etc/systemd/system/saod.service > /dev/null <<EOF
    [Unit]
    Description=saod Daemon
    After=network-online.target
    [Service]
    User=$USER
    ExecStart=$(which saod) start
    Restart=always
    RestartSec=3
    LimitNOFILE=65535
    [Install]
    WantedBy=multi-user.target
    EOF

7/ Chạy hệ thống và lệnh kiểm tra logs

    sudo systemctl daemon-reload
    sudo systemctl enable saod
    sudo systemctl restart saod

    sudo journalctl -u saod -f
    
8/ Tạo ví Sao:

    saod keys add wallet

Nếu đã có ví Sao dùng lệnh recover:

    saod keys add wallet --recover
    
Lưu thông tin:

    cat $HOME/.saod/config/priv_validator_key.json
    
9/ Tạo validator Sao Network: lưu ý đã faucet và synced

    saod tx staking create-validator \
    --amount=10000000sao \
    --pubkey=$(saod tendermint show-validator) \
    --moniker="Node & Validator VietNam" \
    --identity=1342DBE69C23B662 \
    --details="https://t.me/NodeValidatorVietNam" \
    --chain-id=sao-testnet0 \
    --commission-rate="0.10" \
    --commission-max-rate="0.20" \
    --commission-max-change-rate="0.01" \
    --min-self-delegation="1000000" \
    --gas="2000000" \
    --gas-prices="0.0025sao" \
    --from=wallet
    -y

Kiểm tra trạng thái sync:

    saod status 2>&1 | jq .SyncInfo.catching_up

Xem số block đã sync hiện tại:

    saod status 2>&1 | jq .SyncInfo.latest_block_height

