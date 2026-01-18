#!/bin/bash

# 简化版：启动 3 Broker 集群
# 这个脚本会停止现有的 Broker，然后启动 3 个新的 Broker

KAFKA_HOME="/Users/heybox/Downloads/kafka-2.7.2"
CLUSTER_DIR="$KAFKA_HOME/cluster"

echo "=========================================="
echo "启动 Kafka 3 Broker 集群"
echo "=========================================="
echo ""

# 1. 停止现有的 Broker
echo "1. 停止现有的 Broker..."
pkill -f "kafka.Kafka config/server.properties" || true
sleep 2

# 2. 检查集群配置是否存在
if [ ! -f "$CLUSTER_DIR/broker-1.properties" ]; then
    echo "2. 生成集群配置..."
    bash setup-cluster.sh
else
    echo "2. 集群配置已存在"
fi

echo ""
echo "3. 启动 3 个 Broker..."

cd "$KAFKA_HOME"

# 创建日志目录
mkdir -p logs

# 启动 Broker 1
echo "   启动 Broker 1 (端口 9092)..."
nohup bin/kafka-server-start.sh cluster/broker-1.properties > logs/broker-1.log 2>&1 &
sleep 2

# 启动 Broker 2
echo "   启动 Broker 2 (端口 9093)..."
nohup bin/kafka-server-start.sh cluster/broker-2.properties > logs/broker-2.log 2>&1 &
sleep 2

# 启动 Broker 3
echo "   启动 Broker 3 (端口 9094)..."
nohup bin/kafka-server-start.sh cluster/broker-3.properties > logs/broker-3.log 2>&1 &
sleep 2

echo ""
echo "=========================================="
echo "集群启动完成！"
echo "=========================================="
echo ""
echo "验证集群状态:"
echo "  bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092"
echo ""
echo "查看日志:"
echo "  tail -f logs/broker-1.log"
echo "  tail -f logs/broker-2.log"
echo "  tail -f logs/broker-3.log"
echo ""
