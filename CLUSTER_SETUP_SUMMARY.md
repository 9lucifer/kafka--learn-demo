# Kafka 源码环境集群配置总结

## 当前状态

✓ Java 环境已就绪（OpenJDK 1.8.0）
✓ Kafka 源码已下载
✓ ZooKeeper 已运行
⚠ Kafka Broker 需要启动

## 快速开始（3 步）

### 第 1 步：生成集群配置

```bash
cd /Users/heybox/Downloads/kafka-2.7.2
bash setup-cluster.sh
```

**作用：**
- 创建集群目录结构
- 生成 ZooKeeper 配置
- 生成 3 个 Broker 的配置文件

**输出：**
```
cluster/
├── zookeeper.properties
├── zookeeper/
├── broker-1.properties
├── broker-1/
├── broker-2.properties
├── broker-2/
├── broker-3.properties
└── broker-3/
```

### 第 2 步：启动集群

```bash
bash start-cluster.sh
```

**作用：**
- 启动 ZooKeeper（端口 2181）
- 启动 Broker 1（端口 9092）
- 启动 Broker 2（端口 9093）
- 启动 Broker 3（端口 9094）

**输出：**
```
启动 Kafka 集群
1. 启动 ZooKeeper...
   ZooKeeper PID: xxxxx
2. 启动 Broker 1 (端口 9092)...
   Broker 1 PID: xxxxx
3. 启动 Broker 2 (端口 9093)...
   Broker 2 PID: xxxxx
4. 启动 Broker 3 (端口 9094)...
   Broker 3 PID: xxxxx
```

### 第 3 步：验证集群

```bash
bash verify-cluster.sh
```

或者手动验证：

```bash
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

## 集群架构

```
┌─────────────────────────────────────────────────┐
│           Kafka 集群 (3 节点)                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌────────┐│
│  │  Broker 1    │  │  Broker 2    │  │Broker 3││
│  │  Port 9092   │  │  Port 9093   │  │Port 9094
│  └──────────────┘  └──────────────┘  └────────┘│
│         │                 │              │      │
│         └─────────────────┼──────────────┘      │
│                           │                     │
│                    ┌──────▼──────┐              │
│                    │  ZooKeeper   │              │
│                    │  Port 2181   │              │
│                    └──────────────┘              │
│                                                 │
└─────────────────────────────────────────────────┘
```

## 配置文件说明

### ZooKeeper 配置（cluster/zookeeper.properties）

```properties
tickTime=2000                    # 心跳间隔
dataDir=./cluster/zookeeper     # 数据目录
clientPort=2181                 # 客户端端口
initLimit=5                     # 初始化超时
syncLimit=2                     # 同步超时
server.1=localhost:2888:3888    # Broker 1
server.2=localhost:2889:3889    # Broker 2
server.3=localhost:2890:3890    # Broker 3
```

### Broker 配置（cluster/broker-*.properties）

关键配置项：

| 配置项 | 说明 | 值 |
|-------|------|-----|
| broker.id | Broker ID（必须唯一） | 1, 2, 3 |
| listeners | 监听地址 | PLAINTEXT://localhost:9092 |
| advertised.listeners | 广告地址 | PLAINTEXT://localhost:9092 |
| zookeeper.connect | ZooKeeper 连接 | localhost:2181 |
| log.dirs | 日志目录 | ./cluster/broker-1 |
| num.partitions | 默认分区数 | 3 |
| default.replication.factor | 默认副本因子 | 3 |
| min.insync.replicas | 最小同步副本数 | 2 |

## 常用命令

### Topic 操作

```bash
# 创建 Topic（3 个分区，3 个副本）
bin/kafka-topics.sh --create \
  --topic test-topic \
  --partitions 3 \
  --replication-factor 3 \
  --bootstrap-server localhost:9092

# 查看 Topic 详情
bin/kafka-topics.sh --describe \
  --topic test-topic \
  --bootstrap-server localhost:9092

# 列出所有 Topic
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

### 生产者/消费者

```bash
# 启动生产者
bin/kafka-console-producer.sh \
  --topic test-topic \
  --bootstrap-server localhost:9092

# 启动消费者
bin/kafka-console-consumer.sh \
  --topic test-topic \
  --from-beginning \
  --bootstrap-server localhost:9092
```

### 集群管理

```bash
# 查看 Broker 信息
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# 查看消费者组
bin/kafka-consumer-groups.sh --list --bootstrap-server localhost:9092

# 查看消费者组详情
bin/kafka-consumer-groups.sh --describe \
  --group <group-id> \
  --bootstrap-server localhost:9092
```

## 与测试代码集成

### 生产者

```java
// 使用集群的所有 Broker
String bootstrapServers = "localhost:9092,localhost:9093,localhost:9094";
SimpleProducer producer = new SimpleProducer(bootstrapServers);
producer.sendMessage("test-topic", "key1", "value1");
producer.flush();
producer.close();
```

### 消费者

```java
// 使用集群的所有 Broker
String bootstrapServers = "localhost:9092,localhost:9093,localhost:9094";
SimpleConsumer consumer = new SimpleConsumer(bootstrapServers, "test-group");
consumer.subscribe("test-topic");
consumer.consumeMessages(30000);
consumer.close();
```

## 日志位置

```
logs/
├── zookeeper.log      # ZooKeeper 日志
├── broker-1.log       # Broker 1 日志
├── broker-2.log       # Broker 2 日志
└── broker-3.log       # Broker 3 日志
```

查看日志：

```bash
tail -f logs/broker-1.log
tail -f logs/zookeeper.log
```

## 停止集群

```bash
bash stop-cluster.sh
```

## 清理数据

```bash
# 删除所有集群数据（谨慎操作！）
rm -rf cluster/ pids/ logs/
```

## 故障排查

### 问题 1：端口已被占用

```bash
# 查看占用端口的进程
lsof -i :9092

# 杀死进程
kill -9 <PID>
```

### 问题 2：集群无法启动

```bash
# 查看启动日志
tail -f logs/broker-1.log
tail -f logs/zookeeper.log

# 检查 Java 进程
jps
```

### 问题 3：消息无法发送

```bash
# 验证集群连接
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# 检查 Topic 是否存在
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

## 文件清单

| 文件 | 说明 |
|------|------|
| setup-cluster.sh | 生成集群配置 |
| start-cluster.sh | 启动集群 |
| stop-cluster.sh | 停止集群 |
| verify-cluster.sh | 验证集群环境 |
| CLUSTER_SETUP.md | 详细配置指南 |
| CLUSTER_QUICK_START.md | 快速参考卡 |

## 下一步

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

## 参考资源

- Kafka 官方文档：https://kafka.apache.org/documentation/
- 配置参考：https://kafka.apache.org/documentation/#brokerconfigs
- ZooKeeper 文档：https://zookeeper.apache.org/
