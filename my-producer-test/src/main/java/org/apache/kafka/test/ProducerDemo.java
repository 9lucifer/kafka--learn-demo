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

public class ProducerDemo {
    public static void main(String[] args) {
        String bootstrapServers = "localhost:9092";
        String topic = "test-topic";

        SimpleProducer producer = new SimpleProducer(bootstrapServers);

        // 发送 10 条消息
        for (int i = 0; i < 10; i++) {
            String key = "key-" + i + 10;
            String value = "message-" + i;
            producer.sendMessage(topic, key, value);
        }

        // 确保所有消息都被发送
        producer.flush();
        producer.close();

        System.out.println("所有消息已发送完毕");
    }
}
