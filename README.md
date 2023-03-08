# Sao-Network

Cấu hình khuyến nghị:
2 Core
4 Gb Ram
SSD: 100GB

1/ Cập nhật hệ thống:

    sudo apt update

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
    
