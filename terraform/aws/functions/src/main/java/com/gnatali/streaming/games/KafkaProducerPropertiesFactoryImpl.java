package com.gnatali.streaming.games;

import java.util.Map;
import java.util.Properties;
import io.confluent.kafka.serializers.KafkaAvroSerializer;
import org.apache.kafka.common.serialization.StringSerializer;
import com.gnatali.streaming.games.utils.Constants;

public class KafkaProducerPropertiesFactoryImpl implements KafkaProducerPropertiesFactory {

    private Properties kafkaProducerProperties;

    public KafkaProducerPropertiesFactoryImpl() {

    }

    @Override
    public Properties getProducerProperties() {
        if (kafkaProducerProperties != null)
            return kafkaProducerProperties;

        final String keySerializer = StringSerializer.class.getCanonicalName();
        final String valueSerializer = KafkaAvroSerializer.class.getCanonicalName();

        Map<String, String> configuration = Map.ofEntries(
            Map.entry("key.serializer", keySerializer),
            Map.entry("value.serializer", valueSerializer),
            Map.entry("bootstrap.servers", Constants.BOOTSTRAP_SERVER),
            Map.entry("security.protocol", "SASL_SSL"),
            Map.entry("sasl.mechanism", "PLAIN"),
            Map.entry("sasl.jaas.config", "org.apache.kafka.common.security.plain.PlainLoginModule required username= '" + Constants.KAFKA_API_KEY + "' password='" + Constants.KAFKA_API_SECRET + "';"),
            Map.entry("session.timeout.ms","45000"),
            Map.entry("client.dns.lookup", "use_all_dns_ips"),
            Map.entry("schema.registry.url", Constants.SR_ENDPOINT),
            Map.entry("basic.auth.credentials.source", "USER_INFO"),
            Map.entry("basic.auth.user.info", Constants.SR_API_KEY + ":" + Constants.SR_API_SECRET)
        );

        kafkaProducerProperties = new Properties();

        for (Map.Entry<String, String> configEntry : configuration.entrySet()) {
            kafkaProducerProperties.put(configEntry.getKey(), configEntry.getValue());
        }



        return kafkaProducerProperties;
    }

}