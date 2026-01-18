#!/bin/bash

# Kafka 集群停止脚本

KAFKA_HOME="/Users/heybox/Downloads/kafka-2.7.2"

echo "=========================================="
echo "停止 Kafka 集群"
echo "=========================================="
echo ""

# 停止 Broker 3
if [ -f "$KAFKA_HOME/pids/broker-3.pid" ]; then
    PID=$(cat "$KAFKA_HOME/pids/broker-3.pid")
    echo "停止 Broker 3 (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm "$KAFKA_HOME/pids/broker-3.pid"
    sleep 1
fi

# 停止 Broker 2
if [ -f "$KAFKA_HOME/pids/broker-2.pid" ]; then
    PID=$(cat "$KAFKA_HOME/pids/broker-2.pid")
    echo "停止 Broker 2 (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm "$KAFKA_HOME/pids/broker-2.pid"
    sleep 1
fi

# 停止 Broker 1
if [ -f "$KAFKA_HOME/pids/broker-1.pid" ]; then
    PID=$(cat "$KAFKA_HOME/pids/broker-1.pid")
    echo "停止 Broker 1 (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm "$KAFKA_HOME/pids/broker-1.pid"
    sleep 1
fi

# 停止 ZooKeeper
if [ -f "$KAFKA_HOME/pids/zookeeper.pid" ]; then
    PID=$(cat "$KAFKA_HOME/pids/zookeeper.pid")
    echo "停止 ZooKeeper (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm "$KAFKA_HOME/pids/zookeeper.pid"
    sleep 1
fi

echo ""
echo "=========================================="
echo "集群已停止"
echo "=========================================="
echo ""
