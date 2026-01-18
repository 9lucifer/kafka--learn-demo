# Kafka 幂等性生产者详解

## 核心概念

根据《Kafka权威指南》的说法，Kafka 可以保证同一分区内的消息顺序。但在某些情况下，如果配置不当，消息顺序可能会被打乱。

## 问题场景

### 配置：
- `retries > 0`（启用重试）
- `max.in.flight.requests.per.connection > 1`（多个请求并发发送）

### 问题：
当第一个批次失败，第二个批次成功时：
1. 第二个批次先被 broker 写入
2. 第一个批次重试后被写入
3. 结果：消息顺序反转！

### 例子（银行账户）：
```
初始余额：100 元

正确顺序：
1. 存入 50 元 → 余额 150
2. 取出 30 元 → 余额 120

错误顺序（消息反转）：
1. 取出 30 元 → 余额 70
2. 存入 50 元 → 余额 120

虽然最终余额相同，但过程中余额会变成负数！
```

## 解决方案：启用幂等性

### 配置：
```java
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
```

### 幂等性生产者的要求：
1. **enable.idempotence = true**
2. **max.in.flight.requests.per.connection ≤ 5**
3. **retries > 0**
4. **acks = all**

### 自动设置：
当启用幂等性时，Kafka 会自动设置：
- `max.in.flight.requests.per.connection`: 5（最多 5 个未确认请求）
- `retries`: Integer.MAX_VALUE（无限重试）
- `acks`: "all"（所有副本都确认）

## 源代码位置

### ProducerConfig.java 中的关键代码：

**1. 配置定义（第 201-252 行）：**
```java
// max.in.flight.requests.per.connection
public static final String MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION = "max.in.flight.requests.per.connection";
private static final String MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION_DOC =
    "The maximum number of unacknowledged requests the client will send on a single connection before blocking."
    + " Note that if this setting is set to be greater than 1 and there are failed sends, there is a risk of"
    + " message re-ordering due to retries (i.e., if retries are enabled).";

// enable.idempotence
public static final String ENABLE_IDEMPOTENCE_CONFIG = "enable.idempotence";
public static final String ENABLE_IDEMPOTENCE_DOC =
    "When set to 'true', the producer will ensure that exactly one copy of each message is written in the stream."
    + "Note that enabling idempotence requires max.in.flight.requests.per.connection to be less than or equal to 5, "
    + "retries to be greater than 0 and acks must be 'all'.";
```

**2. 幂等性验证（第 466-485 行）：**
```java
private void maybeOverrideAcksAndRetries(final Map<String, Object> configs) {
    if (idempotenceEnabled()) {
        // 检查 retries 是否 > 0
        if (this.getInt(RETRIES_CONFIG) == 0) {
            throw new ConfigException("Must set retries to non-zero when using the idempotent producer.");
        }

        // 检查 acks 是否为 "all"
        if (userConfiguredAcks && acks != (short) -1) {
            throw new ConfigException("Must set acks to all in order to use the idempotent producer.");
        }

        // 自动设置配置
        configs.put(RETRIES_CONFIG, Integer.MAX_VALUE);
        configs.put(ACKS_CONFIG, "-1");  // -1 表示 "all"
    }
}
```

**3. 幂等性检查（第 539-547 行）：**
```java
boolean idempotenceEnabled() {
    boolean userConfiguredIdempotence = this.originals().containsKey(ENABLE_IDEMPOTENCE_CONFIG);
    boolean userConfiguredTransactions = this.originals().containsKey(TRANSACTIONAL_ID_CONFIG);
    boolean idempotenceEnabled = userConfiguredIdempotence && this.getBoolean(ENABLE_IDEMPOTENCE_CONFIG);

    if (!idempotenceEnabled && userConfiguredIdempotence && userConfiguredTransactions)
        throw new ConfigException("Cannot set a transactional.id without also enabling idempotence.");
    return userConfiguredTransactions || idempotenceEnabled;
}
```

## 使用示例

### 启用幂等性：
```java
IdempotentProducer producer = new IdempotentProducer("localhost:9092", true);
producer.sendMessage("account-operations", "account-001", "DEPOSIT:50");
producer.sendMessage("account-operations", "account-001", "WITHDRAW:30");
producer.flush();
producer.close();
```

### 不启用幂等性（可能导致问题）：
```java
IdempotentProducer producer = new IdempotentProducer("localhost:9092", false);
// 可能导致消息重复或顺序错乱
```

## 关键点总结

| 方面 | 说明 |
|------|------|
| **问题** | retries > 0 且 max.in.flight > 1 时，消息可能顺序错乱 |
| **原因** | 第一个批次失败，第二个批次成功，重试导致顺序反转 |
| **解决方案** | 启用幂等性 (enable.idempotence = true) |
| **幂等性要求** | max.in.flight ≤ 5, retries > 0, acks = all |
| **自动设置** | Kafka 会自动调整这些配置 |
| **保证** | 消息不重复，同分区内顺序不变 |

## 运行演示

```bash
# 编译
./gradlew :my-producer-test:build

# 运行幂等性生产者演示
java -cp "my-producer-test/build/libs/kafka-my-producer-test-2.7.2.jar:clients/build/libs/kafka-clients-2.7.2.jar" \
  org.apache.kafka.test.IdempotentProducerDemo
```

## 参考资源

- 《Kafka权威指南（第2版）》- 第 3 章：生产者
- Kafka 官方文档：https://kafka.apache.org/documentation/#producerconfigs
- 源代码：`clients/src/main/java/org/apache/kafka/clients/producer/ProducerConfig.java`
