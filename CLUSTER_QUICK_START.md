# Kafka 集群快速参考

## 一键启动

```bash
cd /Users/heybox/Downloads/kafka-2.7.2

# 1. 生成配置
bash setup-cluster.sh

# 2. 启动集群
bash start-cluster.sh

# 3. 验证集群
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

## 集群信息

| 组件 | 地址 | 端口 |
|------|------|------|
| ZooKeeper | localhost | 2181 |
| Broker 1 | localhost | 9092 |
| Broker 2 | localhost | 9093 |
| Broker 3 | localhost | 9094 |

## 常用命令

### Topic 操作

```bash
# 创建 Topic
bin/kafka-topics.sh --create --topic test-topic --partitions 3 --replication-factor 3 --bootstrap-server localhost:9092

# 查看 Topic
bin/kafka-topics.sh --describe --topic test-topic --bootstrap-server localhost:9092

# 列出所有 Topic
bin/kafka-topics.sh --list --bootstrap-server localhost:9092

# 删除 Topic
bin/kafka-topics.sh --delete --topic test-topic --bootstrap-server localhost:9092
```

### 生产者/消费者

```bash
# 启动生产者
bin/kafka-console-producer.sh --topic test-topic --bootstrap-server localhost:9092

# 启动消费者
bin/kafka-console-consumer.sh --topic test-topic --from-beginning --bootstrap-server localhost:9092

# 消费者组
bin/kafka-consumer-groups.sh --list --bootstrap-server localhost:9092
bin/kafka-consumer-groups.sh --describe --group <group-id> --bootstrap-server localhost:9092
```

### 集群管理

```bash
# 查看 Broker 信息
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# 查看日志目录
bin/kafka-log-dirs.sh --bootstrap-server localhost:9092 --describe

# 查看消费者偏移量
bin/kafka-consumer-groups.sh --describe --group <group-id> --bootstrap-server localhost:9092
```

## 日志位置

```
logs/
├── zookeeper.log
├── broker-1.log
├── broker-2.log
└── broker-3.log
```

## 停止集群

```bash
bash stop-cluster.sh
```

## 清理数据

```bash
# 删除所有集群数据
rm -rf cluster/ pids/ logs/
```

## 与测试代码集成

### 生产者

```java
String bootstrapServers = "localhost:9092,localhost:9093,localhost:9094";
SimpleProducer producer = new SimpleProducer(bootstrapServers);
producer.sendMessage("test-topic", "key1", "value1");
producer.flush();
producer.close();
```

### 消费者

```java
String bootstrapServers = "localhost:9092,localhost:9093,localhost:9094";
SimpleConsumer consumer = new SimpleConsumer(bootstrapServers, "test-group");
consumer.subscribe("test-topic");
consumer.consumeMessages(30000);
consumer.close();
```

## 故障排查

### 检查进程

```bash
jps  # 查看所有 Java 进程
```

### 检查端口

```bash
lsof -i :9092  # 检查 Broker 端口
lsof -i :2181  # 检查 ZooKeeper 端口
```

### 查看日志

```bash
tail -f logs/broker-1.log
tail -f logs/zookeeper.log
```

### 强制停止

```bash
# 查找进程
ps aux | grep kafka
ps aux | grep zookeeper

# 杀死进程
kill -9 <PID>
```

## 配置文件位置

- ZooKeeper: `cluster/zookeeper.properties`
- Broker 1: `cluster/broker-1.properties`
- Broker 2: `cluster/broker-2.properties`
- Broker 3: `cluster/broker-3.properties`

## 更多信息

详见 `CLUSTER_SETUP.md`
