#!/bin/bash

# 测试当前 Kafka 集群

KAFKA_HOME="/Users/heybox/Downloads/kafka-2.7.2"

echo "=========================================="
echo "Kafka 集群测试"
echo "=========================================="
echo ""

cd "$KAFKA_HOME"

# 1. 查看 Broker 信息
echo "1. 查看 Broker 信息..."
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092 2>/dev/null | grep "id:" || echo "   无法连接到 Broker"

echo ""

# 2. 列出所有 Topic
echo "2. 列出所有 Topic..."
bin/kafka-topics.sh --list --bootstrap-server localhost:9092 2>/dev/null

echo ""

# 3. 查看 test-topic 详情
echo "3. 查看 test-topic 详情..."
bin/kafka-topics.sh --describe --topic test-topic --bootstrap-server localhost:9092 2>/dev/null || echo "   test-topic 不存在"

echo ""

# 4. 查看消费者组
echo "4. 查看消费者组..."
bin/kafka-consumer-groups.sh --list --bootstrap-server localhost:9092 2>/dev/null

echo ""

# 5. 运行中的进程
echo "5. 运行中的 Kafka 进程..."
jps -l | grep -E "kafka.Kafka|QuorumPeerMain"

echo ""
echo "=========================================="
echo "测试完成"
echo "=========================================="
echo ""
