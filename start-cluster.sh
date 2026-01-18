#!/bin/bash

# Kafka 集群启动脚本
# 一键启动 ZooKeeper 和 3 个 Broker

KAFKA_HOME="/Users/heybox/Downloads/kafka-2.7.2"
CLUSTER_DIR="$KAFKA_HOME/cluster"

echo "=========================================="
echo "启动 Kafka 集群"
echo "=========================================="
echo ""

# 检查集群配置是否存在
if [ ! -f "$CLUSTER_DIR/broker-1.properties" ]; then
    echo "错误：集群配置不存在"
    echo "请先运行: bash setup-cluster.sh"
    exit 1
fi

cd "$KAFKA_HOME"

# 启动 ZooKeeper
echo "1. 启动 ZooKeeper..."
nohup bin/zookeeper-server-start.sh config/zookeeper.properties > logs/zookeeper.log 2>&1 &
ZOOKEEPER_PID=$!
echo "   ZooKeeper PID: $ZOOKEEPER_PID"
sleep 3

# 启动 Broker 1
echo "2. 启动 Broker 1 (端口 9092)..."
nohup bin/kafka-server-start.sh cluster/broker-1.properties > logs/broker-1.log 2>&1 &
BROKER1_PID=$!
echo "   Broker 1 PID: $BROKER1_PID"
sleep 2

# 启动 Broker 2
echo "3. 启动 Broker 2 (端口 9093)..."
nohup bin/kafka-server-start.sh cluster/broker-2.properties > logs/broker-2.log 2>&1 &
BROKER2_PID=$!
echo "   Broker 2 PID: $BROKER2_PID"
sleep 2

# 启动 Broker 3
echo "4. 启动 Broker 3 (端口 9094)..."
nohup bin/kafka-server-start.sh cluster/broker-3.properties > logs/broker-3.log 2>&1 &
BROKER3_PID=$!
echo "   Broker 3 PID: $BROKER3_PID"
sleep 2

echo ""
echo "=========================================="
echo "集群启动完成！"
echo "=========================================="
echo ""
echo "进程信息："
echo "  ZooKeeper: $ZOOKEEPER_PID"
echo "  Broker 1:  $BROKER1_PID"
echo "  Broker 2:  $BROKER2_PID"
echo "  Broker 3:  $BROKER3_PID"
echo ""
echo "验证集群状态:"
echo "  bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092"
echo ""
echo "查看日志:"
echo "  tail -f logs/broker-1.log"
echo "  tail -f logs/broker-2.log"
echo "  tail -f logs/broker-3.log"
echo ""
echo "停止集群:"
echo "  bash stop-cluster.sh"
echo ""

# 保存 PID 到文件
mkdir -p "$KAFKA_HOME/pids"
echo "$ZOOKEEPER_PID" > "$KAFKA_HOME/pids/zookeeper.pid"
echo "$BROKER1_PID" > "$KAFKA_HOME/pids/broker-1.pid"
echo "$BROKER2_PID" > "$KAFKA_HOME/pids/broker-2.pid"
echo "$BROKER3_PID" > "$KAFKA_HOME/pids/broker-3.pid"
