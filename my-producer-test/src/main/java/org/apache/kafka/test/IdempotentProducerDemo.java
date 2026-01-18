/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.kafka.test;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 演示幂等性生产者的测试类
 *
 * 场景：模拟银行账户操作
 * - 账户初始余额：100 元
 * - 操作 1：存入 50 元（余额应为 150）
 * - 操作 2：取出 30 元（余额应为 120）
 *
 * 如果消息顺序错乱：
 * - 先取出 30 元（余额 70）
 * - 再存入 50 元（余额 120）
 * 结果相同，但过程中余额会变成负数！
 *
 * 使用幂等性生产者可以保证：
 * 1. 消息不会重复
 * 2. 同一分区内的消息顺序不会改变
 */
public class IdempotentProducerDemo {
    private static final Logger log = LoggerFactory.getLogger(IdempotentProducerDemo.class);

    public static void main(String[] args) {
        String bootstrapServers = "localhost:9092";
        String topic = "account-operations";

        log.info("========== 幂等性生产者演示 ==========");
        log.info("场景：银行账户操作（初始余额 100 元）");
        log.info("");

        // 演示 1：使用幂等性生产者
        log.info("--- 演示 1：启用幂等性 ---");
        demonstrateIdempotentProducer(bootstrapServers, topic, true);

        log.info("");
        log.info("--- 演示 2：不启用幂等性（可能导致问题）---");
        demonstrateIdempotentProducer(bootstrapServers, topic, false);
    }

    private static void demonstrateIdempotentProducer(String bootstrapServers, String topic, boolean enableIdempotence) {
        IdempotentProducer producer = new IdempotentProducer(bootstrapServers, enableIdempotence);

        // 使用相同的 key 确保消息发送到同一分区
        String accountId = "account-001";

        // 操作 1：存入 50 元
        producer.sendMessage(topic, accountId, "DEPOSIT:50");

        // 操作 2：取出 30 元
        producer.sendMessage(topic, accountId, "WITHDRAW:30");

        // 操作 3：存入 20 元
        producer.sendMessage(topic, accountId, "DEPOSIT:20");

        // 确保所有消息都被发送
        producer.flush();
        producer.close();

        log.info("消息已发送完毕");
        log.info("");
    }
}
