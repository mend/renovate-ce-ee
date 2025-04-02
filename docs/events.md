# Event-driven notifications

Renovate EE supports event-driven notifications via its **workers**. When enabled, Renovate CLI log messages at `INFO`
level and above will be submitted to the predefined Kafka broker.

## Environment variables for configuring event notifications to Kafka

The following is a list of configuration variables for using TLS communication.

| Configuration variable                       | Brief description                                             |
|----------------------------------------------|---------------------------------------------------------------|
| `MEND_RNV_KAFKA_TOPIC_NAME`                  | The Kafka topic to which messages are submitted.              |
| `MEND_RNV_KAFKA_TOPIC_CONFIG`                | Topic configuration for Kafka producer.                       |
| `MEND_RNV_KAFKA_PRODUCER_GLOBAL_CONFIG`      | Global configuration for the Kafka producer.                  |
| `MEND_RNV_KAFKA_PRODUCER_GLOBAL_CONFIG_PATH` | Path to a global producer configuration file.                 |
| `MEND_RNV_KAFKA_PARTITION_KEY_CANDIDATES`    | List of keys whose values will be used as Kafka message keys. |

See below for detailed descriptions and examples.

# Configuration details

To enable event-driven configuration, either `MEND_RNV_KAFKA_PRODUCER_GLOBAL_CONFIG` or
`MEND_RNV_KAFKA_PRODUCER_GLOBAL_CONFIG_PATH` must be configured. If both are provided, the former will take precedence.
Renovate EE uses the `node-rdkafka`[^1] library, which is a wrapper around `librdkafka`[^2].

All the configuration options described below should be set on the Renovate EE worker end.

**`MEND_RNV_KAFKA_TOPIC_NAME`**: The Kafka topic to which messages are submitted. Default: "mend-renovate-ee".

> [!IMPORTANT]  
> Topics need to be manually created. If the topic defined does not exist at startup, the worker will terminate.

**`MEND_RNV_KAFKA_TOPIC_CONFIG`**: Optional. A Kafka producer topic configuration. Expects a JSON string representation
of `node-rdkafka`' s [producer topic config interface](https://github.com/Blizzard/node-rdkafka/blob/23a403d4ee26e2b34449e10dd96f193aea78d4ed/config.d.ts#L987-L1074).

**`MEND_RNV_KAFKA_PRODUCER_GLOBAL_CONFIG`**: A global configuration for the Kafka producer. Expects a JSON string
representation of the `librdkafka` [global configuration properties](https://github.com/confluentinc/librdkafka/blob/6d8ce88c6a2d02881e6c93f405c4518dcec9570a/CONFIGURATION.md).

Minimal configuration example:

```
MEND_RNV_KAFKA_PRODUCER_GLOBAL_CONFIG='{"metadata.broker.list": "kafka:9093"}'
```

> [!TIP]
> Both `MEND_RNV_KAFKA_TOPIC_CONFIG` and `MEND_RNV_KAFKA_PRODUCER_GLOBAL_CONFIG` support dynamically loading file or
> base64-based content.
> To load the content of a file into a given configuration option, set its value to `file://<ABSOLUTE_PATH>`.
> To encode data in base64 for a given configuration option, set its value to `base64://<BASE64_ENCODED_DATA>`.

**`MEND_RNV_KAFKA_PRODUCER_GLOBAL_CONFIG_PATH`**: A path to a global producer configuration file. Expects a JSON
representation of the `librdkafka` [global configuration properties](https://github.com/confluentinc/librdkafka/blob/6d8ce88c6a2d02881e6c93f405c4518dcec9570a/CONFIGURATION.md).

**`MEND_RNV_KAFKA_PARTITION_KEY_CANDIDATES`**: Optional. A comma-separated list of keys whose values will be used as
Kafka message keys. The value of the first key found in the message will be used as the Kafka key. If none of the keys
are present in the message, `null` will be used as the Kafka key.

If this is not set, all messages will be submitted with a `null` Kafka key.

For example, consider the following setting:

`MEND_RNV_KAFKA_PARTITION_KEY_CANDIDATES= no_such_key, repository`

For a message to be submitted:

```json
{
  "level": 30,
  "name": "renovate",
  "hostname": "e323075dc9c9",
  "pid": 30,
  "repository": "org_name/repo",
  "logContext": "9cd9202d-372d-4662-9c70-28ae4d0a24da",
  "renovateVersion": "39.185.4",
  "time": "2025-03-19T09:14:39.847Z",
  "v": 0,
  "msg": "Repository started",
  "org": "org_name"
}
```

the Kafka key used to submit this message will be `org_name/repo`.

[^1]: https://github.com/Blizzard/node-rdkafka
[^2]: https://github.com/confluentinc/librdkafka
