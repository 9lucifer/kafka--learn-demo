#!/bin/bash

# Kafka 集群验证脚本

KAFKA_HOME="/Users/heybox/Downloads/kafka-2.7.2"

echo "=========================================="
echo "Kafka 集群验证"
echo "=========================================="
echo ""

# 1. 检查 Java
echo "1. 检查 Java..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -1)
    echo "   ✓ $JAVA_VERSION"
else
    echo "   ✗ Java 未安装"
    exit 1
fi

echo ""

# 2. 检查 Kafka 目录
echo "2. 检查 Kafka 目录..."
if [ -d "$KAFKA_HOME" ]; then
    echo "   ✓ Kafka 目录存在: $KAFKA_HOME"
else
    echo "   ✗ Kafka 目录不存在"
    exit 1
fi

echo ""

# 3. 检查脚本
echo "3. 检查启动脚本..."
for script in bin/kafka-server-start.sh bin/zookeeper-server-start.sh bin/kafka-topics.sh; do
    if [ -f "$KAFKA_HOME/$script" ]; then
        echo "   ✓ $script"
    else
        echo "   ✗ $script 不存在"
    fi
done

echo ""

# 4. 检查配置脚本
echo "4. 检查集群配置脚本..."
for script in setup-cluster.sh start-cluster.sh stop-cluster.sh; do
    if [ -f "$KAFKA_HOME/$script" ]; then
        echo "   ✓ $script"
    else
        echo "   ✗ $script 不存在"
    fi
done

echo ""

# 5. 检查端口
echo "5. 检查端口可用性..."
for port in 2181 9092 9093 9094; do
    if lsof -i :$port &> /dev/null; then
        echo "   ⚠ 端口 $port 已被占用"
    else
        echo "   ✓ 端口 $port 可用"
    fi
done

echo ""

# 6. 检查集群配置
echo "6. 检查集群配置..."
if [ -f "$KAFKA_HOME/cluster/broker-1.properties" ]; then
    echo "   ✓ 集群配置已生成"
else
    echo "   ⚠ 集群配置未生成，请运行: bash setup-cluster.sh"
fi

echo ""

# 7. 检查进程
echo "7. 检查运行中的进程..."
ZOOKEEPER_COUNT=$(jps 2>/dev/null | grep -i quorumpeermain | wc -l)
KAFKA_COUNT=$(jps 2>/dev/null | grep -i kafkaserverstartkafka | wc -l)

if [ "$ZOOKEEPER_COUNT" -gt 0 ]; then
    echo "   ✓ ZooKeeper 运行中 ($ZOOKEEPER_COUNT 个)"
else
    echo "   ⚠ ZooKeeper 未运行"
fi

if [ "$KAFKA_COUNT" -gt 0 ]; then
    echo "   ✓ Kafka Broker 运行中 ($KAFKA_COUNT 个)"
else
    echo "   ⚠ Kafka Broker 未运行"
fi

echo ""

# 8. 尝试连接集群
echo "8. 尝试连接集群..."
if [ "$KAFKA_COUNT" -gt 0 ]; then
    BROKERS=$("$KAFKA_HOME/bin/kafka-broker-api-versions.sh" --bootstrap-server localhost:9092 2>/dev/null | grep "id:" | wc -l)
    if [ "$BROKERS" -gt 0 ]; then
        echo "   ✓ 成功连接到集群，发现 $BROKERS 个 Broker"
    else
        echo "   ⚠ 无法连接到集群"
    fi
else
    echo "   ⚠ 集群未运行，跳过连接测试"
fi

echo ""
echo "=========================================="
echo "验证完成"
echo "=========================================="
echo ""
echo "后续步骤："
echo "  1. 生成配置: bash setup-cluster.sh"
echo "  2. 启动集群: bash start-cluster.sh"
echo "  3. 验证集群: bash verify-cluster.sh"
echo ""
