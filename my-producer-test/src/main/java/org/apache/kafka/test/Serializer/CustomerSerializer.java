package org.apache.kafka.test.Serializer;

import org.apache.kafka.common.header.Headers;
import org.apache.kafka.common.serialization.Serializer;
import org.apache.kafka.test.model.Customer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.Map;

public class CustomerSerializer implements Serializer<Customer> {

    private static final Logger log = LoggerFactory.getLogger(CustomerSerializer.class);

    @Override
    public void configure(Map<String, ?> configs, boolean isKey) {

    }

    @Override
    public byte[] serialize(String topic, Customer data) {
        try {
            byte[]serializedName;
            int stringSize;
            if(data == null)return null;
            else if(data.getName() != null){
                serializedName = data.getName().getBytes(StandardCharsets.UTF_8);
                stringSize = serializedName.length;
            }else{
                serializedName = new byte[0];
                stringSize = 0;
            }
            ByteBuffer buffer = ByteBuffer.allocate(4 + 4 + stringSize);
            buffer.putInt(data.getID());
            buffer.putInt(stringSize);
            buffer.put(serializedName);
            return buffer.array();
        }catch (Exception e){
            log.error(e.toString());
        }
    }

    @Override
    public void close() {

    }
}
