#!/bin/bash

# 运行生产者测试
# 确保 Kafka broker 运行在 localhost:9092

KAFKA_HOME="/Users/heybox/Downloads/kafka-2.7.2"
CLASSPATH="$KAFKA_HOME/my-producer-test/build/libs/kafka-my-producer-test-2.7.2.jar:$KAFKA_HOME/clients/build/libs/kafka-clients-2.7.2.jar:$KAFKA_HOME/build/libs/log4j-1.2.17.jar:$KAFKA_HOME/build/libs/slf4j-api-1.7.30.jar"

java -cp "$CLASSPATH" org.apache.kafka.test.ProducerDemo
