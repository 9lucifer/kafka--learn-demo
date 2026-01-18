# Kafka 集群启动状态总结

## ✅ 当前状态

**Kafka 集群已成功启动！**

### 运行中的进程

| 进程 | PID | 状态 |
|------|-----|------|
| ZooKeeper | 22255 | ✓ 运行中 |
| Kafka Broker (ID: 0) | 24222 | ✓ 运行中 |

### 集群信息

| 项目 | 值 |
|------|-----|
| Broker 地址 | localhost:9092 |
| ZooKeeper 地址 | localhost:2181 |
| Broker ID | 0 |
| 现有 Topic | test-topic, __consumer_offsets |
| 消费者组 | test-group |

## 📊 当前集群架构

```
┌─────────────────────────────────┐
│   Kafka 单 Broker 集群          │
├─────────────────────────────────┤
│                                 │
│  ┌──────────────────────────┐   │
│  │  Broker 0                │   │
│  │  Port: 9092              │   │
│  │  Status: ✓ 运行中        │   │
│  └──────────────────────────┘   │
│           │                      │
│           ▼                      │
│  ┌──────────────────────────┐   │
│  │  ZooKeeper               │   │
│  │  Port: 2181              │   │
│  │  Status: ✓ 运行中        │   │
│  └──────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

## 🚀 快速命令

### 验证集群

```bash
cd /Users/heybox/Downloads/kafka-2.7.2
bash test-cluster.sh
```

### 创建 Topic

```bash
bin/kafka-topics.sh --create \
  --topic my-topic \
  --partitions 1 \
  --replication-factor 1 \
  --bootstrap-server localhost:9092
```

### 发送消息

```bash
bin/kafka-console-producer.sh \
  --topic test-topic \
  --bootstrap-server localhost:9092
```

### 消费消息

```bash
bin/kafka-console-consumer.sh \
  --topic test-topic \
  --from-beginning \
  --bootstrap-server localhost:9092
```

## 🔧 启动多 Broker 集群

如果你想启动一个 3 Broker 的集群：

```bash
bash start-multi-broker.sh
```

这个脚本会：
1. 停止现有的 Broker
2. 生成 3 个 Broker 的配置
3. 启动 3 个 Broker（端口 9092, 9093, 9094）

## 📝 与测试代码集成

### 生产者

```java
// 使用当前 Broker
String bootstrapServers = "localhost:9092";
SimpleProducer producer = new SimpleProducer(bootstrapServers);
producer.sendMessage("test-topic", "key1", "value1");
producer.flush();
producer.close();
```

### 消费者

```java
// 使用当前 Broker
String bootstrapServers = "localhost:9092";
SimpleConsumer consumer = new SimpleConsumer(bootstrapServers, "test-group");
consumer.subscribe("test-topic");
consumer.consumeMessages(30000);
consumer.close();
```

## 📂 相关文件

| 文件 | 说明 |
|------|------|
| setup-cluster.sh | 生成集群配置 |
| start-cluster.sh | 启动集群（原始版本） |
| start-multi-broker.sh | 启动 3 Broker 集群 |
| stop-cluster.sh | 停止集群 |
| test-cluster.sh | 测试集群状态 |
| verify-cluster.sh | 验证集群环境 |
| CLUSTER_SETUP.md | 详细配置指南 |
| CLUSTER_QUICK_START.md | 快速参考卡 |

## 🔍 查看日志

```bash
# 查看 Broker 日志
tail -f logs/server.log

# 查看 ZooKeeper 日志
tail -f logs/zookeeper.log

# 查看 GC 日志
tail -f logs/kafkaServer-gc.log.0.current
```

## ⚠️ 常见问题

### Q: 如何停止集群？

```bash
bash stop-cluster.sh
```

或者手动停止：

```bash
pkill -f "kafka.Kafka"
pkill -f "QuorumPeerMain"
```

### Q: 如何清理数据？

```bash
# 删除所有集群数据
rm -rf cluster/ pids/ logs/
```

### Q: 如何查看 Broker 状态？

```bash
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

### Q: 如何列出所有 Topic？

```bash
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

## 📊 下一步

1. **运行生产者测试**
   ```bash
   java -cp "my-producer-test/build/libs/kafka-my-producer-test-2.7.2.jar:clients/build/libs/kafka-clients-2.7.2.jar" \
     org.apache.kafka.test.ProducerDemo
   ```

2. **运行消费者测试**
   ```bash
   java -cp "my-producer-test/build/libs/kafka-my-producer-test-2.7.2.jar:clients/build/libs/kafka-clients-2.7.2.jar" \
     org.apache.kafka.test.ConsumerDemo
   ```

3. **运行幂等性生产者演示**
   ```bash
   java -cp "my-producer-test/build/libs/kafka-my-producer-test-2.7.2.jar:clients/build/libs/kafka-clients-2.7.2.jar" \
     org.apache.kafka.test.IdempotentProducerDemo
   ```

## 📚 参考资源

- Kafka 官方文档：https://kafka.apache.org/documentation/
- 配置参考：https://kafka.apache.org/documentation/#brokerconfigs
- ZooKeeper 文档：https://zookeeper.apache.org/
