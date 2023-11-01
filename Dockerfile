FROM debian:bookworm-slim

ARG TARGETPLATFORM
ARG CLIVERSION=v3.39.1
ENV GO_VERSION=1.21.0
ENV CLIVERSION $CLIVERSION
WORKDIR /cli
EXPOSE 26635

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then export ARCHITECTURE=amd64; \
	elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then export ARCHITECTURE=arm; \
	elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then export ARCHITECTURE=arm64; \
	else export ARCHITECTURE=amd64; fi; \
	echo "export ARCHITECTURE=${ARCHITECTURE}" >> /etc/profile

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
		curl \
		git \
		build-essential \
		rename \
		default-jdk-headless \
	; \
	rm -rf /var/lib/apt/lists/*

RUN . /etc/profile ; wget "https://go.dev/dl/go${GO_VERSION}.linux-${ARCHITECTURE}.tar.gz" && \
		tar -C /usr/local -xzf "go${GO_VERSION}.linux-${ARCHITECTURE}.tar.gz" && \
		rm "go${GO_VERSION}.linux-${ARCHITECTURE}.tar.gz" ; \
		echo "export PATH=${PATH}:/usr/local/go/bin:/root/go/bin:/cli" >> /etc/profile

ENV PATH=${PATH}:/usr/local/go/bin:/root/go/bin:/cli

RUN . /etc/profile ; git clone https://github.com/confluentinc/cli.git . && \
	git checkout "tags/${CLIVERSION}" -b "${CLIVERSION}-branch" && \
	go mod vendor && \
	make "gorelease-linux-${ARCHITECTURE}" && \
	mv "prebuilt/confluent-linux-${ARCHITECTURE}_linux_${ARCHITECTURE}/confluent" /usr/local/bin; \
	cd /usr/local/bin ; chmod +x confluent ; \
	rm -rf /cli

WORKDIR /root

RUN . /etc/profile ; git clone https://github.com/apache/kafka.git --depth=1 && \
	cd kafka && \
	./gradlew jar -PscalaVersion=2.13

COPY ./x-www-browser.sh /usr/local/bin/x-www-browser
RUN chmod +x /usr/local/bin/x-www-browser

ENTRYPOINT sh -c "echo 'Running...' ; tail -f /dev/null;"
