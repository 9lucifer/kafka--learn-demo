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

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;

/**
 * 演示 Kafka 幂等性生产者
 * 根据《Kafka权威指南》的说法：
 * - 如果 retries > 0 且 max.in.flight.requests.per.connection > 1
 * - 当第一个批次失败，第二个批次成功时，重试第一个批次会导致消息顺序反转
 * - 解决方案：启用幂等性 (enable.idempotence = true)
 * 幂等性生产者的要求：
 * 1. enable.idempotence = true
 * 2. max.in.flight.requests.per.connection <= 5
 * 3. retries > 0
 * 4. acks = all
 */
public class IdempotentProducer {
    private static final Logger log = LoggerFactory.getLogger(IdempotentProducer.class);
    private final KafkaProducer<String, String> producer;

    /**
     * 创建普通生产者（可能导致消息重复或顺序错乱）
     */
    public IdempotentProducer(String bootstrapServers, boolean enableIdempotence) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.CLIENT_ID_CONFIG, "idempotent-producer");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        if (enableIdempotence) {
            // 启用幂等性
            props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);

            // 这些配置会被自动设置，但也可以显式指定：
            // - max.in.flight.requests.per.connection: 最多 5 个未确认请求
            // - retries: 重试次数（会被设置为 Integer.MAX_VALUE）
            // - acks: 必须是 "all"（所有副本都确认）

            log.info("启用幂等性生产者");
            log.info("  - enable.idempotence: true");
            log.info("  - max.in.flight.requests.per.connection: 5 (自动设置)");
            log.info("  - retries: Integer.MAX_VALUE (自动设置)");
            log.info("  - acks: all (自动设置)");
        } else {
            // 非幂等性生产者配置
            props.put(ProducerConfig.RETRIES_CONFIG, 3);
            props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
            props.put(ProducerConfig.ACKS_CONFIG, "1");

            log.warn("使用非幂等性生产者，可能导致消息重复或顺序错乱");
            log.warn("  - enable.idempotence: false");
            log.warn("  - max.in.flight.requests.per.connection: 5");
            log.warn("  - retries: 3");
            log.warn("  - acks: 1");
        }

        this.producer = new KafkaProducer<>(props);
    }

    /**
     * 发送消息
     * 关键点：
     * - 同一分区内的消息顺序由 key 决定
     * - 相同 key 的消息会发送到同一分区
     * - 幂等性保证：即使重试，也只会写入一次
     */
    public void sendMessage(String topic, String key, String value) {
        producer.send(new ProducerRecord<>(topic, key, value), (metadata, exception) -> {
            if (exception == null) {
                log.info("消息已发送 - 分区: {}, 偏移量: {}, Key: {}, Value: {}",
                    metadata.partition(), metadata.offset(), key, value);
            } else {
                log.error("发送消息失败 - Key: {}, Value:{} ", key, value, exception);
            }
        });
    }

    public void flush() {
        producer.flush();
    }

    public void close() {
        producer.close();
    }
}
