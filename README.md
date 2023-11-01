# confluent.cloud kafka

Builds confluent-cli and apache/kafka.

## Requirements

- `cloud.properties` file in project root
- docker and docker-compose

## Instructions

- Save your `cloud.properties` file in the project root.
- Run `docker compose up` in a Linux terminal to build the Dockerfile.
Once built you will see the message "Running...".
- In another terminal window, you can run the kafka commands like this:  
```
docker compose exec -it cloud ./kafka/bin/kafka-topics.sh --list --bootstrap-server $YOUR_SERVER --command-config cloud.properties
```
Where `$YOUR_SERVER` is your broker server.
Might be defined in your `cloud.properties` file.

## Notes

`confluent` does not allow a user to login.
I have created a ticket [here](https://github.com/confluentinc/cli/issues/2390).
In the interim, running `docker compose cp cloud:/usr/local/bin/confluent .` will copy the binary locally.

Mulitple warnings about `SLF4J` and class bindings.
This appears to be an internal issue with apache/kafka and does not affect running the tools.
