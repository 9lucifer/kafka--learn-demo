# Kafka 集群配置指南

## 概述

本指南说明如何在 Kafka 源码环境中配置和启动一个 3 节点的 Kafka 集群。

## 前置条件

- Java 8 或更高版本
- Kafka 源码已下载：`/Users/heybox/Downloads/kafka-2.7.2`
- 足够的磁盘空间用于日志存储

## 快速开始

### 1. 生成集群配置

```bash
cd /Users/heybox/Downloads/kafka-2.7.2
bash setup-cluster.sh
```

这个脚本会：
- 创建集群目录结构
- 生成 ZooKeeper 配置
- 生成 3 个 Broker 的配置文件

### 2. 启动集群

```bash
bash start-cluster.sh
```

这个脚本会：
- 启动 ZooKeeper
- 启动 3 个 Broker（端口 9092, 9093, 9094）
- 保存进程 ID 到 `pids/` 目录

### 3. 验证集群状态

```bash
bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

应该看到 3 个 broker 的信息。

### 4. 停止集群

```bash
bash stop-cluster.sh
```

## 详细配置说明

### 目录结构

```
kafka-2.7.2/
├── cluster/                    # 集群数据目录
│   ├── zookeeper/             # ZooKeeper 数据
│   ├── zookeeper.properties   # ZooKeeper 配置
│   ├── broker-1.properties    # Broker 1 配置
│   ├── broker-1/              # Broker 1 日志
│   ├── broker-2.properties    # Broker 2 配置
│   ├── broker-2/              # Broker 2 日志
│   ├── broker-3.properties    # Broker 3 配置
│   └── broker-3/              # Broker 3 日志
├── pids/                       # 进程 ID 文件
├── logs/                       # 启动日志
├── setup-cluster.sh           # 配置脚本
├── start-cluster.sh           # 启动脚本
└── stop-cluster.sh            # 停止脚本
```

### ZooKeeper 配置

**文件：** `cluster/zookeeper.properties`

```properties
tickTime=2000                    # 心跳间隔（毫秒）
dataDir=./cluster/zookeeper     # 数据目录
clientPort=2181                 # 客户端端口
initLimit=5                     # 初始化超时
syncLimit=2                     # 同步超时
server.1=localhost:2888:3888    # Broker 1
server.2=localhost:2889:3889    # Broker 2
server.3=localhost:2890:3890    # Broker 3
```

### Broker 配置

**文件：** `cluster/broker-1.properties`（以 Broker 1 为例）

```properties
# 基本配置
broker.id=1                                    # Broker ID（必须唯一）
listeners=PLAINTEXT://localhost:9092          # 监听地址
advertised.listeners=PLAINTEXT://localhost:9092 # 广告地址
zookeeper.connect=localhost:2181              # ZooKeeper 连接

# 存储配置
log.dirs=./cluster/broker-1                   # 日志目录
log.retention.hours=168                       # 日志保留时间（小时）
log.segment.bytes=1073741824                  # 日志段大小（1GB）

# 网络配置
num.network.threads=3                         # 网络线程数
num.io.threads=8                              # IO 线程数
socket.send.buffer.bytes=102400               # 发送缓冲区
socket.receive.buffer.bytes=102400            # 接收缓冲区

# Topic 配置
num.partitions=3                              # 默认分区数
default.replication.factor=3                  # 默认副本因子
min.insync.replicas=2                         # 最小同步副本数

# 其他配置
auto.create.topics.enable=true                # 自动创建 Topic
delete.topic.enable=true                      # 允许删除 Topic
group.initial.rebalance.delay.ms=3000         # 消费者组初始化延迟
```

## 常见操作

### 创建 Topic

```bash
bin/kafka-topics.sh --create \
  --topic test-topic \
  --partitions 3 \
  --replication-factor 3 \
  --bootstrap-server localhost:9092
```

### 查看 Topic

```bash
bin/kafka-topics.sh --describe \
  --topic test-topic \
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

### 查看消费者组

```bash
bin/kafka-consumer-groups.sh \
  --list \
  --bootstrap-server localhost:9092
```

### 查看消费者组详情

```bash
bin/kafka-consumer-groups.sh \
  --describe \
  --group <group-id> \
  --bootstrap-server localhost:9092
```

## 故障排查

### 查看日志

```bash
# ZooKeeper 日志
tail -f logs/zookeeper.log

# Broker 日志
tail -f logs/broker-1.log
tail -f logs/broker-2.log
tail -f logs/broker-3.log
```

### 检查端口占用

```bash
# 检查 ZooKeeper 端口
lsof -i :2181

# 检查 Broker 端口
lsof -i :9092
lsof -i :9093
lsof -i :9094
```

### 强制停止进程

```bash
# 查看所有 Java 进程
jps

# 杀死特定进程
kill -9 <PID>
```

### 清理数据

```bash
# 删除所有集群数据（谨慎操作！）
rm -rf cluster/
rm -rf pids/
rm -rf logs/
```

## 性能调优

### 增加 Broker 数量

修改 `setup-cluster.sh` 中的循环次数：

```bash
for i in 1 2 3 4 5; do  # 改为 5 个 Broker
    ...
done
```

### 调整线程数

在 `broker-*.properties` 中修改：

```properties
num.network.threads=8      # 增加网络线程
num.io.threads=16          # 增加 IO 线程
```

### 增加缓冲区大小

```properties
socket.send.buffer.bytes=524288      # 512KB
socket.receive.buffer.bytes=524288   # 512KB
```

## 与生产者/消费者集成

### 生产者配置

```java
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,
    "localhost:9092,localhost:9093,localhost:9094");
```

### 消费者配置

```java
props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,
    "localhost:9092,localhost:9093,localhost:9094");
```

## 参考资源

- Kafka 官方文档：https://kafka.apache.org/documentation/
- 配置参考：https://kafka.apache.org/documentation/#brokerconfigs
- ZooKeeper 文档：https://zookeeper.apache.org/

## 注意事项

1. **数据持久化**：集群数据存储在 `cluster/` 目录，删除后无法恢复
2. **端口冲突**：确保 9092-9094 和 2181 端口未被占用
3. **磁盘空间**：日志会不断增长，定期清理或调整保留时间
4. **内存使用**：每个 Broker 默认使用 1GB 堆内存，可在启动脚本中调整
5. **网络配置**：如果在不同机器上运行，需要修改 `advertised.listeners`
