#!/bin/bash

# Kafka 集群启动脚本
# 用于在源码环境中启动一个 3 节点的 Kafka 集群

set -e

KAFKA_HOME="/Users/heybox/Downloads/kafka-2.7.2"
CLUSTER_DIR="$KAFKA_HOME/cluster"
ZOOKEEPER_PORT=2181
KAFKA_BASE_PORT=9092

echo "=========================================="
echo "Kafka 集群启动脚本"
echo "=========================================="
echo ""

# 1. 创建集群目录
echo "1. 创建集群目录..."
mkdir -p "$CLUSTER_DIR"/{zookeeper,broker-1,broker-2,broker-3}

# 2. 创建 ZooKeeper 配置
echo "2. 创建 ZooKeeper 配置..."
cat > "$CLUSTER_DIR/zookeeper.properties" << 'EOF'
# ZooKeeper 配置
tickTime=2000
dataDir=./cluster/zookeeper
clientPort=2181
initLimit=5
syncLimit=2
server.1=localhost:2888:3888
server.2=localhost:2889:3889
server.3=localhost:2890:3890
EOF

# 3. 创建 ZooKeeper myid 文件
echo "3. 创建 ZooKeeper myid 文件..."
echo "1" > "$CLUSTER_DIR/zookeeper/myid"

# 4. 创建 Broker 配置
echo "4. 创建 Broker 配置..."

for i in 1 2 3; do
    PORT=$((KAFKA_BASE_PORT + i - 1))
    CONFIG_FILE="$CLUSTER_DIR/broker-$i.properties"

    cat > "$CONFIG_FILE" << EOF
# Broker $i 配置
broker.id=$i
listeners=PLAINTEXT://localhost:$PORT
advertised.listeners=PLAINTEXT://localhost:$PORT
zookeeper.connect=localhost:$ZOOKEEPER_PORT
log.dirs=./cluster/broker-$i
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
num.partitions=3
default.replication.factor=3
min.insync.replicas=2
log.retention.hours=168
log.segment.bytes=1073741824
log.cleanup.policy=delete
log.cleanup.interval.ms=300000
auto.create.topics.enable=true
delete.topic.enable=true
group.initial.rebalance.delay.ms=3000
EOF

    echo "   创建 broker-$i 配置 (端口: $PORT)"
done

echo ""
echo "=========================================="
echo "配置完成！"
echo "=========================================="
echo ""
echo "集群目录结构："
echo "  $CLUSTER_DIR/"
echo "  ├── zookeeper.properties"
echo "  ├── zookeeper/"
echo "  ├── broker-1.properties"
echo "  ├── broker-1/"
echo "  ├── broker-2.properties"
echo "  ├── broker-2/"
echo "  ├── broker-3.properties"
echo "  └── broker-3/"
echo ""
echo "启动步骤："
echo "  1. 启动 ZooKeeper:"
echo "     cd $KAFKA_HOME"
echo "     bin/zookeeper-server-start.sh config/zookeeper.properties &"
echo ""
echo "  2. 启动 Broker 1 (端口 9092):"
echo "     bin/kafka-server-start.sh cluster/broker-1.properties &"
echo ""
echo "  3. 启动 Broker 2 (端口 9093):"
echo "     bin/kafka-server-start.sh cluster/broker-2.properties &"
echo ""
echo "  4. 启动 Broker 3 (端口 9094):"
echo "     bin/kafka-server-start.sh cluster/broker-3.properties &"
echo ""
echo "验证集群状态:"
echo "  bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092"
echo ""
echo "创建 Topic:"
echo "  bin/kafka-topics.sh --create --topic test-topic --partitions 3 --replication-factor 3 --bootstrap-server localhost:9092"
echo ""
echo "查看 Topic:"
echo "  bin/kafka-topics.sh --describe --topic test-topic --bootstrap-server localhost:9092"
echo ""
